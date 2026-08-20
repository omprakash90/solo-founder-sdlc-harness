---
name: ship-epic
description: The execution pipeline for one epic. Picks tasks from the GitHub Kanban board, implements them, tests, reviews, deploys to staging, merges. Run after /groom-epic <slug> has completed. Use: /ship-epic <slug> or /ship-epic <slug> --qa to jump straight to QA.
---

Epic slug: $ARGUMENTS

This is the BUILDING command. It requires /groom-epic $ARGUMENTS to have
been run first — PRD, TRD, designs, and GitHub Issues must all exist.

STOP at every checkpoint. Wait for explicit user confirmation.
Never auto-chain phases unless stated.

---

## Preflight check

Before starting, verify all inputs exist:

- [ ] docs/prds/$ARGUMENTS.md
- [ ] docs/trds/$ARGUMENTS.md
- [ ] GitHub Issues with label epic:E0N and milestone E0N exist
- [ ] Branch feat/$ARGUMENTS exists (or create it now)

If any are missing: stop and tell the user what is missing.
Do not proceed until all inputs are present.

If `--qa` flag passed: skip to Phase 3 (QA).

---

## Phase 1 — Implementation loop

Invoke @implementer for $ARGUMENTS.

The implementer will loop autonomously:

1. Check for In Progress issues → resume if found
2. Pick next Todo task (topmost, unblocked, label + milestone scoped)
3. Move issue to In Progress
4. Read epic TRD + task mini-spec
5. Implement vertical slice (migration → core → API → UI)
6. Write tests (unit + e2e)
7. Lint + typecheck
8. Commit with issue number
9. Move issue to In Review
10. Repeat

The implementer runs until all tasks are In Review, then stops and
tells you: "All tasks In Review."

During this phase you may:

- Watch the terminal to see progress
- Answer any stop-condition questions the implementer surfaces
- Do other things — the implementer works autonomously between stops

STOP when implementer reports all tasks In Review.

Tell the user:
"All tasks are In Review. Review the diff in your source control tool.
Run through the manual test checklist the implementer posted on
the epic issue. Say 'qa' when ready."

STOP. Wait.

---

## Phase 2 — QA pass

On "qa", invoke @qa-engineer for $ARGUMENTS.

The QA agent will:

- Test every AC: happy path + failure path + edge case
- Capture visual diffs against docs/designs/$ARGUMENTS/
- Produce the full pass/fail + visual diff table

STOP when QA report is complete.

If any FAIL:
Tell user: "QA failing on: [list of failed ACs and visual diffs].
Options: (1) fix the code — say 'fix', (2) update the PRD AC —
say 'update AC-N to: <new wording>', (3) accept the gap —
say 'accept [AC-N]' with a reason."
STOP. Wait for user decision.

On "fix": invoke @implementer with the specific failures.
Re-run QA after fix. Repeat until clean.
On "update AC-N": update docs/prds/$ARGUMENTS.md, re-run QA.
On "accept": note the accepted gap in the release notes.

On all PASS:
Tell user: "QA passing. Say 'review' to continue."
STOP. Wait.

---

## Phase 3 — Code review

On "review", invoke @code-reviewer for $ARGUMENTS.

The reviewer will produce: BLOCKER / SHOULD-FIX / NIT findings.

If BLOCKERs exist:
Invoke @implementer with the specific BLOCKER list.
Re-invoke @code-reviewer after fix.
Repeat until reviewer outputs "BLOCKER: none."

On "BLOCKER: none":
Tell user: "No blockers. Branch is clean. Say 'stage' to deploy
to staging."
STOP. Wait.

---

## Phase 4 — Staging

On "stage":

First push the branch: `git push origin feat/$ARGUMENTS`, then open the PR
if one doesn't exist yet (`gh pr create`).

Check whether this project has an automated dev-deploy path: look for a
`deploy-dev.yml` (or similarly named) GitHub Actions workflow in the
repo(s) this epic touched, and a documented staging/dev deploy command in
`docs/architecture.md` or `CLAUDE.md`.

**If an automated `deploy-dev.yml`-style workflow exists:**
Tell the user:
"PR is open: <PR URL>. Say 'deploy' to push this to the dev environment
for validation, or deploy manually yourself."
STOP. Wait.

On "deploy": run `gh workflow run deploy-dev.yml --repo <owner/repo> -f
tag=pr-<n> -f pr_url=<PR URL>` for each affected repo (substitute the
project's actual workflow inputs if they differ — read the workflow file
first rather than assuming). Report the triggered run URL(s) and tell the
user E2E results (if the project wires them up) and any other evidence
will land wherever the project's CI is configured to send them (e.g.
Slack) — check `docs/architecture.md` for where. Then continue to
verification below.

**If no automated dev-deploy workflow exists**, fall back to the manual
path — tell the user:

"Deploy to staging now:
<this project's deploy command — see docs/architecture.md>

Staging URL: <this project's preview URL for this branch>"

**Either way**, once deployed:

"Verify on staging/dev:

- Walk through the manual test checklist on the epic issue
- Check each screen matches the approved designs
- Test on mobile (375px) and desktop (1280px)
- If automated E2E/evidence was posted (e.g. to Slack), review it too

Say 'ship' when it looks good.
Say 'fix: <what is wrong>' if you find an issue."

STOP. Wait.

On "fix: <issue>":
Invoke @implementer with the specific staging issue.
Redeploy to staging. Tell user to re-verify.
STOP. Wait.

On "ship": continue to Phase 5.

---

## Phase 5 — Merge and release

On "ship":

1. Tell user to merge the PR:
   "Merge feat/$ARGUMENTS → main
    (e.g.: gh pr merge feat/$ARGUMENTS --squash --delete-branch)
   Then say 'merged'."
   If the repo has a `deploy-prod.yml`-style workflow triggered on push
   to main, mention it: "Merging will automatically deploy to production
   — no separate deploy step needed."
   STOP. Wait for "merged".

2. On "merged", write docs/releases/<YYYY-MM-DD>-$ARGUMENTS.md:

```markdown
# Release: <Epic title>

Date: <today>
Epic: E0N — $ARGUMENTS
PR: #<number>

## What shipped

<One paragraph in plain English. What can users do now that
they couldn't before? Written for a non-technical reader.>

## Acceptance criteria delivered

- AC-1: ...
- AC-2: ...
  [copy from PRD, mark any accepted gaps]

## Accepted gaps

<List any ACs accepted as known gaps, with reason. If none: "None.">

## Manual smoke test

1. <step>
2. <step>
3. <step>

## Follow-up issues filed

<Any SHOULD-FIX items from the review that were filed as
GitHub issues rather than fixed in this PR. If none: "None.">
```

3. Update docs/epics/backlog.md — set status to `shipped`.

4. Close the parent epic GitHub Issue.

5. Tell the user:
   "Epic $ARGUMENTS shipped.
   Next epic: <next todo row from backlog.md>
   Run: /groom-epic <next-slug>"

---

## Notes

- One epic at a time in /ship-epic. You can /groom-epic multiple
  epics ahead, but ship them in backlog order.
- The implementer picks tasks in order within the epic. You do not
  need to manage the task queue — it is handled by the label +
  milestone + dependency logic.
- If the implementer gets stuck mid-task and you end the session,
  the issue stays In Progress. Next session, /ship-epic will resume
  from that task automatically.
- Cost watch: a full epic run typically costs a few dollars. If a
  session costs far more than similar epics, something is looping —
  stop, read .claude/session.log, find the loop, tighten the
  relevant agent prompt.
</content>
