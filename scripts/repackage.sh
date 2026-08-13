#!/usr/bin/env bash
#
# Re-apply this repo's packaging deviations to freshly generated SDK output.
#
# Why this is separate from patch-sdk.sh: that script works around an upstream
# codegen *bug* and is meant to be deleted wholesale the day Pulumi fixes it.
# This script encodes deliberate, permanent decisions about how we publish the
# SDK as a git dependency. Conflating the two would make the bug fix impossible
# to retire cleanly.
#
# The deviations, and why each exists:
#
#   1. No lifecycle scripts. A git dependency must be installable with
#      `--ignore-scripts`. Pulumi's generated package runs `tsc` in a
#      `postinstall`; we delete both the hook and the script it calls, and
#      commit the build output instead (see 2).
#   2. `typescript` moves to devDependencies. With no postinstall, TypeScript
#      is only needed to build here in CI — never by a consumer at runtime.
#      `@types/node` deliberately STAYS in dependencies: consumers typecheck
#      against our shipped .d.ts files, which reference node types.
#   3. `bin/` is committed, so `.gitignore` must not ignore it. The build step
#      also copies package.json into bin/ — utilities.getVersion() does
#      `require('./package.json')`, which resolves relative to bin/ at runtime.
#      Without it, every resource construction throws MODULE_NOT_FOUND.
#   4. The generated README.md becomes NOTICE.md, byte-for-byte. It carries the
#      upstream MPL-2.0 derived-work attribution and must not be lost; README.md
#      is this repo's own documentation.
#   5. `.gitattributes` keeps codegen's blanket `* linguist-generated` but
#      exempts the hand-authored paths.
#
# It also ASSERTS the load-bearing `pulumi.parameterization` block survived
# regeneration and matches the pins we expect — runtime plugin resolution
# depends on it, and a silent change there is a production incident, not a diff.
#
# Idempotent: safe to re-run on an already-repackaged tree.
set -euo pipefail

EXPECTED_PROVIDER_VERSION="${1:?usage: repackage.sh <provider-version> <bridge-version>}"
EXPECTED_BRIDGE_VERSION="${2:?usage: repackage.sh <provider-version> <bridge-version>}"

# 4. Verify the upstream attribution is in place.
#
# This script does NOT move README.md to NOTICE.md any more. It used to, and
# combined with regenerate.sh copying the generated tree over the repo root it
# destroyed this repository's own README: codegen's README landed on ours, then
# this move carried it off to NOTICE.md, leaving no README.md behind.
#
# regenerate.sh now writes NOTICE.md directly and never lets codegen's README
# occupy README.md. This script only checks the result — which keeps a single
# owner for that file and makes it impossible to reintroduce the same trap here.
if [[ ! -f NOTICE.md ]]; then
  echo "repackage: FAILED — NOTICE.md is missing. It carries the upstream MPL-2.0" >&2
  echo "attribution and must not be dropped. regenerate.sh writes it from codegen's" >&2
  echo "README.md; if you ran this script standalone, create it from that file." >&2
  exit 1
fi

if ! grep -q 'MPL 2.0' NOTICE.md; then
  echo "repackage: FAILED — NOTICE.md no longer mentions MPL 2.0. Upstream may" >&2
  echo "have changed its licensing notice. This repo is licensed MPL-2.0 to match" >&2
  echo "the upstream provider, so re-check LICENSE and the README attribution" >&2
  echo "against upstream's new terms before publishing." >&2
  exit 1
fi

# 1. Remove the postinstall hook script.
rm -f scripts/postinstall.js

# 3. bin/ is committed here.
printf 'node_modules/\n' > .gitignore

# 5. Generated marking, with our authored paths exempt.
cat > .gitattributes <<'ATTRS'
* linguist-generated

# Hand-authored files in this repo — exempt from the blanket generated marking
# above so they render normally in diffs and language stats.
README.md linguist-generated=false
LICENSE linguist-generated=false
.gitattributes linguist-generated=false
.github/** linguist-generated=false
docs/** linguist-generated=false
scripts/** linguist-generated=false
ATTRS

# 1 + 2 + assertions on package.json.
EXPECTED_PROVIDER_VERSION="$EXPECTED_PROVIDER_VERSION" \
EXPECTED_BRIDGE_VERSION="$EXPECTED_BRIDGE_VERSION" \
node - <<'NODE'
const fs = require("node:fs");

const file = "package.json";
const raw = fs.readFileSync(file, "utf8");
const pkg = JSON.parse(raw);
const fail = (msg) => { console.error(`repackage: FAILED — ${msg}`); process.exit(1); };

// --- Assertions on the load-bearing parameterization block -------------------
const p = pkg.pulumi;
if (!p) fail("package.json has no `pulumi` block. Runtime plugin resolution depends on it.");
if (p.resource !== true) fail("pulumi.resource is not true.");
if (p.name !== "terraform-provider") fail(`pulumi.name is "${p.name}", expected "terraform-provider".`);

const expectedBridge = process.env.EXPECTED_BRIDGE_VERSION;
if (p.version !== expectedBridge) {
  fail(`pulumi.version (bridge plugin) is "${p.version}", expected "${expectedBridge}". ` +
       `If this bump is intended, pass the new bridge version to this script.`);
}

const par = p.parameterization;
if (!par) fail("pulumi.parameterization is missing.");
if (par.name !== "flagsmith") fail(`pulumi.parameterization.name is "${par.name}", expected "flagsmith".`);

const expectedProvider = process.env.EXPECTED_PROVIDER_VERSION;
if (par.version !== expectedProvider) {
  fail(`pulumi.parameterization.version is "${par.version}", expected "${expectedProvider}".`);
}
if (pkg.version !== expectedProvider) {
  fail(`package version is "${pkg.version}", expected "${expectedProvider}" ` +
       `(this repo pins package.json version == provider version).`);
}

// The base64 value encodes the upstream provider coordinates. Decode and check
// them rather than string-matching the blob, so a re-encoding with identical
// meaning does not trip the gate.
let decoded;
try {
  decoded = JSON.parse(Buffer.from(par.value, "base64").toString("utf8"));
} catch {
  fail("pulumi.parameterization.value is not valid base64-encoded JSON.");
}
const remote = decoded?.remote ?? {};
if (remote.url !== "registry.opentofu.org/flagsmith/flagsmith") {
  fail(`parameterization remote.url is "${remote.url}", expected "registry.opentofu.org/flagsmith/flagsmith".`);
}
if (remote.version !== expectedProvider) {
  fail(`parameterization remote.version is "${remote.version}", expected "${expectedProvider}".`);
}

// --- Deviations --------------------------------------------------------------
pkg.scripts = pkg.scripts ?? {};
delete pkg.scripts.postinstall;
delete pkg.scripts.prepare;      // npm runs `prepare` for git deps; must not exist.
delete pkg.scripts.prepublish;
delete pkg.scripts.prepack;
// `tsc` alone is not a complete build here: utilities.getVersion() does
// `require('./package.json')`, which at runtime resolves to bin/package.json.
// Codegen's postinstall used to copy it; we do it as part of the build.
pkg.scripts.build = "tsc && node scripts/stamp-bin-package.js";

pkg.dependencies = pkg.dependencies ?? {};
pkg.devDependencies = pkg.devDependencies ?? {};
if (pkg.dependencies.typescript) {
  pkg.devDependencies.typescript = pkg.dependencies.typescript;
  delete pkg.dependencies.typescript;
}
if (!pkg.dependencies["@types/node"]) {
  fail("@types/node is not a runtime dependency; consumers typecheck against our .d.ts.");
}

// Preserve codegen's 4-space formatting and trailing newline.
fs.writeFileSync(file, JSON.stringify(pkg, null, 4) + "\n");
console.log("repackage: package.json normalised; parameterization verified " +
            `(bridge ${p.version}, provider ${par.version}).`);
NODE

echo "repackage: done."
