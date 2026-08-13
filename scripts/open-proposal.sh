#!/usr/bin/env bash
#
# Commit the regenerated SDK to a proposal branch and open (or refresh) its PR.
#
# Runs for BOTH verdicts. A failing gate still gets a PR, deliberately: the
# likeliest failure is upstream codegen drift, and a visible proposal carrying
# its own reproduction beats a red cron run in an inbox nobody reads. The
# difference is draft vs ready, the label, and the commit status the caller
# stamps afterwards.
#
# Env:
#   BRANCH, PROVIDER, BRIDGE, OLD_PROVIDER, OLD_BRIDGE, PULUMI_CLI, RUN_URL
#   PASSED        "true" | "false"
#   FAILED_STAGE  set when PASSED != true
#   GH_TOKEN      for the gh CLI
#
# Outputs (to $GITHUB_OUTPUT): opened, sha
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

: "${BRANCH:?}" "${PROVIDER:?}" "${BRIDGE:?}"
PASSED="${PASSED:-false}"
PULUMI_CLI="${PULUMI_CLI:-unknown}"
OLD_PROVIDER="${OLD_PROVIDER:-none}"
OLD_BRIDGE="${OLD_BRIDGE:-none}"
RUN_URL="${RUN_URL:-}"
FAILED_STAGE="${FAILED_STAGE:-}"
GITHUB_REPOSITORY="${GITHUB_REPOSITORY:-semdatex/tools-pulumi-flagsmith-sdk}"

emit() { [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "$1" >> "$GITHUB_OUTPUT" || echo "$1"; }

if [[ -z "$(git status --porcelain)" ]]; then
  echo "::notice::Regeneration produced no changes — nothing to propose."
  emit "opened=false"
  exit 0
fi

git config user.name "github-actions[bot]"
git config user.email "41898282+github-actions[bot]@users.noreply.github.com"
git checkout -B "$BRANCH"
git add -A

if [[ "$PASSED" == "true" ]]; then
  title="chore: SDK for provider ${PROVIDER}, bridge ${BRIDGE}"
else
  title="[BUILD FAILING] SDK for provider ${PROVIDER}, bridge ${BRIDGE}"
fi

git commit -m "$title" -m "Proposed by the Regenerate SDK workflow (run ${GITHUB_RUN_ID:-local}).

Provider: ${OLD_PROVIDER} -> ${PROVIDER}
Bridge:   ${OLD_BRIDGE} -> ${BRIDGE}
Gate:     ${PASSED}

Provider-Version: ${PROVIDER}
Bridge-Version: ${BRIDGE}
Pulumi-CLI-Version: ${PULUMI_CLI}"

# The branch name is deterministic, so a leftover remote branch from a closed
# proposal would wedge a plain push forever. Force is safe precisely because the
# decide step established that no OPEN PR points at this branch — anything on it
# is stale by definition.
git push --force -u origin "$BRANCH"
emit "sha=$(git rev-parse HEAD)"

export PROVIDER BRIDGE OLD_PROVIDER OLD_BRIDGE PULUMI_CLI RUN_URL FAILED_STAGE GITHUB_REPOSITORY
TEMPLATE_VARS=(PROVIDER BRIDGE OLD_PROVIDER OLD_BRIDGE PULUMI_CLI RUN_URL FAILED_STAGE GITHUB_REPOSITORY)

if [[ "$PASSED" == "true" ]]; then
  body="$(./scripts/render-template.sh proposal-passed "${TEMPLATE_VARS[@]}")"
  gh pr create --base main --head "$BRANCH" --title "$title" --body "$body"
else
  body="$(./scripts/render-template.sh proposal-failed "${TEMPLATE_VARS[@]}")"
  gh pr create --base main --head "$BRANCH" --title "$title" --body "$body" --draft

  # The label is not managed as IaC, so create it on first use. Never fatal: the
  # draft state, the failing commit status and BUILD-FAILURE.md already mark this
  # PR without it.
  gh label create "build-failing" \
    --color "B60205" \
    --description "Regeneration produced an SDK that does not build" 2>/dev/null || true
  gh pr edit "$BRANCH" --add-label "build-failing" 2>/dev/null \
    || echo "::notice::Could not apply the build-failing label; the draft state, commit status and BUILD-FAILURE.md still mark this PR."
fi

emit "opened=true"
echo "open-proposal: opened PR on $BRANCH (passed=$PASSED)" >&2
