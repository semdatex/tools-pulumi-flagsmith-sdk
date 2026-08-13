#!/usr/bin/env bash
#
# Compute the next release tag, or decline.
#
# Tag scheme: v<provider>-sdk.<n>
#   <provider> = the bridged Flagsmith provider version (== package.json version)
#   <n>        = increments for regenerations that change the output WITHOUT a
#                provider bump (bridge upgrade, patch change, packaging fix),
#                and resets to 1 when the provider version changes.
#
# Idempotent by content: tags are immutable (a ruleset blocks update and
# deletion), so this refuses to cut a second tag for SDK content identical to
# the last one. That is what makes it safe to run on every green build.
#
# Env:
#   FORCE  "true" to tag even when the content is unchanged
#
# Outputs (to $GITHUB_OUTPUT): should_tag, tag, provider
#
# Run it locally to see what would be cut:
#   scripts/next-tag.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FORCE="${FORCE:-false}"
emit() { [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "$1" >> "$GITHUB_OUTPUT" || echo "$1"; }

provider="$(node -p "require('./package.json').pulumi.parameterization.version")"
pkg_version="$(node -p "require('./package.json').version")"

if [[ "$provider" != "$pkg_version" ]]; then
  echo "::error::package.json version ($pkg_version) != provider version ($provider)."
  echo "This repo pins them equal; repackage.sh normally enforces it."
  exit 1
fi

# Hash of the SDK artifact only — everything except repository scaffolding.
# A deny-list, so newly generated files are included automatically. pins.yml is
# excluded on purpose: it is the declaration, not the artifact, so a comment-only
# edit there must not mint a new tag around byte-identical SDK content.
# (ls-tree prints "<hash> <path>", hence the anchor after the first space.)
sdk_hash() {
  git ls-tree -r "$1" --format='%(objectname) %(path)' \
    | grep -Ev '^[0-9a-f]+ (\.github/|docs/|scripts/|pins\.yml$|README\.md$|LICENSE$|BUILD-FAILURE\.md$|\.gitignore$|\.gitattributes$|package-lock\.json$)' \
    | sort -k2 \
    | sha256sum | cut -d' ' -f1
}

current_hash="$(sdk_hash HEAD)"
echo "SDK content hash: $current_hash" >&2

# Highest existing <n> for this provider version.
highest=0
latest_tag=""
while read -r tag; do
  [[ -z "$tag" ]] && continue
  n="${tag##*-sdk.}"
  if [[ "$n" =~ ^[0-9]+$ ]] && ((n > highest)); then
    highest="$n"
    latest_tag="$tag"
  fi
done < <(git tag --list "v${provider}-sdk.*")

if [[ -n "$latest_tag" ]]; then
  echo "Latest tag for provider $provider: $latest_tag" >&2
  if [[ "$(sdk_hash "$latest_tag")" == "$current_hash" && "$FORCE" != "true" ]]; then
    echo "SDK content is identical to $latest_tag — not cutting a duplicate tag." >&2
    emit "should_tag=false"
    emit "tag=$latest_tag"
    exit 0
  fi
else
  echo "No existing tag for provider $provider — this will be .1" >&2
fi

next="v${provider}-sdk.$((highest + 1))"

if git rev-parse -q --verify "refs/tags/$next" >/dev/null; then
  echo "::error::Tag $next already exists. Tags are immutable and cannot be moved."
  exit 1
fi

emit "should_tag=true"
emit "tag=$next"
emit "provider=$provider"
echo "next-tag: $next" >&2
