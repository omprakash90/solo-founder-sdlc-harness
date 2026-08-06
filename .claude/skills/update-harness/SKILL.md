---
name: update-harness
description: Sync the harness (.claude/, templates/) between this sdlc-harness checkout and the parent workspace directory that holds sibling product/service repos. Two modes — pull (harness → workspace, refresh agents/skills you use daily) and push (workspace → harness, land new agents/skills you built while working, then PR them upstream). Use with: /update-harness pull | /update-harness push
---

Mode: $ARGUMENTS

This skill only makes sense in **workspace mode**: this repo (`sdlc-harness`)
is the reusable, pushable source of truth for `.claude/agents`, `.claude/skills`,
and `templates/`. A parent directory (default: one level up from this repo)
is the actual working root — it holds sibling service repos plus a *copy* of
`.claude/`, `templates/`, and `CLAUDE.md` so a Claude Code session started
there can see every service without sibling-directory permission friction.

Because it's a copy, the two can drift. This skill is how you resync them in
either direction.

---

## Phase 0 — Determine mode and workspace

Parse `$ARGUMENTS`:
- First token must be `pull` or `push`. If missing or invalid, ask the user
  which direction they want (don't guess).
- Second token, if present, is an explicit workspace directory path.
  Otherwise the script defaults to `..` (one level up from this repo).

Confirm you're running from inside the harness checkout: `.claude/skills/update-harness`
should exist at `./.claude/skills/update-harness`. If not, stop and tell the
user to run this from the `sdlc-harness` repo root.

---

## Phase 1 — Pull (harness → workspace)

Run:

```bash
bash scripts/sync-workspace.sh pull
```

This is non-destructive to everything except `.claude/` and `templates/` in
the workspace — those two directories are treated as a mirror of the harness
and fully replaced on each pull (so deletions in the harness propagate too).
`CLAUDE.md` is seeded once from the template and never overwritten after
that — the workspace's filled-in `CLAUDE.md` (stack, multi-repo layout,
sibling service list) is workspace-specific and must never be pushed back
into this repo's generic template.

Report what changed. If nothing changed, say so.

---

## Phase 2 — Push (workspace → harness)

Run:

```bash
bash scripts/sync-workspace.sh push
```

The script diffs `<workspace>/.claude` against `./.claude`, shows the
differences, and asks for confirmation before copying anything back into
this repo. If the user built a new agent or skill while working in the
workspace (e.g. while shipping an epic in `autonom-api`), this is how it
lands in the harness.

After a successful push:

1. Run `git status` / `git diff` in this repo to review exactly what changed.
   Confirm nothing workspace/product-specific (business logic references,
   Autonom-specific paths, secrets) leaked into an agent or skill file —
   this repo is meant to stay generic and reusable for future products.
2. Create a branch: `feat/<short-description>` (never commit directly to
   `main` — the harness's own `PreToolUse` hook blocks this anyway).
3. Commit with a message describing the new/changed agent or skill and why.
4. Push the branch and open a PR against this repo's own `origin`
   (`gh pr create`). Do not push directly to `main`.

STOP after opening the PR — let the user review and merge it themselves.
Do not merge automatically.

---

## Notes

- This skill never touches sibling service repos (`autonom-agent`,
  `autonom-api`, etc.) — only `.claude/`, `templates/`, and (on first pull
  only) `CLAUDE.md`.
- If `push` finds no differences, say so and stop — don't create an empty
  branch or PR.
- If the user has uncommitted changes elsewhere in this repo, mention it
  before creating a new branch, but don't stash/discard anything without
  asking.
