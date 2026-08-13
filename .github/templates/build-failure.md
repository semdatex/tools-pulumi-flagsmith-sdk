# BUILD FAILING — do not merge, do not tag

This branch was produced by the Regenerate SDK workflow, and **the build gate did
not pass**. It is opened as a draft so the breakage is visible and reproducible
rather than buried in an expired workflow log.

`tag.yml` refuses to cut a tag from any commit containing this file, and `ci.yml`
fails while it is present — so even a merge cannot turn this into a release.

| | |
|---|---|
| Failed stage | ${FAILED_STAGE} |
| Provider | `${PROVIDER}` |
| Bridge | `${BRIDGE}` |
| Pulumi CLI | `${PULUMI_CLI}` |
| Workflow run | ${RUN_URL} |

## Most likely cause

Upstream codegen drift. `scripts/patch-sdk.sh` works around a Pulumi
nodejs-codegen collision (the provider defines both `flagsmith_feature` and
`flagsmith_feature_state`, so `index.ts` exports `FeatureState` twice). It
deliberately refuses to guess when the generated shape stops matching what it
expects — see that script's header, and `docs/upstream-issue.md`.

## To resolve

1. Reproduce locally: `scripts/regenerate.sh ${PROVIDER} ${BRIDGE}`
2. Fix the tooling (usually `patch-sdk.sh`) on this branch.
3. Push. `ci.yml` runs on a human push and will report the real result.
4. Delete this file, remove the `build-failing` label, mark ready for review.

## Captured gate output

```
${GATE_OUTPUT}
```
