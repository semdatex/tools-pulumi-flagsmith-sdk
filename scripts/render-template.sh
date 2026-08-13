#!/usr/bin/env bash
#
# Render a template from .github/templates/ by substituting ${VAR} placeholders
# from the environment, and print it.
#
# Exists so PR bodies and BUILD-FAILURE.md are written as markdown files —
# editable, previewable, diffable — instead of heredocs nested inside bash inside
# YAML, where every backtick and dollar sign needs escaping.
#
# Substitution is restricted to a NAMED variable list, so markdown containing
# shell-looking text (a `${...}` inside a code sample, say) is left alone unless
# it is one of the placeholders we actually mean.
#
# Implemented with node rather than envsubst on purpose: node is already a hard
# requirement of this repo, whereas envsubst comes from gettext-base and is not
# guaranteed on every image — depending on it would mean depending on something
# this repo cannot test locally.
#
# Usage:
#   VAR=value scripts/render-template.sh <name> VAR [VAR...]
#
# Example:
#   PROVIDER=0.11.0 scripts/render-template.sh proposal-passed PROVIDER
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
NAME="${1:?usage: render-template.sh <template-name> [VAR...]}"
shift

TEMPLATE="$ROOT/.github/templates/${NAME}.md"
[[ -f "$TEMPLATE" ]] || {
  echo "render-template: no such template: $TEMPLATE" >&2
  exit 1
}

TEMPLATE_PATH="$TEMPLATE" ALLOWED="$*" node -e '
const fs = require("node:fs");
const text = fs.readFileSync(process.env.TEMPLATE_PATH, "utf8");
const allowed = (process.env.ALLOWED || "").split(/\s+/).filter(Boolean);

let out = text;
for (const name of allowed) {
  // Replace ${NAME} with the env value. A function replacement is used so that
  // "$" sequences in the VALUE (e.g. $&) are inserted literally rather than
  // being interpreted as replacement patterns.
  const value = process.env[name] ?? "";
  out = out.split("${" + name + "}").join(value);
}
process.stdout.write(out);
'
