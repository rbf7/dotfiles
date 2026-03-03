Set-StrictMode -Version Latest

$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent (Split-Path -Parent $here)
$profilePath = Join-Path $repoRoot 'Microsoft.PowerShell_profile.ps1'

Describe 'Microsoft.PowerShell_profile.ps1' {
    BeforeAll {
        $script:profileContent = Get-Content -Raw $profilePath
        $script:tokens = $null
        $script:parseErrors = $null
        [System.Management.Automation.Language.Parser]::ParseFile(
            $profilePath,
            [ref] $script:tokens,
            [ref] $script:parseErrors
        ) | Out-Null
    }

    It 'parses without syntax errors' {
        $script:parseErrors | Should BeNullOrEmpty
    }

    It 'guards Kiro integration behind TERM_PROGRAM and command existence' {
        $script:profileContent | Should Match 'if \(\(\$env:TERM_PROGRAM -eq "kiro"\) -and \(Get-Command kiro -ErrorAction SilentlyContinue\)\)'
        $script:profileContent | Should Match '\$kiroIntegrationPath\s*=\s*kiro --locate-shell-integration-path pwsh'
    }

    It 'guards VS Code integration behind command existence' {
        $script:profileContent | Should Match 'if \(\$env:TERM_PROGRAM -eq "vscode"\) \{\s*if \(Get-Command code -ErrorAction SilentlyContinue\)'
        $script:profileContent | Should Match '\$vscodeIntegrationPath\s*=\s*code --locate-shell-integration-path pwsh'
    }

    It 'resolves idea launcher as external application, not function recursion' {
        $script:profileContent | Should Match 'Get-Command idea -CommandType Application -ErrorAction SilentlyContinue'
        $script:profileContent | Should Match '& \$ideaCmd\.Source @args'
        $script:profileContent | Should Not Match '& idea @args'
        $script:profileContent | Should Match '& \$ideaBin\.FullName @args'
    }

    It 'resolves charm launcher as external application, not function recursion' {
        $script:profileContent | Should Match 'Get-Command charm -CommandType Application -ErrorAction SilentlyContinue'
        $script:profileContent | Should Match '& \$charmCmd\.Source @args'
        $script:profileContent | Should Not Match '& charm @args'
        $script:profileContent | Should Match '& \$charmBin\.FullName @args'
    }

    It 'keeps defensive alias-force pattern for custom aliases' {
        $script:profileContent | Should Match 'Set-Alias -Name gpush -Value gitpush\s+-Force'
        $script:profileContent | Should Match 'Set-Alias -Name gup\s+-Value gitupdate\s+-Force'
    }
}