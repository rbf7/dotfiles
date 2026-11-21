# AGENTS.md — dotfiles

Rules for AI agents (and humans) working in this repository.

**This repository is public.** Never add private host names, IP addresses, e-mail addresses,
tokens, or details of any other system.

## Canonical instructions

This file is the canonical AI-agent instruction set. Other assistants reference it:
Claude Code (`.claude/CLAUDE.md`), GitHub Copilot (`.github/copilot-instructions.md`),
Gemini CLI (`.gemini/settings.json`). If instructions conflict, keep the safety, cost,
security and destroy rules in this file unless the owner explicitly changes them.

## Start here

1. `AGENTS.md` (this file).
2. `docs/state.md`: where we are, open items, next actions (the resume point).
3. Only what the task touches: `README.md`, `README_PowerShell.md`, `install.sh`, `tests/`.

## Change discipline

- Work on a feature branch; never commit to `main`/`master`. The owner merges PRs on GitHub.
- Small, reviewable commits. Do not rewrite history or force-push unless the owner asks.
- Before commit and push: `git branch --show-current` and `git status`; after push:
  `git log origin/<branch> -1`.

## Keeping state current

In the same pull request as a decision, a code change or a new finding, update `docs/state.md`
(current facts only, short). This repo has no history file: the pull request is the record.

## Continuity

The work must be resumable by a fresh session of any assistant, on another machine, using only
this repository: start from `docs/state.md`; whatever a later session needs (what was decided,
what is half done, what comes next) goes into a file in the same pull request, never only into
a chat. No required reading outside the repo (facts taken from other repos are summarised in
`docs/state.md`), no state or secrets that exist only on one machine, machine-specific paths
only as examples. This public repository holds no secrets: never add one.

## Org-wide rules

- **Branch names say what the change does, in plain words** (owner rule for all `rbf7` repos,
  2026-11-05): `claude/<what-it-does>` in short kebab-case for agent work, e.g.
  `claude/fix-login-redirect`, `claude/record-dns-change`. No internal codes or ticket IDs a
  person can't read (not `claude/record-b9`), never the random name a session starts with, and
  never reuse a merged branch.
- **Workflows** (2026-11-06): GitHub-hosted runners only (never `runs-on: self-hosted`); every
  workflow has a `paths` filter that excludes `**/*.md`, `timeout-minutes` on every job and
  `concurrency`.
- **Cheaper subagents for simple work** (owner, 2026-11-12; every rbf7 repo): delegate to a
  cheaper model (e.g. Sonnet or Haiku) checking pasted outputs against an expected result ("plan
  says No changes?", "13 added?"), read-only verification lists, and mechanical edits (renames,
  doc sweeps, copying a value). Keep on the main model: design, plans for review, anything
  touching security, IAM, secrets or cost, and judging a failure or an unexpected diff. The
  subagent reports; the main agent decides — a subagent's verdict is never the owner's approval.
