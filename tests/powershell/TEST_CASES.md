# PowerShell Profile Test Cases

## Scope

- `Microsoft.PowerShell_profile.ps1`
- `README_PowerShell.md`

## Priority P0 (Critical)

1. Recursive `idea` invocation must not occur
- Code reference: `Microsoft.PowerShell_profile.ps1:340-343`
- Risk: `Get-Command idea` resolves the function itself, then `& idea @args` recursively calls itself.
- Pester cases:
  - Load profile in isolated scope with no external `idea.exe`.
  - Invoke `idea .`.
  - Assert no recursion/stack overflow.
  - Assert fallback path search branch executes.

2. Recursive `charm` invocation must not occur
- Code reference: `Microsoft.PowerShell_profile.ps1:360-363`
- Risk: same recursion pattern as `idea`.
- Pester cases:
  - Load profile in isolated scope with no external `charm.exe`.
  - Invoke `charm .`.
  - Assert no recursion/stack overflow.
  - Assert fallback path search branch executes.

## Priority P1 (High)

3. VS Code shell integration should not execute when `code` is unavailable
- Code reference: `Microsoft.PowerShell_profile.ps1:327-329`
- Risk: direct `code --locate-shell-integration-path ...` call may error during profile load.
- Pester cases:
  - Set `$env:TERM_PROGRAM='vscode'`; mock `Get-Command code` absent.
  - Dot-source profile.
  - Assert profile loads without terminating error.

4. Kiro shell integration should be guarded when `kiro` command is missing
- Code reference: `Microsoft.PowerShell_profile.ps1:72`
- Risk: direct `kiro --locate-shell-integration-path ...` call can throw when not installed.
- Pester cases:
  - Set `$env:TERM_PROGRAM='kiro'`; mock `Get-Command kiro` absent.
  - Dot-source profile.
  - Assert profile load is non-fatal.

5. README claims around CLI launcher behavior must match profile behavior
- README references:
  - `README_PowerShell.md:232-240` (IDEA launcher fallback)
  - `README_PowerShell.md:243-248` (PyCharm launcher fallback)
- Code references:
  - `Microsoft.PowerShell_profile.ps1:340-355`
  - `Microsoft.PowerShell_profile.ps1:360-374`
- Pester cases:
  - Verify fallback search logic is reachable when launcher binaries are missing.
  - Verify user-facing message matches README guidance.

## Priority P2 (Medium)

6. `devinfo` should stay resilient when command outputs are malformed
- Code reference: `Microsoft.PowerShell_profile.ps1:148-159`
- Pester cases:
  - Mock `terraform version -json` invalid JSON; assert function continues.
  - Mock one tool throwing; assert remaining tool rows still render.

7. `gitpush` parameter contract
- Code reference: `Microsoft.PowerShell_profile.ps1:192-198`
- Pester cases:
  - Call `gitpush` with no message; assert parameter binding failure occurs.
  - Call with message; assert command chain order is `add -> commit -> pull --rebase -> push`.

8. `edit-profile` fallback order behavior
- Code reference: `Microsoft.PowerShell_profile.ps1:306-312`
- Pester cases:
  - Mock only `notepad` present; assert `notepad $PROFILE` called.
  - Mock `code` present; assert it is preferred over others.

9. VPN wrappers should tolerate missing service
- Code reference: `Microsoft.PowerShell_profile.ps1:315-317`
- Pester cases:
  - Mock `Start-Service`/`Stop-Service`/`Get-Service` not finding service.
  - Assert no terminating exception due to `-ErrorAction SilentlyContinue`.

10. README command examples should map to real functions
- README references:
  - `README_PowerShell.md:274-277`, `README_PowerShell.md:281-286`
- Code reference:
  - `Microsoft.PowerShell_profile.ps1:386-429`
- Pester cases:
  - When `gh` is absent, `ghcs/ghce/ghcg` stubs exist and return install guidance.
  - When `codex` absent, `codex` stub exists and returns install guidance.

## Suggested Pester Layout

```text
tests/powershell/
  profile.Tests.ps1
  README_profile_consistency.Tests.ps1
```

## First Tests to Implement

1. P0 recursion tests for `idea` and `charm`.
2. Profile load safety tests for VS Code/Kiro integration.
3. README-to-code consistency tests for IDE launcher behavior.