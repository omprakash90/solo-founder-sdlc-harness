---
name: plan-product
description: Turns a confirmed product outline into the technical foundation and the epic backlog. Runs system-architect → architecture.md, then epic-planner → backlog.md with an MVP boundary. Run after /discover, before /groom-epic. Use with: /plan-product
---

This is the second thinking command. It requires /discover to have produced
docs/product-outline.md. It writes the product-wide architecture and slices the
product into a backlog of epics. No epic code is written here — the output is
the input to /groom-epic.

STOP between every phase. Wait for explicit user confirmation.
Never auto-chain phases.

---

## Preflight

Verify inputs and branch:

- [ ] docs/product-outline.md exists (run /discover first if not)
- [ ] If on `main`, create and switch to `chore/plan-product`
  (`git checkout -b chore/plan-product`) — the repo blocks writes on main.
      Tell the user which branch you are on.

If docs/product-outline.md is missing: stop and tell the user to run
/discover first.

---

## Phase 1 — Architecture (first pass)

Invoke @system-architect for the product.

The system-architect will:

- Read docs/product-outline.md
- Choose a stack right-sized for a solo founder shipping an MVP
- Possibly ask up to 3 targeted questions (answer them one at a time)
- Write docs/architecture.md (sections 1–6)

STOP when docs/architecture.md exists.

Tell the user:
"docs/architecture.md (first pass) is written. Every later agent treats this as
binding, so review and lock it now. Edit anything wrong, then say 'plan epics'."

STOP. Wait.

---

## Phase 2 — Epic backlog

On "plan epics", invoke @epic-planner for the product.

The epic-planner will:

- Read docs/product-outline.md + docs/architecture.md (+ validation memo)
- Slice the product into epics (each groomable into ≤ 15 tasks)
- Write docs/epics/backlog.md with build-order rationale and an MVP boundary

STOP when docs/epics/backlog.md exists.

Tell the user:
"docs/epics/backlog.md is written — the build order for the whole product, with
the MVP boundary marked. Review the slicing. When it looks right:

1. Commit this branch and open a PR to merge the inception docs to main
   (product-outline, architecture, backlog).
2. Start building the first epic: /groom-epic <first-slug>"

---

## Notes

- The three anchor docs (product-outline, architecture, backlog) are the
  contract the existing pipeline consumes — /groom-epic, grill-me, and architect
  all read them first. This command's whole job is to produce them from the
  outline so the founder never hand-writes them.
- Lock architecture.md before grooming epics. Per-epic TRDs (written later by
  the architect agent) work WITHIN it — architectural disagreements surface as
  Open Questions, they don't silently override it.
- The MVP boundary in backlog.md is what /launch later checks for completion.
- You run /plan-product once per product. Re-run only when the product outline
  changes materially.
