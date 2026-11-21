# Project state

**Last updated:** 2026-11-21 (agent files brought to the org standard), by Claude Code.

## Where we are

- Portable Zsh dotfiles (WSL, Debian/Ubuntu, macOS), a PowerShell profile and an oh-my-posh
  theme, installed by `install.sh` (`README.md`, `README_PowerShell.md`).
- Stable: recent changes are agent-instruction files only.
- Tests exist (`tests/bash/*.bats`, `tests/powershell/`) but nothing runs them automatically;
  the repo has no workflows.

## Open items

None is urgent; the owner picks.

1. `.DS_Store` is tracked and there is no `.gitignore`.
2. `install.sh` runs remote installer scripts from moving branches (zplug `master`, Homebrew
   `HEAD`). Pin zplug to a commit for stricter installs.
3. The tests never run in CI. A small workflow is free on a public repository (it must follow
   the "Workflows" rule in `AGENTS.md`).
4. `.agents/skills/` is vendored without a note on its source or licence.
5. Owner: confirm a ruleset protects `main` (Settings → Rules → Rulesets).

## Next actions

- Agent standard step 5b (`rbf7-platform-iac` ADR-007, amended 2026-11-21), owner 2026-11-21:
  `AGENTS.md` gets the required section "Delegate simple work to cheaper subagents" (revised
  wording, tested in fresh Opus sessions) and the standard org-wide block; `.claude/CLAUDE.md` a
  two-line reminder in the owner's words. PR on `claude/adopt-subagent-rule`; docs and agent config
  only. Owner: merge.

1. Owner: item 5, then any other item.
