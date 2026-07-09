---
name: groom-epic
description: The planning pipeline for one epic. Runs grooming → PRD + TRD + designs (parallel) → human review → GitHub Issues. Use before /ship-epic. Run with: /groom-epic <slug>
---

Epic slug: $ARGUMENTS

This is the THINKING command. It produces shared understanding, documents,
and a GitHub Kanban board. No code is written here.
Run /ship-epic <slug> after this completes to start building.

STOP between every phase. Wait for explicit user confirmation.
Never auto-chain phases.

---

## Phase 1 — Grooming session

Invoke @grill-me for $ARGUMENTS.

The grill-me agent will:

- Read the backlog, architecture, existing code
- Ask one question at a time with a recommendation
- Walk the product tree then the technical tree
- Track its own understanding gaps
- Propose closure when all branches are resolved

You answer each question in the terminal.

STOP when grill-me outputs "GROOMING COMPLETE" summary.

Review the summary. Correct anything wrong.
Say "confirmed" to continue.

---

## Phase 2 — Generate documents (parallel)

On "confirmed", invoke these THREE agents simultaneously:

**@product-manager** for $ARGUMENTS:
  Reads the grooming summary → writes docs/prds/$ARGUMENTS.md

**@architect** for $ARGUMENTS:
  Reads the grooming summary + PRD → writes docs/trds/$ARGUMENTS.md

**@ui-designer** for $ARGUMENTS:
  Reads the grooming summary + PRD → proposes screen list →
  waits for your confirmation → builds screens →
  reports preview URL at localhost:3000/_design/$ARGUMENTS →
  iterates from your feedback

You will be talking to all three in parallel:

- Architect may ask ≤3 targeted technical questions
- Designer will ask you to confirm the screen list
- Answer both as they come in

STOP when all three are done:

- docs/prds/$ARGUMENTS.md exists
- docs/trds/$ARGUMENTS.md exists
- docs/designs/$ARGUMENTS/README.md exists (designer approved)

Tell the user:
"Three documents are ready. Review them:

- docs/prds/$ARGUMENTS.md
- docs/trds/$ARGUMENTS.md
- docs/designs/$ARGUMENTS/

Edit anything that is wrong.
Say 'create issues' when you are satisfied."

STOP. Wait.

---

## Phase 3 — Create GitHub Issues

On "create issues", invoke @kanban-generator for $ARGUMENTS.

The kanban-generator will:

- Create the epic:E0N label on GitHub (if missing)
- Create the E0N milestone on GitHub (if missing)
- Generate vertical task breakdown from PRD + TRD
- Create one parent epic issue
- Create one issue per task with mini-spec, AC, dependencies,
  label, and milestone

STOP when kanban-generator outputs the summary table.

Tell the user:
"Board is live. Issues created for epic $ARGUMENTS.
When you are ready to build, run: /ship-epic $ARGUMENTS"

---

## Notes

- You can run /groom-epic on multiple epics before running /ship-epic
  on any of them. Groom ahead, build in order.
- The three documents (PRD, TRD, designs) are version-controlled.
  They are the source of truth — GitHub Issues are generated from them.
  If you edit an issue, also edit the source document.
- If the grooming reveals the epic is too large (> 15 tasks estimated),
  the kanban-generator will flag it. Split the epic in backlog.md
  before continuing.
</content>
