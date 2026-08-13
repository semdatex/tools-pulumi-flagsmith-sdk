#!/usr/bin/env bash
#
# Decide WHETHER to propose a build, and of WHAT.
#
# Reads the declared pins, asks GitHub for the latest upstream release, applies
# the override/skip rules, and writes its verdict to $GITHUB_OUTPUT (or stdout
# when run locally). It makes no changes and needs no write access.
#
# Env (all optional; the workflow passes dispatch inputs through):
#   IN_PROVIDER  explicit provider version for this run
#   IN_BRIDGE    explicit bridge version for this run
#   IN_PULUMI    explicit Pulumi CLI version for this run
#   FORCE        "true" to rebuild the declared pins, and to overrule a
#                previously rejected proposal
#
# Outputs: proceed, provider, bridge, pulumi_cli, old_provider, old_bridge,
#          branch, reason
#
# Run it locally to see what the next cron would do:
#   scripts/decide-build.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

IN_PROVIDER="${IN_PROVIDER:-}"
IN_BRIDGE="${IN_BRIDGE:-}"
IN_PULUMI="${IN_PULUMI:-}"
FORCE="${FORCE:-false}"

# A version-ish token, matching what read-pins.sh accepts.
VERSION_RE='^[0-9][0-9A-Za-z._+-]*$'

emit() { # key=value -> GITHUB_OUTPUT if set, else stdout
  if [[ -n "${GITHUB_OUTPUT:-}" ]]; then echo "$1" >> "$GITHUB_OUTPUT"; else echo "$1"; fi
}

# --- What is declared today ------------------------------------------------
# Fails loudly if pins.yml is missing, malformed, or has an empty pin.
cur_provider="$(./scripts/read-pins.sh provider)"
cur_bridge="$(./scripts/read-pins.sh bridge)"
cur_pulumi="$(./scripts/read-pins.sh pulumi_cli)"

# --- What upstream has -----------------------------------------------------
# Upstream tags releases as vX.Y.Z; the registry coordinate is X.Y.Z.
latest_raw="$(gh api repos/flagsmith/terraform-provider-flagsmith/releases/latest \
  --jq .tag_name 2>/dev/null || echo "")"
latest="${latest_raw#v}"
echo "Declared provider: $cur_provider | latest upstream release: ${latest:-lookup failed}" >&2

# --- Resolve the target ----------------------------------------------------
# explicit input > (force ? the declared pin : the latest release).
# `force` means "rebuild what is declared", so it must not silently retarget to
# a newer upstream.
if [[ -n "$IN_PROVIDER" ]]; then
  provider="$IN_PROVIDER"
elif [[ "$FORCE" == "true" ]]; then
  provider="$cur_provider"
elif [[ -n "$latest" ]]; then
  provider="$latest"
else
  # The watchdog's one job is noticing releases. When it cannot see them,
  # "nothing to do" would be a lie — fail so someone looks.
  echo "::error::Could not determine the latest upstream release and no provider_version was supplied."
  echo "::error::An API outage must not be indistinguishable from 'up to date'."
  exit 1
fi
bridge="${IN_BRIDGE:-$cur_bridge}"
pulumi_cli="${IN_PULUMI:-$cur_pulumi}"

# Dispatch inputs reach shell command lines and $GITHUB_OUTPUT; hold them to the
# same grammar read-pins.sh enforces so nothing shell-active (or newline-bearing)
# gets through. Only writers can dispatch, so this is consistency, not a trust
# boundary.
for v in "$provider" "$bridge"; do
  if [[ ! "$v" =~ $VERSION_RE ]]; then
    echo "::error::'$v' does not look like a version (expected e.g. 0.10.0, no leading 'v')."
    exit 1
  fi
done
if [[ -n "$pulumi_cli" && ! "$pulumi_cli" =~ ^v?[0-9][0-9A-Za-z._+-]*$ ]]; then
  echo "::error::pulumi_version '$pulumi_cli' does not look like a version."
  exit 1
fi

branch="propose/provider-${provider}-bridge-${bridge}"

# --- Should we actually propose? -------------------------------------------
proceed=true
reason=""

if [[ "$provider" == "$cur_provider" && "$bridge" == "$cur_bridge" && "$FORCE" != "true" ]]; then
  proceed=false
  reason="Already at provider $cur_provider / bridge $cur_bridge — nothing to propose."
else
  # One proposal per version pair. An OPEN PR means a human has not dealt with
  # the previous one; a CLOSED or MERGED one records an explicit human decision
  # that a Monday cron must not overrule — only FORCE may.
  prs="$(gh pr list --head "$branch" --state all --json number,state)"
  open_n="$(jq -r '[.[] | select(.state=="OPEN")][0].number // empty' <<<"$prs")"
  prior_state="$(jq -r '[.[] | select(.state!="OPEN")][0].state // empty' <<<"$prs")"

  if [[ -n "$open_n" ]]; then
    proceed=false
    reason="PR #${open_n} already proposes these versions and is awaiting review."
  elif [[ -n "$prior_state" && "$FORCE" != "true" ]]; then
    proceed=false
    case "$prior_state" in
      MERGED) reason="A proposal for these versions was already MERGED — pins.yml has likely changed since; dispatch with force to re-propose." ;;
      *)      reason="A proposal for these versions was previously CLOSED without merging — an explicit human 'no'; dispatch with force to overrule it." ;;
    esac
  fi
fi

# --- What was built last time (for the before/after report) ----------------
if [[ -f package.json ]]; then
  old_provider="$(node -p "require('./package.json').pulumi.parameterization.version")"
  old_bridge="$(node -p "require('./package.json').pulumi.version")"
else
  old_provider="none"
  old_bridge="none"
fi

emit "proceed=$proceed"
emit "provider=$provider"
emit "bridge=$bridge"
emit "pulumi_cli=$pulumi_cli"
emit "old_provider=$old_provider"
emit "old_bridge=$old_bridge"
emit "branch=$branch"
emit "reason=$reason"

if [[ -n "${GITHUB_STEP_SUMMARY:-}" ]]; then
  {
    echo "### Flagsmith provider"
    echo
    echo "| | |"
    echo "|---|---|"
    echo "| Declared in \`pins.yml\` | \`$cur_provider\` |"
    echo "| Latest upstream | \`${latest:-lookup failed}\` |"
    echo "| Target for this run | \`$provider\` |"
    echo
    [[ "$proceed" == "true" ]] && echo "Proposing a build — see the propose job." || echo "$reason"
  } >> "$GITHUB_STEP_SUMMARY"
fi

[[ "$proceed" == "true" ]] || echo "::notice::$reason"
echo "decide-build: proceed=$proceed provider=$provider bridge=$bridge" >&2
