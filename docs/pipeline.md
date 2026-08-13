# How the pipeline works, and why

The workflows in `.github/workflows/` are deliberately thin: they wire steps
together, and the logic lives in `scripts/` where it is readable, shellcheck-able
and runnable on a laptop. This document holds the reasoning that would otherwise
bloat the workflow headers.

## The shape

```
weekly cron ─▶ upstream newer than pins.yml? ── no ─▶ exit quietly
                       │ yes                    (lookup failure = HARD FAIL,
                       ▼                         never "nothing to do")
       regenerate + run scripts/gate.sh INLINE
                       ▼
   open ONE PR: the pins bump AND the built SDK together
                       ▼
   human reviews and merges ─▶ CI passes on main ─▶ tag.yml cuts the tag
```

CI has **no write access to `main`** and holds **no secrets**. It pushes only its
own `propose/*` branches, and every release passes through a human merge.

## Why the gate runs before the PR exists

GitHub does not start workflows for events caused by the default
`GITHUB_TOKEN`. So `ci.yml` will never run on a PR that the proposing workflow
opens — waiting for it would deadlock.

Running the gate *inside* the proposing job is the stronger position anyway: a
PR carrying a broken SDK is never created as a mergeable proposal. The cost is
that the result would be invisible outside the run log, which is why the job
stamps it on the PR head commit as the **`regenerate-gate` commit status** —
reporting a status is permitted with `GITHUB_TOKEN`; only *triggering workflows*
is not.

For an independent re-run on a fresh runner, **close and reopen the PR**: a human
reopening does trigger `ci.yml`.

`regenerate-gate` is deliberately **not** a required status check — only the
proposing workflow reports that context, so requiring it would deadlock ordinary
human PRs that never receive it.

## Why one gate, in a script

`scripts/gate.sh` is the single definition of "the SDK is good", run by both
`ci.yml` and the proposing job. Two copies would drift — they already had, before
this was consolidated (one used `npm ci`, the other `npm install`).

Two switches keep the single definition honest:

- `--install ci|install` — the regenerate flow needs a plain `install`, because
  codegen has just rewritten `package.json` and the committed lockfile is
  *legitimately* stale. `npm ci` would correctly refuse.
- `--check-bin` — deletes `bin/` and rebuilds it from nothing. Only meaningful
  where `bin/` is supposed to already be correct (`ci.yml`); the regenerate flow
  omits it because a changed `bin/` is the entire point there.

The delete-then-rebuild matters: `git diff -- bin` only compares **tracked**
content, so it is blind in both directions — a new source whose compiled output
was never committed (output appears untracked, diff silent), and a deleted source
whose stale output lingers (nothing changed, diff silent). Rebuilding from
nothing and asking `git status --porcelain` catches both.

## Why tags chain off CI

`tag.yml` triggers on `workflow_run` (CI completing), not on push. Both firing on
push would race, and `tag.yml` runs no build of its own — so a merge that broke
the build in a way the failure marker does not capture could receive an immutable
tag seconds later. Immutable is exactly what makes that expensive.

It tags `workflow_run.head_sha` — the commit CI actually verified — rather than
whatever `main` has become in the meantime. Overlapping runs converge because
`next-tag.sh` refuses to cut a second tag for identical SDK content.

That content hash is a **deny-list**, so newly generated files are covered
automatically. `pins.yml` is excluded on purpose: it is the declaration, not the
artifact, and a comment-only edit there must not mint a new tag around
byte-identical SDK content.

> `workflow_run` resolves against the workflow file on the **default branch**, so
> this trigger only becomes active once merged to `main` — which is also the only
> place tags are cut from.

## Why a failing build still opens a PR

The likeliest failure is upstream codegen drift that `patch-sdk.sh` refuses to
guess at. A red cron run is an email nobody reads; a visible PR carries its own
reproduction and becomes a work item.

Such a proposal is marked four ways, and each independently prevents a release:

| Marker | Effect |
|---|---|
| Opened as a **draft** | Not mergeable without a deliberate "ready for review" |
| `regenerate-gate` status **failing** | Red row in the merge box |
| **`build-failing`** label | Machine-readable state (created on first use — labels are not IaC-managed) |
| **`BUILD-FAILURE.md`** committed | `ci.yml` fails while present; `tag.yml` refuses to tag |

Plus the fifth, structural one: tags require a green CI run on `main` in the first
place.

`BUILD-FAILURE.md` is **committed to the branch**, not merely written into the PR
body, because Actions logs expire and a blocked proposal may sit for months
waiting on upstream. It records the failing stage, the versions attempted, the
captured gate output and the resolution steps — which is also exactly the context
a future automated fixer would need.

## Why the watcher fails loudly

`decide-build.sh` treats an empty upstream release lookup, with no explicit
`provider_version`, as a **hard error**. A watchdog whose failure mode is
"green, nothing to do" is not a watchdog: an API outage, an upstream rename and
"you are up to date" would otherwise be indistinguishable.

`force` still works when the lookup fails, because it targets the *declared* pin
rather than the latest release — the API is only consulted when its answer is
actually needed.

## Why closed proposals are not re-proposed

One proposal per version pair. An **open** PR means a human has not dealt with the
previous one. A **closed or merged** one records an explicit human decision that a
Monday cron must not overrule — only `force` (with an explicit `provider_version`)
may.

## Why the proposal branch is force-pushed

The branch name is deterministic (`propose/provider-X-bridge-Y`), so a leftover
remote branch from a closed proposal would wedge a plain push forever — every
week, silently, with no PR opened. Force is safe precisely because the decide step
has already established that no open PR points at that branch: anything on it is
stale by definition.

## Scripts

| Script | Responsibility |
|---|---|
| `gate.sh` | The single definition of "good". Run by CI and by the proposing job. |
| `decide-build.sh` | What to build, and whether to bother. Read-only; run it locally to preview the next cron. |
| `install-pulumi.sh` | Install the CLI at the pinned version, and prove the pin took. |
| `write-pins.sh` | Write all three pins, verified through `read-pins.sh`. |
| `regenerate.sh` | Pin the bridge, run codegen, sync the generated surface, then patch + repackage. |
| `patch-sdk.sh` | The upstream codegen-collision workaround. **Delete when upstream fixes it.** |
| `repackage.sh` | Re-apply packaging deviations; assert the parameterization block. |
| `evaluate-gate.sh` | Collapse step outcomes into a verdict; write `BUILD-FAILURE.md` on failure. |
| `open-proposal.sh` | Commit to the proposal branch and open/refresh its PR. |
| `stamp-status.sh` | Report the gate verdict as a commit status. |
| `next-tag.sh` | Compute the next tag, or decline. Run it locally to see what would be cut. |
| `read-pins.sh` | Read and validate `pins.yml`. Strict — an empty pin fails rather than defaulting. |
| `render-template.sh` | Fill `${VAR}` placeholders in `.github/templates/*.md`. |

PR bodies and `BUILD-FAILURE.md` live in `.github/templates/` as markdown, so they
can be edited and previewed as markdown rather than as heredocs nested inside bash
inside YAML.
