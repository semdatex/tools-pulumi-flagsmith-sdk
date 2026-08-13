#!/usr/bin/env bash
#
# The single definition of "the SDK is good", shared by ci.yml (every PR and
# push to main) and regenerate.yml (before a proposal PR is opened) — so the
# two gates cannot drift apart.
#
# Usage:
#   scripts/gate.sh [--install ci|install] [--check-bin]
#
#   --install ci        clean install against the committed lockfile (default;
#                       what ci.yml wants)
#   --install install   plain npm install — for the regenerate flow, where
#                       codegen just rewrote package.json and the committed
#                       lockfile is LEGITIMATELY stale (npm ci would correctly
#                       refuse; the refreshed lockfile becomes part of the
#                       proposal)
#   --check-bin         delete bin/ before building and fail on any difference
#                       afterwards. Only meaningful where bin/ is supposed to
#                       already be correct (ci.yml); the regenerate flow omits
#                       it because a changed bin/ is the point there.
#
# Stages, in order: install, build, bin-freshness (opt), pins, smoke, consumer.
#
# Why --check-bin deletes bin/ first: `git diff -- bin` only compares TRACKED
# content, so it is blind in both directions — a new source file whose compiled
# output was never committed (the output appears as untracked, diff silent),
# and a deleted source whose stale committed output lingers (nothing changes,
# diff silent). Rebuilding from nothing and asking `git status --porcelain`
# catches both: the first shows `??`, the second shows ` D`.
#
# On failure the LAST line printed is
#
#   gate: FAILED at stage: <stage>
#
# which regenerate.yml parses into BUILD-FAILURE.md for failed-proposal
# attribution. Do not change that format without changing the parser.
set -Eeuo pipefail

INSTALL=ci
CHECK_BIN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --install)
      INSTALL="${2:?gate: --install needs a value (ci|install)}"
      shift 2
      ;;
    --check-bin)
      CHECK_BIN=true
      shift
      ;;
    *)
      echo "gate: unknown argument '$1' (usage: gate.sh [--install ci|install] [--check-bin])" >&2
      exit 2
      ;;
  esac
done
case "$INSTALL" in
  ci | install) ;;
  *)
    echo "gate: --install must be 'ci' or 'install', got '$INSTALL'" >&2
    exit 2
    ;;
esac

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

stage=startup
on_err() {
  # Deliberately the last line on failure — see the header.
  echo "gate: FAILED at stage: $stage"
}
trap on_err ERR

stage=install
echo "==> [gate] install (npm $INSTALL, --ignore-scripts)"
if [[ "$INSTALL" == "ci" ]]; then
  npm ci --ignore-scripts
else
  npm install --ignore-scripts
fi

if [[ "$CHECK_BIN" == true ]]; then
  echo "==> [gate] deleting bin/ so the build must reproduce it from nothing"
  rm -rf bin
fi

stage=build
echo "==> [gate] build"
npm run build

if [[ "$CHECK_BIN" == true ]]; then
  stage=bin-freshness
  echo "==> [gate] committed bin/ must match the sources"
  drift="$(git status --porcelain -- bin)"
  if [[ -n "$drift" ]]; then
    echo "bin/ is out of date with the sources:"
    echo "$drift"
    echo "Run 'npm ci --ignore-scripts && npm run build' and commit the result."
    false
  fi
  echo "bin/ is reproducible from the committed sources."
fi

stage=pins
echo "==> [gate] pins.yml must describe the built artifact"
declared_provider="$(./scripts/read-pins.sh provider)"
declared_bridge="$(./scripts/read-pins.sh bridge)"
built_provider="$(node -p "require('./package.json').pulumi.parameterization.version")"
built_bridge="$(node -p "require('./package.json').pulumi.version")"
if [[ "$declared_provider" != "$built_provider" || "$declared_bridge" != "$built_bridge" ]]; then
  echo "pins.yml declares provider ${declared_provider} / bridge ${declared_bridge},"
  echo "but package.json was built with provider ${built_provider} / bridge ${built_bridge}."
  echo "Do not hand-edit package.json. Change pins.yml, then rebuild:"
  echo "  scripts/regenerate.sh <provider> <bridge> && npm install && npm run build"
  false
fi
echo "pins.yml and package.json agree: provider ${built_provider}, bridge ${built_bridge}."

stage=smoke
echo "==> [gate] runtime smoke test"
EXPECTED_PROVIDER_VERSION="$declared_provider" \
  EXPECTED_BRIDGE_VERSION="$declared_bridge" \
  node scripts/smoke-test.js

stage=consumer
echo "==> [gate] consumer smoke test"
./scripts/consumer-smoke.sh

echo "gate: PASSED (install=$INSTALL, check-bin=$CHECK_BIN)"
