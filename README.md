# Solo-Founder SDLC Harness

A reusable Claude Code pipeline for taking a solo founder from a raw
idea all the way to a launched MVP, using a team of specialist agents
instead of one generalist agent. Extracted from a real project (Doot)
where the build pipeline was first used end-to-end, stripped of that
project's business content so it can be copied into any new repo.

The pipeline covers the full path — **idea → clarity → backlog →
shipped epics → launch** — as a sequence of small skills, each stopping
for your judgment at the points that matter. Nothing auto-chains; you
stay the orchestrator.

Read [`docs/philosophy.md`](docs/philosophy.md) for the full reasoning —
the mental model, the roles, the non-negotiables, and the honest limits.
This README is the what's-in-here + how-to-use guide.

## What's in here

```
solo-founder-sdlc-harness/
├── .claude/
│   ├── agents/        14 specialist agent definitions (one job each)
│   ├── skills/        5 pipeline commands (see below)
│   │   ├── discover/       inception: idea → product outline
│   │   ├── plan-product/   planning: outline → architecture + backlog
│   │   ├── groom-epic/     the THINKING pipeline (per epic)
│   │   ├── ship-epic/      the BUILDING pipeline (per epic)
│   │   └── launch/         go-live: rollup + readiness checklist
│   └── settings.json  hooks: main-branch guard, post-edit lint, audit log
├── templates/         blank doc templates (idea, CLAUDE.md, PRD, TRD, ...)
└── docs/philosophy.md why this is shaped the way it is
```

The whole thing is plain markdown + Claude Code config — no runtime, no
build step. The five skills are slash commands; the fourteen agents are
the specialists those skills delegate to.

## The roles

Inception + planning (whole product, run once):

| Agent                | Phase        | Produces                             |
| -------------------- | ------------ | ------------------------------------- |
| `founder-grill`      | discover     | product thesis (idea interview)      |
| `idea-validator`     | discover     | validation memo (opt-in)             |
| `product-strategist` | discover     | product-outline.md (north star)      |
| `system-architect`   | plan-product | architecture.md (first pass)         |
| `epic-planner`       | plan-product | backlog.md (epics + MVP boundary)    |

Per epic (loop through the backlog, once each):

| Agent                | Phase   | Produces                              |
| -------------------- | ------- | -------------------------------------- |
| `grill-me`           | groom   | shared understanding (interview)      |
| `product-manager`    | groom   | PRD                                    |
| `architect`          | groom   | TRD                                    |
| `ui-designer`        | groom   | React/Tailwind preview                |
| `kanban-generator`   | groom   | GitHub Issues (vertical task slices)  |
| `implementer`        | ship    | working code, one task at a time      |
| `qa-engineer`        | ship    | tests against the PRD's AC            |
| `code-reviewer`      | ship    | BLOCKER / SHOULD-FIX / NIT findings   |

Launch (run once, when the MVP epics are shipped):

| Agent                | Phase   | Produces                              |
| -------------------- | ------- | -------------------------------------- |
| `launch-manager`     | launch  | release rollup + readiness checklist  |

## The pipeline at a glance

```
docs/idea.md         you write a few raw paragraphs
/discover <slug>     founder-grill → (validate) → product-outline.md
/plan-product        system-architect → architecture.md; epic-planner → backlog.md
/groom-epic <slug>   grill-me → PRD + TRD + designs (parallel) → GitHub Issues
/ship-epic <slug>    implement → QA → review → staging → merge      (per epic)
/launch              rollup of shipped MVP epics + go-live checklist
```

`/discover` and `/plan-product` run once per product. `/groom-epic` and
`/ship-epic` run once per epic — loop through the backlog in order.
`/launch` runs once the MVP epics are shipped.

> This repo focuses on **solo-founder mode** — one person, maximum
> leverage, the AI proposes and you approve. A software-team mode
> (explicit role separation, assignment, heavier review gates) is a
> plausible future addition and is not built here.

## How to use it

Once the harness is installed in your project (see "Installing" below),
a full product runs like this. Each step stops and waits for you.

**1. Brain-dump the idea.** Write a few raw paragraphs in `docs/idea.md`
(from `templates/idea.md.template`). No polish — that's the point.

**2. `/discover <slug>`** — turn the idea into a thesis.
`founder-grill` interviews you one question at a time (problem, beachhead
user, core loop, wedge, monetization, risk, v1 scope). At closure you can
say **`validate`** to run an optional market/competitor/riskiest-assumption
scan, or **`confirmed`** to write `docs/product-outline.md` — your north
star. Review and edit it.

**3. `/plan-product`** — turn the outline into a plan.
`system-architect` drafts `docs/architecture.md` (stack, data model, auth,
hosting) — review and **lock** it. Then `epic-planner` slices the product
into `docs/epics/backlog.md` with a build order and an **MVP boundary**.

**4. `/groom-epic <slug>`** — think through one epic.
`grill-me` grooms it, then in parallel `product-manager` writes the PRD,
`architect` writes the TRD, and `ui-designer` builds a live preview. You
review all three, say `create issues`, and `kanban-generator` fills a
GitHub board with vertical task slices.

**5. `/ship-epic <slug>`** — build it.
`implementer` works the board task by task; `qa-engineer` tests each AC;
`code-reviewer` gates blockers. You verify on staging and merge. Release
notes are written to `docs/releases/`.

**6. Loop steps 4–5** through the backlog in order until the MVP epics
are shipped.

**7. `/launch`** — `launch-manager` rolls up everything that shipped and
produces a go-live readiness checklist in `docs/releases/launch-<date>.md`.
This is your final go/no-go — nothing auto-deploys.

**Where you actually spend judgment:** idea confirmation, product-outline
review, architecture lock, MVP-boundary sign-off, PRD review, design
approval, TRD review, staging verification, and launch readiness. Between
those gates the agents work on their own.

## Installing into a new project

1. Copy `.claude/agents/` and `.claude/skills/` into your project's
   `.claude/` directory.
2. Copy `.claude/settings.json` in too (or merge it with your existing
   one) — it adds the main-branch edit guard, a post-edit
   lint+typecheck hook, and a session audit log. **Edit the
   `PostToolUse` command to your project's actual lint/typecheck
   commands** — it ships with `pnpm lint`/`pnpm tsc` as a placeholder.
3. Copy `templates/` in — most are filled by the agents, not by hand:
   - `idea.md.template` → `docs/idea.md` — **the one doc you write by
     hand.** A few raw paragraphs about the idea; `/discover` turns it
     into the rest.
   - `CLAUDE.md.template` → `CLAUDE.md` (project root) — you fill this in
     (see step 4).
   - `product-outline.md.template`, `architecture.md.template`,
     `backlog.md.template` — **generated for you** by `/discover` and
     `/plan-product`. Copy them in only so you know the shape; you no
     longer hand-write them.
   - `adr.md.template` → copy per-decision into `docs/decisions/`.
   - `prd.md.template`, `trd.md.template`, `release-notes.md.template`,
     `launch-checklist.md.template` are used by the agents automatically
     — they're here so you know the shape the agents produce.
4. Fill in `CLAUDE.md` with your actual stack, repo structure, and
   package/module boundary rules — every agent reads this file first.
   The agent files reference "this project's actual repo layout / see
   CLAUDE.md" rather than hardcoding paths, so this is the one file
   that makes the whole pipeline project-specific. (Starting from an idea
   rather than an existing stack? Run `/discover` and `/plan-product`
   first — `/plan-product` writes `docs/architecture.md`, which tells you
   what to put in `CLAUDE.md`.)
5. Then follow "How to use it" above, starting at step 1.

## What this is not (yet)

This is a reference template repo, not a scaffolding CLI. There's no
`npx create-harness` — you copy the files in by hand and adapt
`CLAUDE.md` to your project. A CLI that automates the install steps
above, and a full software-team mode alongside solo-founder mode, are
plausible future additions but aren't built here. The pipeline also
covers idea→launch but not yet the operate/iterate half (bug/hotfix
flow, CI/CD + infra provisioning, monitoring, a feedback→backlog loop).

## Requirements

- Claude Code (agents + skills + hooks support).
- GitHub, from `/groom-epic` onward (the kanban-generator, implementer,
  qa-engineer, and code-reviewer agents use `mcp__github__*` tools
  against GitHub Issues/Projects as the board). The front-end skills
  `/discover` and `/plan-product` need no GitHub — they only write docs.
- Whatever stack your project actually uses — the pipeline is
  language/framework-agnostic; only `CLAUDE.md` needs filling in.
