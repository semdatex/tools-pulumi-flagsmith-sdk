#!/usr/bin/env bash
#
# Prove this repo is consumable the way consumers actually consume it.
#
# `npm pack` produces exactly the tarball npm builds when resolving a git
# dependency, so packing and installing that tarball is a high-fidelity local
# stand-in for `npm install github:semdatex/tools-pulumi-flagsmith-sdk#<tag>`
# — and it works before the repository is public, or even before it exists.
#
# The install uses --ignore-scripts. That is the point: a git dependency must be
# usable with zero lifecycle scripts, which is only true because bin/ is
# committed and the postinstall hook is removed.
#
# Then it typechecks a real consumer program against the shipped .d.ts files,
# which is the only way to assert the type-level `FeatureResourceState` alias.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

echo "==> Packing the repo as npm would for a git dependency"
TARBALL="$(cd "$ROOT" && npm pack --silent --pack-destination "$WORK")"
TARBALL="$WORK/$TARBALL"
echo "    $(basename "$TARBALL") ($(wc -c < "$TARBALL") bytes)"

echo "==> Asserting the tarball ships the committed build output"
tar -tzf "$TARBALL" > "$WORK/contents.txt"
# LICENSE and NOTICE.md are asserted alongside the build output on purpose: the
# SDK is a derived work of an MPL-2.0 provider, so a tarball that shipped the
# code without the licence and the upstream attribution would be a distribution
# problem, not a cosmetic one.
for required in \
  "package/bin/index.js" \
  "package/bin/index.d.ts" \
  "package/bin/package.json" \
  "package/package.json" \
  "package/NOTICE.md" \
  "package/LICENSE"; do
  if ! grep -qx "$required" "$WORK/contents.txt"; then
    echo "consumer-smoke: FAILED — $required missing from the package tarball." >&2
    echo "Tarball contents:" >&2
    sed 's/^/  /' "$WORK/contents.txt" >&2
    exit 1
  fi
  echo "    ok $required"
done

echo "==> Creating a scratch consumer project"
mkdir -p "$WORK/consumer"
cd "$WORK/consumer"
npm init -y >/dev/null
# Pin a TypeScript the consumer controls, as a real consumer would.
npm install --silent --ignore-scripts typescript@5 @types/node@20 >/dev/null

echo "==> Installing the SDK with --ignore-scripts (zero lifecycle scripts)"
npm install --silent --ignore-scripts "$TARBALL"

echo "==> Confirming nothing was built at install time"
if [[ ! -f node_modules/@semdatex/pulumi-flagsmith/bin/index.js ]]; then
  echo "consumer-smoke: FAILED — bin/index.js absent after an ignore-scripts install." >&2
  exit 1
fi
echo "    ok bin/index.js present without any script having run"

cat > tsconfig.json <<'JSON'
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "nodenext",
    "moduleResolution": "nodenext",
    "types": ["node"],
    "strict": true,
    "noEmit": true,
    "skipLibCheck": true
  },
  "files": ["consumer.ts"]
}
JSON

# A real consumer program: constructs resources, and touches the export surface
# including the type-only alias the patch introduces.
cat > consumer.ts <<'TS'
import * as flagsmith from "@semdatex/pulumi-flagsmith";

// Resource classes must be constructible with typed args. The property names
// and types below are asserted against the shipped .d.ts, so a codegen change
// that renamed or retyped them would fail this compile.
const project = new flagsmith.Project("smoke-project", {
    name: "smoke",
    organisationId: 1,
});

const feature = new flagsmith.Feature("smoke-feature", {
    projectUuid: project.uuid,
    featureName: "smoke_flag",
    defaultEnabled: false,
});

// FeatureState is a distinct *resource class*, not Feature's state interface.
export type FeatureStateResource = flagsmith.FeatureState;

// ...because the patch renamed Feature's state interface to FeatureResourceState.
// If the alias is missing or the collision came back, this line fails to compile.
export type FeatureStateInterface = flagsmith.FeatureResourceState;

// The rest of the documented export surface.
export type Env = flagsmith.Environment;
export type Seg = flagsmith.Segment;
export type Mv = flagsmith.MvFeatureOption;
export type Tg = flagsmith.Tag;
export type Prov = flagsmith.Provider;

export const ids = [project.id, feature.id];
TS

echo "==> Typechecking the consumer against the shipped .d.ts"
./node_modules/.bin/tsc --noEmit -p tsconfig.json

echo
echo "consumer-smoke: passed — packed, installed with --ignore-scripts, and compiled."
