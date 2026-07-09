# Philosophy: Harness AI Development

Why this framework exists, and the thinking behind each piece. This is
the durable reference — the blog post is the narrated version of this
document.

## Core thesis

AI dev tools fail not because the models aren't capable — they fail
because there's no pipeline. A pipeline of specialist agents, with human
checkpoints in the right places, beats one "smart" agent every time.

## 1. The problem with one model doing everything

One model trying to plan, design, build, test, and review in a single
undifferentiated context produces one of two failure modes:

- **Loops forever** — no clear stopping condition, no checklist to
  satisfy, so it keeps "improving" indefinitely.
- **Produces code you don't trust** — because nothing forced it to
  separate "what should this do" from "how is this built" from "does
  this actually work," so all three get conflated and none get
  verified.

"Prompt better" doesn't fix this. The problem is structural, not
lexical — no prompt makes one context simultaneously a good product
thinker, a good architect, and a suspicious-of-its-own-work reviewer.

## 2. The mental model: a star team, not a swarm

One orchestrator (you, running skills) + specialists with
non-overlapping roles, each with their own context and tools. Subagents
don't talk to each other directly — they only see what you (via the
skill) explicitly hand them. This isn't a limitation to work around,
it's the point: it forces every handoff to go through a durable
artifact (a PRD, a TRD, a GitHub Issue) instead of an ephemeral chat
turn. That artifact is what the next agent — and the next session, and
the human — actually reads.

**Seven roles, covering an end-to-end SDLC:**

| Role              | Produces                          | Model  |
| ----------------- | ---------------------------------- | ------ |
| grill-me           | shared understanding (grooming)   | opus   |
| product-manager    | PRD                                | —      |
| architect          | TRD                                | opus   |
| ui-designer        | React + Tailwind preview           | —      |
| kanban-generator   | vertical task slices as GitHub Issues | —  |
| implementer        | working code, one task at a time  | —      |
| qa-engineer        | tests against AC, not code        | —      |
| code-reviewer      | BLOCKER / SHOULD-FIX / NIT         | —      |

grill-me and architect run on the highest-leverage thinking model
available (opus) — get those two right and every downstream agent
inherits clean input. The rest run on whatever's inherited/default,
because their job is narrower and more mechanical.

## 3. The three documents that anchor everything

- **product-outline.md** — north star, ~10 lines, rarely changes.
- **architecture.md** — binding technical decisions, long-form.
- **CLAUDE.md** — short-form project memory every agent reads first.

The principle: agents need shared context, not clever prompts. A PRD
that says "AC-3: returns 400 on invalid email" is worth more than any
amount of prompt engineering telling the implementer to "be careful
about validation." Documents are infrastructure, not paperwork.

## 4. Vertical slicing on the Kanban

Per-layer tasks ("add migration", "build component") break AI
pipelines because no single task delivers anything checkable — you
can't write a happy/failure/edge test against half a feature. One AC =
one task = one vertical slice (touches UI + API + DB together, or
whichever layers a slice genuinely needs).

GitHub Issues + labels (`epic:E0N`) + milestones are the actual board.
The implementer picks tasks dependency-aware — it never starts a task
whose `Depends on` issues aren't `Done`, and it always resumes an `In
Progress` issue before starting a new one. This means a session can be
killed mid-task and resumed cleanly later; state lives on the board,
not in your context window.

## 5. The seven non-negotiables baked into every agent

1. Every HTTP route gets: validation + auth + rate limit + structured log.
2. Every feature gets: happy + failure + edge test.
3. Untrusted content never gets executed.
4. AI-generated or user-generated HTML must be sanitized AND sandboxed
   (if the project renders untrusted content at all).
5. Tests assert AC behaviour, not implementation — a QA agent that
   "fixes" a failing test by weakening the assertion has failed at
   its actual job.
6. No silent architectural deviations — surfaced as Open Questions,
   never quietly worked around.
7. One PR per epic, one commit per task.

These live in CLAUDE.md's "Non-negotiable engineering rules" section
and every agent reads that file before doing anything.

## 6. The two-skill pipeline

- **`/groom-epic`** = thinking (grill-me → PRD + TRD + designs in
  parallel → GitHub Issues).
- **`/ship-epic`** = building (pick task → implement → test → review →
  staging → merge).

Splitting thinking from building matters because they have different
failure modes and different human-attention requirements. Grooming
needs your full judgment, one decision at a time. Building mostly
doesn't — the implementer loops autonomously across many tasks while
you do other things, and only interrupts you at genuine stop
conditions (missing dependency, TRD conflict, repeated test failure).
Collapsing the two into one command means you're either micromanaging
the build or rubber-stamping the thinking. Neither is good.

## 7. Human checkpoints — where you actually matter

- PRD review (does this solve the right problem?)
- Design approval (in-browser, plain-English feedback)
- TRD review (AI-generated, you still gate it — architecture decisions
  are still yours to own)
- Staging verification (does it actually work, on a real deploy?)

The principle: you're not writing code, you're making decisions. Every
phase gate exists because the decision at that point is one only a
human should make — scope, taste, risk tolerance, "is this good
enough to ship."

## 8. Observability

- The terminal as live chain-of-thought — you watch the agent reason,
  not just its final output.
- The GitHub Project board as the source of truth for task state.
- `.claude/session.log` as the audit trail (every subagent stop,
  timestamped, with branch and session ID).
- Cost discipline: a full epic run has a rough expected cost range. If
  a session costs far more than a comparable epic, something is
  looping — stop and read the session log before spending more.

Cost discipline matters more than most write-ups admit: an
undisciplined pipeline can burn real money re-running agents against
the same failure. The stop conditions throughout this framework
(implementer, qa-engineer, code-reviewer all have explicit ones) exist
specifically to fail loud and cheap instead of looping silently and
expensive.

## 9. Honest limits

**Where this still falls short:**

- Subagent reliability for fully automatic delegation — you are still
  the orchestrator running skills by hand, not a fire-and-forget system.
- Generic UI taste — the ui-designer agent produces competent,
  consistent output, not genuinely novel visual design.
- Distributed debugging — multi-service failures that span the whole
  stack still need a human to reason about causality.

**Where it shines:**

- Routine CRUD: 3–5x throughput over unstructured prompting.
- Bug fixes against a clear spec.
- Refactors with good existing test coverage.

## 10. The takeaway

Pipeline + boundaries > one smart agent. Documents are infrastructure,
not paperwork. You stop typing code and start making decisions — the
bottleneck shifts to your judgment, which is the right bottleneck.
</content>
