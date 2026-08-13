# Draft upstream issue — NOT FILED

> [!WARNING]
> **This has not been submitted to any upstream project, and must not be filed
> without explicit human approval.** It is a prepared draft only.
>
> Suggested target: [`pulumi/pulumi-terraform-bridge`](https://github.com/pulumi/pulumi-terraform-bridge/issues).
> Maintainers may redirect it to [`pulumi/pulumi`](https://github.com/pulumi/pulumi/issues),
> since the emission happens in the Node.js SDK generator (`pkg/codegen/nodejs`)
> rather than in the bridge itself. The bridge is the right place to *start*
> because the collision is only reachable through a bridged Terraform provider's
> resource naming.
>
> Before filing, re-check whether it is already fixed or reported — the
> workaround (`scripts/patch-sdk.sh`) is written to no-op the moment codegen
> stops producing the collision.

---

**Title:** Node.js codegen emits a duplicate `FeatureState` export when a provider has both `<x>` and `<x>_state` resources

### What happened

Generating a Node.js SDK for the Flagsmith Terraform provider produces an
`index.ts` that does not compile:

```
index.ts: error TS2323: Cannot redeclare exported variable 'FeatureState'.
index.ts: error TS2484: Export declaration conflicts with exported declaration of 'FeatureState'.
```

### Why

Pulumi emits a `<Name>State` interface for every resource — the type accepted by
`get()` / import. The Flagsmith provider defines two resources whose Pulumi names
collide under that convention:

| Terraform resource | Pulumi class | Generated state interface |
|---|---|---|
| `flagsmith_feature` | `Feature` | `FeatureState` |
| `flagsmith_feature_state` | `FeatureState` | `FeatureStateState` |

So `FeatureState` is emitted twice in `index.ts` — once as `Feature`'s state
interface, re-exported from `./feature`, and once as the `FeatureState` resource
class declared from `./featureState`:

```ts
export { FeatureArgs, FeatureState } from "./feature";              // <- state interface
export type FeatureState = import("./featureState").FeatureState;
export const FeatureState: typeof import("./featureState").FeatureState = null as any;  // <- resource class
```

The generator has no collision detection between the `<Name>State` interface
namespace and the resource-class namespace, so any provider containing both
`<x>` and `<x>_state` hits this. Flagsmith is simply the case we ran into;
nothing about it is special.

### Reproduction

```bash
pulumi package gen-sdk terraform-provider Flagsmith/flagsmith 0.10.0 \
  --language nodejs --local --out ./out
cd ./out            # (path may be ./out or ./out/nodejs depending on CLI version)
npm install && npx tsc
```

Versions used:

- Bridge plugin `terraform-provider` **1.3.0**
- Provider `registry.opentofu.org/flagsmith/flagsmith` **0.10.0**

### Expected

The generated SDK compiles as generated. Codegen should detect that a
`<Name>State` interface collides with a resource class of the same name and
disambiguate one of them — for example by emitting the state interface under a
non-colliding name when a resource of that name exists.

### Impact

The generated SDK is unusable without a manual edit. For a *dynamically bridged*
provider this is worse than for a published one, because Pulumi's prescribed
model is to generate the SDK locally and commit it into the consuming repo — so
every consumer of the provider has to discover and re-apply the same fix, on
every regeneration.

### Workaround

Alias the *interface* on the `./feature` re-export line only:

```ts
export { FeatureArgs, FeatureState as FeatureResourceState } from "./feature";
```

The resource class keeps its name and its provider mapping, so no runtime
behaviour changes — only a type that consuming programs generally never
reference is renamed. Restricting the edit to lines importing from `./feature`
keeps it from touching the resource export.

We apply this automatically after every regeneration:
[`scripts/patch-sdk.sh`](../scripts/patch-sdk.sh). It is idempotent, no-ops if
the collision is absent (so it self-retires when this is fixed), and fails loudly
if the generated shape stops matching what it expects.
