---
name: discover
description: The inception pipeline for a solo founder. Turns a raw idea into a confirmed product outline. Runs idea intake → founder-grill interview → optional clarity/validation → product-outline.md. Run before /plan-product. Use with: /discover <slug>
---

Product slug: $ARGUMENTS

This is the FIRST thinking command in the harness — it runs BEFORE any epic
exists. It takes a raw idea and produces the product north star
(docs/product-outline.md). No code and no architecture are written here.
Run /plan-product after this completes.

STOP between every phase. Wait for explicit user confirmation.
Never auto-chain phases.

---

## Preflight — get off main

The repo blocks Edit/Write on the `main` branch (see .claude/settings.json).
The inception docs live on main eventually, but are written on a branch first.

- If the current branch is `main`, create and switch to `chore/discover` now:
  `git checkout -b chore/discover`
- Tell the user which branch you are on. The product-outline change merges to
  main via a small PR at the end (same discipline as feat/<slug> epics).

---

## Phase 0 — Idea intake

Check for docs/idea.md.

- If it does not exist: copy templates/idea.md.template to docs/idea.md, tell
  the user "Write your raw idea in docs/idea.md — a few paragraphs, no polish
  needed. Say 'ready' when done."
- If it exists but is still the empty template: same ask.
- If it has real content: summarise back what you read in 2–3 sentences and ask
  the user to confirm it captures the idea.

STOP. Wait for "ready" / confirmation.

---

## Phase 1 — Discovery session

Invoke @founder-grill for $ARGUMENTS.

The founder-grill agent will:

- Read docs/idea.md
- Ask one question at a time, each with a recommendation
- Walk the product/business tree (problem, beachhead user, core loop, wedge,
  monetization, biggest risk, v1 scope, why-now)
- Propose closure when all branches are resolved

You answer each question in the terminal.

STOP when founder-grill outputs the "DISCOVERY COMPLETE" summary.

Review it. Correct anything wrong. Then choose:
- say "validate" to pressure-test the risky assumptions first (Phase 2), or
- say "confirmed" to skip straight to writing the outline (Phase 3).

---

## Phase 2 — Clarity / validation (optional)

On "validate", invoke @idea-validator for $ARGUMENTS.

The idea-validator will run four bounded clarity steps — market scan,
competitor scan, riskiest-assumption test, monetization sketch — and write
docs/discovery/$ARGUMENTS-validation.md with a PROCEED / NARROW / TEST-FIRST
recommendation.

STOP when the memo is written.

Tell the user:
"Validation memo ready: docs/discovery/$ARGUMENTS-validation.md
Read the bottom line. Then say 'confirmed' to write the product outline, or
adjust the idea and re-run discovery if the evidence changed your thinking."

STOP. Wait.

---

## Phase 3 — Write the product outline

On "confirmed", invoke @product-strategist for $ARGUMENTS.

The product-strategist reads the confirmed discovery summary (+ validation memo
if it exists) and writes docs/product-outline.md — the ~10-line north star.

STOP when docs/product-outline.md exists.

Tell the user:
"Your product outline is written: docs/product-outline.md
This is your north star — every later agent reads it first. Edit anything that
is off. When it reads true, run: /plan-product"

---

## Notes

- docs/product-outline.md is the single most important document in the harness.
  It is the tiebreaker: if a later decision conflicts with it, the outline wins
  unless you deliberately update it.
- The validation step is optional but strongly recommended when the biggest
  risk is demand or distribution — cheaper to test an assumption now than to
  build a backlog against a false one.
- You run /discover once per product, not once per epic. Epic-level grooming is
  /groom-epic, which comes later.
