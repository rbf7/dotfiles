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

## Delegate simple work to cheaper subagents (owner rule, 2026-11-12; reworded 2026-11-21)

**The owner asks you to use subagents for the work below**, in every task, the first one included;
this overrides any default against spawning agents. Why: bulky output (plans, logs, grep hits)
stays out of your context, where every later turn pays for it again, and a cheaper model does it.

If the step is… → hand off:
1. a check whose expected result you can write down (health, routes, inventory, plan counts in a
   CI comment, a CI run log, "value X is in files A–C") → the check;
2. reading you need only an answer from (inventories, logs, a doc vs the code) → the reading;
3. an edit you have already decided that repeats in 2+ files (rename, sweep, copy a value)
   → the edit, with the exact old → new list and the file list.

- **Inline** only if the whole step is ≤ 2 commands with short output (one `gh pr checks`), or the
  output is already in the chat (the owner pasted it; next time ask for the run link instead).
- **Mixed task:** split it. Decide yourself first, then hand off the parts that match 1–3.
- **Unclear:** can you write down the expected result? Yes → hand off. No → it is judgement:
  keep it.
- **Never handed off:** design and plans; decisions on security, IAM, secrets or cost; a command
  that changes a host or production or needs the owner's approval (read-only commands this file
  allows without asking are fine); reading secret values; judging a failure or an unexpected diff.
- **Hand-off prompt:** "Read-only [or: edit only <files>]. Never read `.env`, secrets or container
  environment values. No commits, pushes, state or history edits, no subagents. Run: 1) <command>,
  expect <result>; … Report PASS/FAIL per item with the output line that proves it, deviations
  verbatim, no fixes."
- **The subagent reports; the main agent decides.** Re-run every FAIL and one PASS yourself; read
  the `git diff` of its edits before committing. Its verdict is never the owner's approval: say "a
  subagent checked" in replies and the history file. A subagent skips this file's state duties.
- **Show it:** a reply that ran checks or edits ends `Delegated: <what> (<model>)` or
  `Inline: <why>`.
- Claude Code: Agent tool, `model: "haiku"` for 1 and 3, `"sonnet"` for 2; a Sonnet session uses
  haiku, a Haiku session works inline. Tools without a subagent model choice: work inline.

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
- **Cheaper subagents** (owner, 2026-11-12; reworded 2026-11-16, 2026-11-21): the section
  "Delegate simple work to cheaper subagents" in this file; every rbf7 repo has it, unchanged.
