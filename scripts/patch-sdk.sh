#!/usr/bin/env bash
#
# Work around a Pulumi nodejs-codegen name collision in the generated
# Flagsmith SDK. On a provider upgrade, run from the repo root AFTER
# `pulumi package gen-sdk` regenerated the SDK sources, and BEFORE
# installing deps.
#
# Cause: Pulumi emits a `<Name>State` interface for every resource (the
# `get()`/import state type). The provider has both `flagsmith_feature` and
# `flagsmith_feature_state`, so `index.ts` ends up exporting `FeatureState`
# twice — once as Feature's state interface, once as the FeatureState
# resource class:
#
#   export { FeatureArgs, FeatureState } from "./feature";        <- interface
#   export type  FeatureState = import("./featureState").FeatureState;
#   export const FeatureState: ... = null as any;                 <- resource
#
#   index.ts: error TS2323: Cannot redeclare exported variable 'FeatureState'.
#   index.ts: error TS2484: Export declaration conflicts with exported
#                           declaration of 'FeatureState'.
#
# Fix: alias the *interface* on the `./feature` re-export line only. The
# resource class keeps its name and its provider mapping, so nothing about
# runtime behaviour changes; we merely rename a type this program never
# uses. Touching only lines that import from "./feature" keeps the edit
# from affecting the resource export.
#
# This is idempotent and safe to re-run.
set -euo pipefail

INDEX="${1:-index.ts}"

if [[ ! -f "$INDEX" ]]; then
  echo "patch-sdk: $INDEX not found — run 'scripts/regenerate.sh' first." >&2
  exit 1
fi

if grep -q 'FeatureState as FeatureResourceState' "$INDEX"; then
  echo "patch-sdk: already patched."
  exit 0
fi

# A newer Pulumi may disambiguate this itself. Only patch when the collision
# is actually present: FeatureState re-exported from "./feature" (the state
# interface) AND declared from "./featureState" (the resource class).
if ! grep -q 'FeatureState[^)]*from "\./feature";' "$INDEX" ||
  ! grep -q 'from "\./featureState"' "$INDEX"; then
  echo "patch-sdk: no FeatureState collision in $INDEX — nothing to patch."
  echo "(Codegen likely fixed upstream. Just install; if tsc still fails, paste"
  echo " the error and the first 30 lines of $INDEX.)"
  exit 0
fi

perl -pi -e 'if (m{from "\./feature";}) { s/\bFeatureState\b/FeatureState as FeatureResourceState/ }' "$INDEX"

if ! grep -q 'FeatureState as FeatureResourceState' "$INDEX"; then
  echo "patch-sdk: FAILED to patch — the generated index.ts does not match the" >&2
  echo "expected shape. Inspect it and alias the FeatureState re-exported from" >&2
  echo "\"./feature\" by hand:" >&2
  echo "  sed -n '1,30p' $INDEX" >&2
  exit 1
fi

echo "patch-sdk: aliased Feature's state interface to FeatureResourceState."
echo "Now run 'scripts/repackage.sh' and 'npm install && npm run build'."
