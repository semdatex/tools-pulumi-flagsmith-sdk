#!/usr/bin/env bash
#
# Report the inline gate's verdict as a commit status on the proposal's head
# commit, so it shows as the usual green/red row in the PR's merge box.
#
# Why this exists: GitHub does not start workflows for events caused by the
# default GITHUB_TOKEN, so ci.yml never runs on a bot-opened PR and the gate
# result would otherwise be invisible outside the run log. Reporting a status is
# permitted with GITHUB_TOKEN; only triggering workflows is not.
#
# Deliberately NOT a required status check: only the proposing workflow ever
# reports this context, so requiring it would deadlock ordinary human PRs that
# never receive it.
#
# Env: SHA, PASSED, FAILED_STAGE, RUN_URL, GH_TOKEN, GITHUB_REPOSITORY
set -euo pipefail

: "${SHA:?}" "${GITHUB_REPOSITORY:?}"
PASSED="${PASSED:-false}"
RUN_URL="${RUN_URL:-}"

if [[ "$PASSED" == "true" ]]; then
  state=success
  description="gate.sh passed: install, build, pins, smoke, consumer"
else
  state=failure
  description="failed at ${FAILED_STAGE:-unknown}"
fi

# The API caps descriptions at 140 characters.
gh api "repos/${GITHUB_REPOSITORY}/statuses/${SHA}" \
  -f state="$state" \
  -f context="regenerate-gate" \
  -f description="${description:0:139}" \
  -f target_url="$RUN_URL" >/dev/null

echo "stamp-status: ${state} on ${SHA}"
