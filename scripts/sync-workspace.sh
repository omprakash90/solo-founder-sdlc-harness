#!/usr/bin/env bash
#
# Sync the harness (.claude/, templates/, docs/philosophy.md) between this
# repo and a parent "workspace" directory that holds multiple sibling
# product/service repos.
#
# Layout this assumes:
#
#   repo-autonom/                 <- workspace root, Claude Code sessions start here
#   ├── .claude/                  <- pull:  copied FROM sdlc-harness/.claude
#   ├── templates/                <- pull:  copied FROM sdlc-harness/templates
#   ├── CLAUDE.md                 <- pull:  seeded once, never overwritten after
#   ├── sdlc-harness/              <- this repo: the reusable, pushable harness
#   ├── autonom-agent/            <- sibling service repos, untouched by this script
#   ├── autonom-api/
#   └── ...
#
#   bash scripts/sync-workspace.sh pull [workspace-dir]
#   bash scripts/sync-workspace.sh push [workspace-dir]
#
# pull  — refresh the workspace's .claude/ and templates/ from this repo
#         (the source of truth). Safe to re-run; never touches CLAUDE.md,
#         docs/idea.md or anything else in the workspace once they exist.
#
# push  — copy the workspace's .claude/ back into this repo so new agents
#         or skills you built while working can be committed and PR'd
#         upstream. Shows a diff and asks for confirmation before
#         overwriting anything in this repo.
#
# Neither mode ever touches the sibling service repos.

set -euo pipefail

MODE="${1:-}"
HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKSPACE_DIR="${2:-$(cd "$HARNESS_DIR/.." && pwd)}"

say()  { printf '\n\033[1m==> %s\033[0m\n' "$1"; }
ok()   { printf '    \033[32m✓\033[0m %s\n' "$1"; }
warn() { printf '    \033[33m!\033[0m %s\n' "$1"; }
die()  { printf '\n\033[31m✗ %s\033[0m\n\n' "$1" >&2; exit 1; }

[ "$MODE" = "pull" ] || [ "$MODE" = "push" ] || die "Usage: sync-workspace.sh <pull|push> [workspace-dir]"
[ -d "$HARNESS_DIR/.claude" ] || die "$HARNESS_DIR does not look like a harness checkout (.claude missing)."
[ -d "$WORKSPACE_DIR" ] || die "Workspace dir $WORKSPACE_DIR does not exist."
[ "$WORKSPACE_DIR" != "$HARNESS_DIR" ] || die "Workspace dir resolved to the harness dir itself — pass an explicit path."

# ------------------------------------------------------------------ pull

do_pull() {
  say "Pulling harness → workspace"
  echo "    harness:   $HARNESS_DIR"
  echo "    workspace: $WORKSPACE_DIR"

  rsync -a --delete "$HARNESS_DIR/.claude/" "$WORKSPACE_DIR/.claude/"
  ok ".claude/ refreshed (agents + skills + settings)"

  rsync -a --delete "$HARNESS_DIR/templates/" "$WORKSPACE_DIR/templates/"
  ok "templates/ refreshed"

  mkdir -p "$WORKSPACE_DIR/docs"
  if [ -f "$HARNESS_DIR/docs/philosophy.md" ]; then
    cp "$HARNESS_DIR/docs/philosophy.md" "$WORKSPACE_DIR/docs/philosophy.md"
    ok "docs/philosophy.md refreshed"
  fi

  if [ -f "$WORKSPACE_DIR/CLAUDE.md" ]; then
    warn "CLAUDE.md already exists in workspace — left untouched."
  else
    cp "$HARNESS_DIR/templates/CLAUDE.md.template" "$WORKSPACE_DIR/CLAUDE.md"
    ok "CLAUDE.md seeded from template (fill in stack + multi-repo layout)"
  fi

  say "Pull complete"
  echo "    Start your Claude Code session in: $WORKSPACE_DIR"
}

# ------------------------------------------------------------------ push

do_push() {
  say "Checking for local changes in workspace/.claude"
  [ -d "$WORKSPACE_DIR/.claude" ] || die "No .claude/ in $WORKSPACE_DIR — nothing to push."

  if diff -rq "$HARNESS_DIR/.claude" "$WORKSPACE_DIR/.claude" >/dev/null 2>&1; then
    ok "No differences — harness and workspace .claude/ are already in sync."
    return 0
  fi

  say "Differences found (workspace → harness)"
  diff -rq "$HARNESS_DIR/.claude" "$WORKSPACE_DIR/.claude" || true

  printf '\n    Copy these changes into %s and stage them for commit? [y/N] ' "$HARNESS_DIR"
  read -r REPLY
  case "$REPLY" in
    y|Y)
      rsync -a --delete "$WORKSPACE_DIR/.claude/" "$HARNESS_DIR/.claude/"
      ok "Copied workspace/.claude → harness/.claude"
      echo "    Review with 'git -C \"$HARNESS_DIR\" diff', then commit and open a PR."
      ;;
    *)
      warn "Skipped. No files changed in $HARNESS_DIR."
      ;;
  esac
}

case "$MODE" in
  pull) do_pull ;;
  push) do_push ;;
esac
