#!/usr/bin/env bash
#
# Turn the regenerate job's per-step outcomes into one verdict, and on failure
# write BUILD-FAILURE.md — the marker that makes a broken proposal
# self-documenting and blocks it from ever becoming a release tag.
#
# The marker is COMMITTED to the branch rather than only written into the PR
# body because Actions logs expire and a blocked proposal may sit for months
# waiting on upstream.
#
# Env:
#   O_WRITEPINS, O_REGEN, O_GATE   step outcomes ("success" | anything else)
#   PROVIDER, BRIDGE, PULUMI_CLI, RUN_URL
#   GATE_LOG                       file with captured gate output
#                                  (default: gate-output.txt)
#
# Outputs (to $GITHUB_OUTPUT): passed, failed_stage
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

O_WRITEPINS="${O_WRITEPINS:-success}"
O_REGEN="${O_REGEN:-success}"
O_GATE="${O_GATE:-success}"
GATE_LOG="${GATE_LOG:-gate-output.txt}"
PROVIDER="${PROVIDER:-unknown}"
BRIDGE="${BRIDGE:-unknown}"
PULUMI_CLI="${PULUMI_CLI:-unknown}"
RUN_URL="${RUN_URL:-}"

emit() { [[ -n "${GITHUB_OUTPUT:-}" ]] && echo "$1" >> "$GITHUB_OUTPUT" || echo "$1"; }

failed_stage=""
if [[ "$O_WRITEPINS" != "success" ]]; then
  failed_stage="writing pins.yml"
elif [[ "$O_REGEN" != "success" ]]; then
  failed_stage="regeneration (codegen / patch-sdk.sh / repackage.sh)"
elif [[ "$O_GATE" != "success" ]]; then
  # gate.sh prints "gate: FAILED at stage: <stage>" as its last line.
  stage="$(grep -oE 'gate: FAILED at stage: .*' "$GATE_LOG" 2>/dev/null | tail -1 | sed 's/gate: FAILED at stage: //')"
  failed_stage="gate: ${stage:-unknown}"
fi

if [[ -z "$failed_stage" ]]; then
  emit "passed=true"
  rm -f "$GATE_LOG" BUILD-FAILURE.md
  echo "evaluate-gate: passed" >&2
  exit 0
fi

emit "passed=false"
emit "failed_stage=$failed_stage"
echo "::warning::Gate failed at: ${failed_stage}. Opening a draft PR marked build-failing."

# Cap the captured output so a runaway log cannot produce an unreviewable file.
GATE_OUTPUT="$(tail -c 60000 "$GATE_LOG" 2>/dev/null || echo "(no output captured)")"

export PROVIDER BRIDGE PULUMI_CLI RUN_URL FAILED_STAGE="$failed_stage" GATE_OUTPUT
./scripts/render-template.sh build-failure \
  PROVIDER BRIDGE PULUMI_CLI RUN_URL FAILED_STAGE GATE_OUTPUT > BUILD-FAILURE.md

rm -f "$GATE_LOG"
echo "evaluate-gate: FAILED at ${failed_stage}; wrote BUILD-FAILURE.md" >&2
