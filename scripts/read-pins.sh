#!/usr/bin/env bash
#
# Read the declared build pins from pins.yml.
#
# pins.yml is deliberately a flat `key: "value"` file so it can be read without
# a YAML library — GitHub runners have no guaranteed `yq`, and pulling in a
# parser to read three strings would be silly. The trade-off is that this reader
# is strict rather than clever: it accepts exactly that shape and fails loudly on
# anything else, because a pin that silently reads as empty would send codegen
# after the wrong version.
#
# Usage:
#   scripts/read-pins.sh              # provider=... / bridge=... / pulumi_cli=...
#   scripts/read-pins.sh provider     # just the value
#
# Output is KEY=VALUE lines, so it can be appended straight to $GITHUB_OUTPUT.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PINS="$ROOT/pins.yml"

if [[ ! -f "$PINS" ]]; then
  echo "read-pins: $PINS not found." >&2
  exit 1
fi

# Strict scalar read: `key: value`, optional quotes, optional trailing comment.
# Anchored to the start of the line so a commented-out example cannot win.
read_key() {
  local key="$1"
  sed -n -E "s/^${key}:[[:space:]]*(.*)\$/\1/p" "$PINS" \
    | head -1 \
    | sed -E 's/[[:space:]]+#.*$//' \
    | sed -E 's/^"(.*)"$/\1/; s/^'"'"'(.*)'"'"'$/\1/' \
    | sed -E 's/[[:space:]]+$//'
}

PROVIDER="$(read_key provider)"
BRIDGE="$(read_key bridge)"
PULUMI_CLI="$(read_key pulumi_cli)"

# A version-ish token: starts with a digit, then the usual semver alphabet.
version_re='^[0-9][0-9A-Za-z._+-]*$'

for required in provider bridge; do
  value="$(read_key "$required")"
  if [[ -z "$value" ]]; then
    echo "read-pins: '${required}' is missing or empty in pins.yml." >&2
    echo "Both 'provider' and 'bridge' must be set — regeneration will not guess." >&2
    exit 1
  fi
  if [[ ! "$value" =~ $version_re ]]; then
    echo "read-pins: '${required}' is '${value}', which does not look like a version." >&2
    echo "Expected something like 0.10.0 (no leading 'v')." >&2
    exit 1
  fi
done

# pulumi_cli is optional (empty = latest stable), but if set it must be sane.
if [[ -n "$PULUMI_CLI" && ! "$PULUMI_CLI" =~ ^v?[0-9][0-9A-Za-z._+-]*$ ]]; then
  echo "read-pins: 'pulumi_cli' is '${PULUMI_CLI}', which does not look like a version." >&2
  echo "Leave it empty for the latest stable release." >&2
  exit 1
fi

if [[ $# -gt 0 ]]; then
  case "$1" in
    provider)   echo "$PROVIDER" ;;
    bridge)     echo "$BRIDGE" ;;
    pulumi_cli) echo "$PULUMI_CLI" ;;
    *) echo "read-pins: unknown key '$1' (expected provider|bridge|pulumi_cli)." >&2; exit 1 ;;
  esac
  exit 0
fi

echo "provider=$PROVIDER"
echo "bridge=$BRIDGE"
echo "pulumi_cli=$PULUMI_CLI"
