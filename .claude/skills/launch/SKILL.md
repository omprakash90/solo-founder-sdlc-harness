---
name: launch
description: The go-live pipeline. Once every epic inside the MVP boundary is shipped, compiles a release rollup and a launch-readiness checklist for the founder to run. Run after the MVP epics are shipped via /ship-epic. Use with: /launch
---

This is the final command in the harness for a product's MVP. It runs after
every epic inside the MVP boundary (in docs/epics/backlog.md) has been shipped
via /ship-epic. It produces the launch artifact — a rollup of what shipped plus
a readiness checklist. Nothing auto-deploys; going live is a human decision.

STOP at the readiness gate. Wait for the founder.

---

## Preflight — is the MVP complete?

1. Read docs/epics/backlog.md. Identify every epic inside the MVP boundary.
2. Check the Status of each MVP epic.

- If any MVP epic is NOT `shipped`: stop. Tell the user exactly which epics
  remain and their status. Do not proceed.
  "Cannot launch yet — these MVP epics are not shipped: [list].
  Finish them with /groom-epic + /ship-epic, then run /launch again."
- If on `main`, create and switch to `chore/launch` before writing
  (`git checkout -b chore/launch`) — the repo blocks writes on main.

Only proceed when every MVP-boundary epic is `shipped`.

---

## Phase 1 — Compile the launch artifact

Invoke @launch-manager for the product.

The launch-manager will:

- Read docs/product-outline.md (success metric, monetization, biggest risk)
- Read every docs/releases/<date>-<slug>.md for the MVP epics
- Roll up what shipped and every accepted gap
- Write docs/releases/launch-<YYYY-MM-DD>.md with a readiness checklist

STOP when the launch doc exists.

---

## Phase 2 — Readiness gate (human go/no-go)

Tell the user:
"docs/releases/launch-<date>.md is ready. It rolls up every MVP epic and gives
you a launch-readiness checklist. This is a human go/no-go gate — nothing
auto-ships.

Work the checklist:
- Smoke-test the full core loop on production
- Confirm rollback works
- Confirm the success metric is instrumented so you'll know if launch worked
- Draft the announcement for your beachhead channel

When every box is checked and you're satisfied, you launch. There is no further
command — the harness's job ends at the checklist; the go-live is yours."

STOP.

---

## Notes

- The MVP boundary is defined by the epic-planner in docs/epics/backlog.md.
  If you want to launch a narrower set than the recorded MVP, edit the boundary
  in backlog.md first (deliberately), then re-run /launch.
- Post-MVP epics stay in the backlog. After launch, resume the normal loop:
  /groom-epic <next-slug> → /ship-epic <next-slug>. There is no need to re-run
  /discover unless the product thesis itself changes.
- launch-manager compiles; it never deploys. Every action item is one the
  founder executes.
