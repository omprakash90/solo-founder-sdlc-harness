# Harness AI Development

A reusable Claude Code pipeline for building software with a team of
specialist agents instead of one generalist agent. Extracted from a
real project (Doot) where it was first used end-to-end, stripped of
that project's business content so it can be copied into any new repo.

Read [`docs/philosophy.md`](docs/philosophy.md) for the full reasoning —
the mental model, the seven roles, the non-negotiables, and the honest
limits. This README is just the install/usage guide.

## What's in here

```
harness-ai-dev/
├── .claude/
│   ├── agents/        8 specialist agent definitions
│   └── skills/
│       ├── groom-epic/   the THINKING pipeline
│       └── ship-epic/    the BUILDING pipeline
├── templates/          blank doc templates (CLAUDE.md, PRD, TRD, ADR, ...)
└── docs/philosophy.md  why this is shaped the way it is
```

## The seven roles

| Agent              | Phase   | Produces                              |
| ------------------ | ------- | -------------------------------------- |
| `grill-me`          | groom   | shared understanding (interview)      |
| `product-manager`   | groom   | PRD                                    |
| `architect`         | groom   | TRD                                    |
| `ui-designer`       | groom   | React/Tailwind preview                |
| `kanban-generator`  | groom   | GitHub Issues (vertical task slices)  |
| `implementer`       | ship    | working code, one task at a time      |
| `qa-engineer`       | ship    | tests against the PRD's AC            |
| `code-reviewer`     | ship    | BLOCKER / SHOULD-FIX / NIT findings   |

## The two-skill pipeline

```
/groom-epic <slug>   grill-me → PRD + TRD + designs (parallel) → GitHub Issues
/ship-epic <slug>    implement → QA → review → staging → merge
```

Both skills stop at every phase boundary and wait for your explicit
confirmation — nothing auto-chains. See the SKILL.md files for the
exact phase-by-phase flow.

## Installing into a new project

1. Copy `.claude/agents/` and `.claude/skills/` into your project's
   `.claude/` directory.
2. Copy `.claude/settings.json` in too (or merge it with your existing
   one) — it adds the main-branch edit guard, a post-edit
   lint+typecheck hook, and a session audit log. **Edit the
   `PostToolUse` command to your project's actual lint/typecheck
   commands** — it ships with `pnpm lint`/`pnpm tsc` as a placeholder.
3. Copy the templates you need from `templates/` into your project's
   `docs/` directory and fill them in for real:
   - `CLAUDE.md.template` → `CLAUDE.md` (project root)
   - `product-outline.md.template` → `docs/product-outline.md`
   - `architecture.md.template` → `docs/architecture.md`
   - `backlog.md.template` → `docs/epics/backlog.md`
   - `adr.md.template` → copy per-decision into `docs/decisions/`
   - `prd.md.template`, `trd.md.template`, `release-notes.md.template`
     are used by the agents automatically — you don't fill these in by
     hand, they're just here so you know the shape the agents produce.
4. Fill in `CLAUDE.md` with your actual stack, repo structure, and
   package/module boundary rules — every agent reads this file first.
   The agent files reference "this project's actual repo layout / see
   CLAUDE.md" rather than hardcoding paths, so this is the one file
   that makes the whole pipeline project-specific.
5. Write `docs/product-outline.md` (~10 lines) and at least the first
   pass of `docs/architecture.md` before running `/groom-epic` on your
   first epic — `grill-me` and `architect` both read these first and
   will ask worse questions without them.
6. Add rows to `docs/epics/backlog.md` for your planned epics.
7. Run `/groom-epic <slug>` on your first epic.

## What this is not (yet)

This is a reference template repo, not a scaffolding CLI. There's no
`npx create-harness` — you copy the files in by hand and adapt
`CLAUDE.md` to your project. A CLI that automates step 1–6 above is a
plausible future addition but isn't built here.

## Requirements

- Claude Code (agents + skills + hooks support).
- GitHub (the kanban-generator, implementer, qa-engineer, and
  code-reviewer agents use `mcp__github__*` tools against GitHub
  Issues/Projects as the board).
- Whatever stack your project actually uses — the pipeline is
  language/framework-agnostic; only `CLAUDE.md` needs filling in.
</content>
