#!/usr/bin/env bash
#
# Install the Pulumi CLI, optionally at a pinned version, and prove we got what
# we asked for.
#
# Env:
#   PULUMI_VERSION  version to install (blank = latest stable). Accepts either
#                   "3.256.0" or "v3.256.0".
#
# Outputs (to $GITHUB_OUTPUT): version
set -euo pipefail

PULUMI_VERSION="${PULUMI_VERSION:-}"

if [[ -n "$PULUMI_VERSION" ]]; then
  # `pulumi version` reports v3.256.0, and that is the natural thing to copy into
  # pins.yml — but the installer expects 3.256.0 and builds a bad download URL
  # from a leading "v". Accept either form.
  curl -fsSL https://get.pulumi.com | sh -s -- --version "${PULUMI_VERSION#v}"
else
  curl -fsSL https://get.pulumi.com | sh
fi

[[ -n "${GITHUB_PATH:-}" ]] && echo "$HOME/.pulumi/bin" >> "$GITHUB_PATH"
export PATH="$HOME/.pulumi/bin:$PATH"

installed="$(pulumi version)"
echo "Installed Pulumi CLI: $installed"
[[ -n "${GITHUB_OUTPUT:-}" ]] && echo "version=$installed" >> "$GITHUB_OUTPUT"

# A silently-ignored --version would defeat the point of pinning.
if [[ -n "$PULUMI_VERSION" && "${installed#v}" != "${PULUMI_VERSION#v}" ]]; then
  echo "::error::Requested Pulumi CLI ${PULUMI_VERSION} but got ${installed}."
  exit 1
fi
