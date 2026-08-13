// Copy package.json into bin/ after compilation.
//
// This is NOT bookkeeping — it is load-bearing. The generated `utilities.ts`
// implements getVersion() as:
//
//     let version = require('./package.json').version;
//
// After compilation that lives at bin/utilities.js, so `./package.json`
// resolves to bin/package.json, not the repo root's. Every resource in the SDK
// calls getVersion() through resourceOptsDefaults(), so without this file the
// package throws MODULE_NOT_FOUND the moment a consumer constructs anything.
//
// Pulumi's generated postinstall did this copy as its last step. This repo
// removes the postinstall (a git dependency must install with zero lifecycle
// scripts) and commits bin/ instead, so the copy moves into the build.
const fs = require("node:fs");
const path = require("node:path");

const root = path.join(__dirname, "..");
const src = path.join(root, "package.json");
const binDir = path.join(root, "bin");
const dest = path.join(binDir, "package.json");

if (!fs.existsSync(binDir)) {
  console.error(
    "stamp-bin-package: bin/ does not exist — run `tsc` first (npm run build does both).",
  );
  process.exit(1);
}

fs.copyFileSync(src, dest);

// Fail loudly rather than shipping a package that throws at construction time.
const version = JSON.parse(fs.readFileSync(dest, "utf8")).version;
if (!version) {
  console.error("stamp-bin-package: bin/package.json has no version field.");
  process.exit(1);
}

console.log(`stamp-bin-package: wrote bin/package.json (version ${version}).`);
