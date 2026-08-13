#!/usr/bin/env bash
#
# Write the target versions into pins.yml.
#
# All three pins are written, including the Pulumi CLI: a dispatch that
# overrides pulumi_version must not leave the declaration naming a CLI that did
# not produce the artifact — that is precisely the drift pins.yml promises
# cannot happen.
#
# The write is verified by reading it back through read-pins.sh, the same reader
# the rest of the pipeline uses, so a botched rewrite fails here rather than
# silently shipping a wrong pins.yml.
#
# Env: PROVIDER, BRIDGE, PULUMI_CLI_PIN (may be empty = "latest stable")
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

: "${PROVIDER:?}" "${BRIDGE:?}"
PULUMI_CLI_PIN="${PULUMI_CLI_PIN:-}"

sed -i -E "s|^provider:[[:space:]]*.*|provider: \"${PROVIDER}\"|" pins.yml
sed -i -E "s|^bridge:[[:space:]]*.*|bridge: \"${BRIDGE}\"|" pins.yml
sed -i -E "s|^pulumi_cli:[[:space:]]*.*|pulumi_cli: \"${PULUMI_CLI_PIN}\"|" pins.yml

[[ "$(./scripts/read-pins.sh provider)" == "$PROVIDER" ]]
[[ "$(./scripts/read-pins.sh bridge)" == "$BRIDGE" ]]
[[ "$(./scripts/read-pins.sh pulumi_cli)" == "$PULUMI_CLI_PIN" ]]

echo "write-pins: provider=$PROVIDER bridge=$BRIDGE pulumi_cli=${PULUMI_CLI_PIN:-<latest>}"
