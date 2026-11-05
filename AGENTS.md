# AGENTS.md — dotfiles

Rules for AI agents (and humans) working in this repository.

## Change discipline

- Work on a feature branch; never commit to `main`/`master`. The owner merges PRs on GitHub.

## Org-wide rules (2026-11-05)

- **Branch names say what the change does, in plain words** (owner rule for all `rbf7` repos,
  2026-11-05): `claude/<what-it-does>` in short kebab-case for agent work, e.g.
  `claude/fix-login-redirect`, `claude/record-dns-change`. No internal codes or ticket IDs a
  person can't read (not `claude/record-b9`), never the random name a session starts with, and
  never reuse a merged branch.
