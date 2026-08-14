// Runtime smoke test for the built SDK.
//
// Checks the things that would make this package silently useless to a consumer
// but that `tsc` alone cannot catch:
//
//   1. The package actually loads from its committed build output.
//   2. Every resource class the provider defines is exported and constructible.
//   3. getVersion() works — i.e. bin/package.json was stamped. Without it every
//      resource construction throws MODULE_NOT_FOUND at deploy time.
//   4. The `pulumi.parameterization` block is present and pinned as expected.
//      Runtime plugin resolution depends on it; a silent change is an incident.
//
// The `FeatureResourceState` alias is type-level only and cannot be asserted
// here — `scripts/consumer-smoke.sh` covers it with a real tsc compile.
"use strict";

const assert = require("node:assert");
const path = require("node:path");

const root = path.join(__dirname, "..");
const pkgForExpectations = require(path.join(root, "package.json"));

// Two modes, chosen by whether the caller pins expectations:
//
//   - regenerate.yml sets EXPECTED_* from the resolved pins, so this asserts
//     the build produced exactly the versions that were requested.
//   - ci.yml sets nothing, so the expectations default to package.json itself
//     and the checks assert INTERNAL consistency (package version ==
//     parameterization version, correct registry URL, decodable block). No
//     hardcoded version here — a hardcoded default would go stale on the first
//     provider bump and fail every ci.yml run after it.
const EXPECTED_BRIDGE_VERSION =
  process.env.EXPECTED_BRIDGE_VERSION || pkgForExpectations.pulumi?.version;
const EXPECTED_PROVIDER_VERSION =
  process.env.EXPECTED_PROVIDER_VERSION ||
  pkgForExpectations.pulumi?.parameterization?.version;
const EXPECTED_REMOTE_URL = "registry.opentofu.org/flagsmith/flagsmith";
const failures = [];
const check = (name, fn) => {
  try {
    fn();
    console.log(`  ok   ${name}`);
  } catch (err) {
    failures.push(`${name}: ${err.message}`);
    console.log(`  FAIL ${name}`);
  }
};

console.log(`Loading ${require(path.join(root, "package.json")).name} from committed build output...`);
const pkg = require(path.join(root, "package.json"));
assert.strictEqual(pkg.main, "bin/index.js", "package.json main must point at bin/index.js");
const flagsmith = require(path.join(root, pkg.main));

console.log("\nResource + function export surface:");
// Every resource class the Flagsmith provider exposes, plus the Provider.
const RESOURCE_EXPORTS = [
  "Provider",
  "Project",
  "Environment",
  "Feature",
  "FeatureState",
  "Segment",
  "MvFeatureOption",
  "Tag",
];
for (const name of RESOURCE_EXPORTS) {
  check(`exports ${name} as a constructor`, () => {
    const value = flagsmith[name];
    assert.ok(value !== undefined && value !== null, `${name} is not exported`);
    assert.strictEqual(typeof value, "function", `${name} is ${typeof value}, expected a class`);
    // Pulumi resource classes carry an isInstance type guard; Provider included.
    assert.strictEqual(
      typeof value.isInstance,
      "function",
      `${name} has no isInstance — it may not be a Pulumi resource class`,
    );
  });
}

const FUNCTION_EXPORTS = ["getOrganisation", "getOrganisationOutput", "getUser", "getUserOutput"];
for (const name of FUNCTION_EXPORTS) {
  check(`exports ${name}()`, () => {
    assert.strictEqual(typeof flagsmith[name], "function", `${name} is not a function`);
  });
}

check("exports the config and types sub-modules", () => {
  assert.ok(flagsmith.config, "config sub-module missing");
  assert.ok(flagsmith.types, "types sub-module missing");
});

console.log("\nFeature / FeatureState are distinct classes (the codegen collision):");
check("Feature and FeatureState are not the same class", () => {
  assert.notStrictEqual(
    flagsmith.Feature,
    flagsmith.FeatureState,
    "Feature and FeatureState resolved to the same value — the patch may have " +
      "aliased the resource class instead of the state interface",
  );
});

console.log("\nVersion resolution (proves bin/package.json was stamped):");
check("getVersion() resolves from bin/package.json", () => {
  // utilities.getVersion() does require('./package.json') relative to bin/.
  const binPkg = require(path.join(root, "bin", "package.json"));
  assert.strictEqual(
    binPkg.version,
    pkg.version,
    `bin/package.json version ${binPkg.version} != package.json version ${pkg.version}`,
  );
  const utilities = require(path.join(root, "bin", "utilities.js"));
  assert.strictEqual(utilities.getVersion(), pkg.version);
});

console.log("\nNo install-time lifecycle scripts (git-dependency safety):");
for (const hook of ["postinstall", "prepare", "prepublish", "prepack", "install"]) {
  check(`package.json has no "${hook}" script`, () => {
    assert.strictEqual(
      pkg.scripts?.[hook],
      undefined,
      `${hook} is defined; a git dependency must install with zero lifecycle scripts`,
    );
  });
}

console.log("\nPulumi parameterization block:");
check("pulumi block is present and marks a resource plugin", () => {
  assert.ok(pkg.pulumi, "package.json has no pulumi block");
  assert.strictEqual(pkg.pulumi.resource, true);
});
check(`bridge plugin is terraform-provider ${EXPECTED_BRIDGE_VERSION}`, () => {
  assert.strictEqual(pkg.pulumi.name, "terraform-provider");
  assert.strictEqual(pkg.pulumi.version, EXPECTED_BRIDGE_VERSION);
});
check(`parameterization targets flagsmith ${EXPECTED_PROVIDER_VERSION}`, () => {
  const par = pkg.pulumi.parameterization;
  assert.ok(par, "pulumi.parameterization missing");
  assert.strictEqual(par.name, "flagsmith");
  assert.strictEqual(par.version, EXPECTED_PROVIDER_VERSION);
});
check(`parameterization value decodes to ${EXPECTED_REMOTE_URL}`, () => {
  const decoded = JSON.parse(
    Buffer.from(pkg.pulumi.parameterization.value, "base64").toString("utf8"),
  );
  assert.strictEqual(decoded.remote.url, EXPECTED_REMOTE_URL);
  assert.strictEqual(decoded.remote.version, EXPECTED_PROVIDER_VERSION);
});
check("package version equals the provider version", () => {
  assert.strictEqual(pkg.version, EXPECTED_PROVIDER_VERSION);
});

console.log("");
if (failures.length > 0) {
  console.error(`smoke-test: ${failures.length} check(s) FAILED:`);
  for (const f of failures) console.error(`  - ${f}`);
  process.exit(1);
}
console.log("smoke-test: all checks passed.");
