#!/usr/bin/env bash
#
# Regenerate the Flagsmith SDK from the bridged Terraform provider, in place.
#
# Both dimensions are pinned explicitly and neither ever defaults to "latest":
#   - the bridge plugin (`terraform-provider`), which does the bridging
#   - the Flagsmith provider itself, resolved from registry.opentofu.org
#
# Usage:
#   scripts/regenerate.sh <provider-version> <bridge-version>
#   scripts/regenerate.sh 0.10.0 1.3.0
#
# Requires: pulumi CLI, node, and network egress to Pulumi's plugin releases
# and registry.opentofu.org.
#
# No Pulumi Cloud account is involved. Codegen is a pure local operation, but
# the CLI wants *a* backend, so we point it at a throwaway local one.
set -euo pipefail

PROVIDER_VERSION="${1:?usage: regenerate.sh <provider-version> <bridge-version>}"
BRIDGE_VERSION="${2:?usage: regenerate.sh <provider-version> <bridge-version>}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

# A local, throwaway backend. Avoids `pulumi login` and never touches Pulumi Cloud.
export PULUMI_BACKEND_URL="file://$WORK/state"
export PULUMI_CONFIG_PASSPHRASE=""
mkdir -p "$WORK/state"
pulumi login --local >/dev/null 2>&1 || true

echo "==> Pinning bridge plugin: terraform-provider $BRIDGE_VERSION"
pulumi plugin install resource terraform-provider "$BRIDGE_VERSION"

echo "==> Generating nodejs SDK: Flagsmith/flagsmith $PROVIDER_VERSION"
# `--local` produces the local-package form, which is what carries the
# `pulumi.parameterization` block in package.json that runtime plugin
# resolution depends on. Do not drop it.
pulumi package gen-sdk \
  terraform-provider "Flagsmith/flagsmith" "$PROVIDER_VERSION" \
  --language nodejs \
  --local \
  --out "$WORK/out"

# The exact nesting under --out has varied across Pulumi releases
# (`<out>/` vs `<out>/nodejs/`). Rather than hardcode a guess, find the
# directory that actually holds the generated package.
GEN=""
while IFS= read -r candidate; do
  if node -e "process.exit(JSON.parse(require('fs').readFileSync('$candidate','utf8')).name === '@pulumi/flagsmith' ? 0 : 1)" 2>/dev/null; then
    GEN="$(dirname "$candidate")"
    break
  fi
done < <(find "$WORK/out" -name package.json -not -path '*/node_modules/*' | sort)

if [[ -z "$GEN" ]]; then
  echo "regenerate: FAILED — could not find generated '@pulumi/flagsmith' package under $WORK/out." >&2
  echo "Generated tree was:" >&2
  find "$WORK/out" -maxdepth 3 >&2
  exit 1
fi
echo "==> Generated package found at: $GEN"

# Replace only the generated surface. Root-level *.ts, config/ and types/ are
# entirely codegen-owned, so clearing them first means a resource removed
# upstream does not linger here as a stale file.
echo "==> Syncing generated sources into the repo"
rm -f ./*.ts
rm -rf ./config ./types

# Copy the generated tree EXCEPT its README.md.
#
# Codegen emits a README.md containing the upstream MPL-2.0 attribution. A plain
# copy lands it on top of this repository's own README.md, and repackage.sh then
# moves it to NOTICE.md — leaving the repo with no README at all. That is not
# hypothetical: it happened on the first real regeneration run.
#
# So the generated README never occupies README.md. It goes straight to
# NOTICE.md, byte-for-byte, which is where the attribution belongs.
( cd "$GEN" && tar --exclude=./README.md -cf - . ) | tar -xf - -C "$ROOT"

if [[ -f "$GEN/README.md" ]]; then
  cp "$GEN/README.md" "$ROOT/NOTICE.md"
  echo "==> Preserved codegen's README.md as NOTICE.md"
else
  echo "regenerate: WARNING — codegen produced no README.md, so the upstream" >&2
  echo "attribution could not be refreshed. NOTICE.md is left as-is;" >&2
  echo "repackage.sh will fail if it is missing or no longer mentions MPL 2.0." >&2
fi

# The generated tree ships scripts/postinstall.js; repackage.sh removes it.
# Our own scripts/ files are not present in the generated tree, so the copy
# above cannot clobber them.

echo "==> Applying upstream codegen bug workaround"
scripts/patch-sdk.sh index.ts

echo "==> Applying packaging deviations + verifying parameterization"
scripts/repackage.sh "$PROVIDER_VERSION" "$BRIDGE_VERSION"

echo
echo "Regeneration complete. Next:"
echo "  npm install && npm run build   # refreshes committed bin/"
echo "  git status                     # review the diff before committing"
