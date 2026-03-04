Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)
$profilePath = Join-Path $repoRoot 'Microsoft.PowerShell_profile.ps1'
$readmePath = Join-Path $repoRoot 'README_PowerShell.md'

Describe 'README_PowerShell consistency with profile' {
    BeforeAll {
        $script:profileContent = Get-Content -Raw $profilePath
        $script:readmeContent = Get-Content -Raw $readmePath
    }

    It 'documents gpush/gup and avoids gp collision claim mismatch' {
        $script:readmeContent | Should Match '\| `gpush "msg"` \|'
        $script:readmeContent | Should Match '\| `gup` \|'
        $script:profileContent | Should Match 'Set-Alias -Name gpush -Value gitpush\s+-Force'
        $script:profileContent | Should Match 'Set-Alias -Name gup\s+-Value gitupdate\s+-Force'
    }

    It 'documents VS Code integration and profile contains TERM_PROGRAM guard' {
        $script:readmeContent | Should Match 'Shell integration activates automatically when PowerShell runs inside VS Code'
        $script:profileContent | Should Match 'if \(\$env:TERM_PROGRAM -eq "vscode"\)'
    }

    It 'documents IDEA fallback behavior and profile has fallback path scan' {
        $script:readmeContent | Should Match 'falls back to searching common JetBrains Toolbox install paths'
        $script:profileContent | Should Match '\$ideaPaths = @\('
        $script:profileContent | Should Match 'IDEA-U\\ch-0\\\*\\bin\\idea64\.exe'
    }

    It 'documents PyCharm launcher and profile has fallback path scan' {
        $script:readmeContent | Should Match 'create the `charm` binary'
        $script:profileContent | Should Match '\$charmPaths = @\('
        $script:profileContent | Should Match 'PyCharm-P\\ch-0\\\*\\bin\\pycharm64\.exe'
    }

    It 'documents profile-home OMP theme preference and profile references tokyo-dev path' {
        $script:readmeContent | Should Match 'PowerShell profile directory'
        $script:readmeContent | Should Match 'themes/powershell/tokyo-dev\.omp\.json'
        $script:profileContent | Should Match '\$profile_Home\s*=\s*Split-Path -Parent \$PROFILE'
        $script:profileContent | Should Match 'themes\\powershell\\tokyo-dev\.omp\.json'
    }

    It 'documents codex powershell completion note and profile uses powershell keyword' {
        $script:readmeContent | Should Match 'uses `powershell` \(not `pwsh`\)'
        $script:profileContent | Should Match 'codex completion powershell'
    }
}


