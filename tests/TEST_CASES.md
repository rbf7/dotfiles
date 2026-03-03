# Dotfiles Test Cases

## Scope

- `install.sh`
- `.zshrc`
- `aliasrc`
- `Microsoft.PowerShell_profile.ps1`

## Priority P0 (Critical)

1. `Microsoft.PowerShell_profile.ps1` recursive function call for `idea`
- File: `Microsoft.PowerShell_profile.ps1`
- Lines: around 340-343
- Why: function `idea` checks `Get-Command idea`, which resolves to the function itself, then calls `& idea @args`, causing recursion.
- Test cases:
  - Define function from profile in isolated session.
  - Mock external `idea.exe` unavailable.
  - Call `idea .`.
  - Assert function does not recurse and prints fallback guidance (expected behavior after fix).

2. `Microsoft.PowerShell_profile.ps1` recursive function call for `charm`
- File: `Microsoft.PowerShell_profile.ps1`
- Lines: around 360-363
- Why: same recursion pattern as `idea`.
- Test cases:
  - Define function from profile in isolated session.
  - Mock external `charm.exe` unavailable.
  - Call `charm .`.
  - Assert function does not recurse and prints fallback guidance (expected behavior after fix).

## Priority P1 (High)

3. `install.sh` ghost-plugin cleanup regex portability
- File: `install.sh`
- Line: around 161
- Why: `grep -v '^\s*$'` uses `\s`, which is not portable in basic grep regex; blank-line filtering can misbehave.
- Test cases:
  - Create temp `packages.zsh` with only blank lines/spaces.
  - Run cleanup path.
  - Assert no false-positive ghost entries are reported.
  - Create temp `packages.zsh` with one plugin line.
  - Assert plugin line is detected and file is cleared.

4. `.zshrc` VS Code integration should be safe when `code` command is missing
- File: `.zshrc`
- Lines: around 511-513
- Why: if `TERM_PROGRAM=vscode` and `code` is missing, sourcing command substitution may error.
- Test cases:
  - Run zsh with `TERM_PROGRAM=vscode` and `code` absent.
  - Source `.zshrc`.
  - Assert shell startup does not exit non-zero and does not print fatal sourcing errors.

5. `install.sh` symlink behavior when destination is directory
- File: `install.sh`
- Lines: around 80-84
- Why: `ln -sf "$src" "$dest"` on directory destination may create nested symlink, not replace.
- Test cases:
  - Create temp destination directory where file link expected.
  - Invoke `link_file`.
  - Assert expected fail-safe behavior (explicit error or refusal) after fix.

## Priority P2 (Medium)

6. `aliasrc` extractor function error handling
- File: `aliasrc`
- Lines: around 20-39
- Test cases:
  - `ex` with missing file.
  - `ex` with unsupported extension.
  - `ex` with `.zip` and valid archive.
  - Assert clear output and proper exit code conventions.

7. `install.sh` backup behavior correctness
- File: `install.sh`
- Lines: around 66-74
- Test cases:
  - target regular file exists -> backup file created with timestamp pattern.
  - target symlink exists -> no backup created.
  - target missing -> no backup created.

8. `.zshrc` `_check_zplug` resolution order
- File: `.zshrc`
- Lines: around 205-220
- Test cases:
  - only `$HOME/.zplug/init.zsh` exists -> selected first.
  - only `/usr/share/zplug/init.zsh` exists -> selected as fallback.
  - none exists -> returns failure.

9. `.zshrc` `_setup_autojump` fallback function `j`
- File: `.zshrc`
- Lines: around 341-374
- Test cases:
  - no autojump scripts found -> `_setup_autojump` returns non-zero and `j` function exists.
  - call `j foo` -> shows OS-specific install guidance.

10. `Microsoft.PowerShell_profile.ps1` `devinfo` resilience
- File: `Microsoft.PowerShell_profile.ps1`
- Lines: around 142-179
- Test cases:
  - Tool missing -> no exception thrown.
  - Terraform returns invalid JSON -> handled gracefully.
  - Output still contains other tool rows.

11. `.zshrc` `fzf-history-widget` keybinding behavior
- File: `.zshrc`
- Lines: around 331-353
- Test cases:
  - with `fzf` available and interactive Zsh, `Ctrl+Space` should be bound to `fzf-history-widget`.
  - when `fzf` is missing, sourcing `.zshrc` should still succeed (no hard failure).
  - `Ctrl+F` should remain bound to `autosuggest-accept` when autosuggestions plugin is enabled.

## Suggested Test Framework Split

- Bash/Zsh files: `bats-core` with fixture temp directories and command stubs in `PATH`.
- PowerShell profile: `Pester` with command mocks (`Mock Get-Command`, `Mock Write-Host`, `Mock Get-Item`).

## Minimal Directory Layout

```text
tests/
  bash/
    install.bats
    zshrc.bats
    aliasrc.bats
  powershell/
    profile.Tests.ps1
  fixtures/
    archives/
```

## First Tests to Implement

1. P0 recursion tests for `idea` and `charm` (Pester).
2. `install.sh` regex portability test.
3. `.zshrc` safe startup test when `TERM_PROGRAM=vscode` and `code` is missing.

