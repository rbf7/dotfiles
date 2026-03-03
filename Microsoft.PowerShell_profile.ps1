# =============================================================================
# PowerShell 7+ Profile — Windows 11/10
# Prompt:  Oh My Posh (Tokyo Night theme)
# Modules: PSReadLine
# Mirrors the Zsh dotfiles developer config in style and aliases
# =============================================================================


# =============================================================================
# 0. SAFETY — abort gracefully if running in a restricted/non-interactive scope
# =============================================================================

if (-not $Host.UI.RawUI) { return }


# =============================================================================
# 1. OH MY POSH — Tokyo Night theme
#    Install: scoop install oh-my-posh
#    Docs:    https://ohmyposh.dev
# =============================================================================

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {

    # $env:POSH_THEMES_PATH is set automatically by Oh My Posh on install.
    # Using it directly is the most reliable cross-machine approach.
    $OmpTheme = "$env:POSH_THEMES_PATH\tokyo.omp.json"

    if (Test-Path $OmpTheme) {
        oh-my-posh init pwsh --config $OmpTheme | Invoke-Expression
    } else {
        # Theme file not found — render a minimal pure-PowerShell Tokyo Night
        # prompt so the profile never crashes or falls back to the default.
        Write-Host "  [oh-my-posh] tokyo.omp.json not found at: $env:POSH_THEMES_PATH" -ForegroundColor DarkGray
        Write-Host "  Run: oh-my-posh font install    then restart terminal." -ForegroundColor DarkGray

        function prompt {
            $lastOk    = $?
            $gitBranch = ""
            if (Get-Command git -ErrorAction SilentlyContinue) {
                $branch = git branch --show-current 2>$null
                if ($branch) { $gitBranch = " ($branch)" }
            }
            $path   = $ExecutionContext.SessionState.Path.CurrentLocation.Path `
                      -replace [regex]::Escape($HOME), "~"
            $blue   = "`e[38;5;111m"
            $purple = "`e[38;5;141m"
            $cyan   = "`e[38;5;117m"
            $green  = "`e[38;5;114m"
            $red    = "`e[38;5;210m"
            $grey   = "`e[38;5;60m"
            $reset  = "`e[0m"
            $arrow  = if ($lastOk) { "${green}❯${reset}" } else { "${red}❯${reset}" }
            "${blue}$env:USERNAME${reset}${grey}@${reset}${purple}$env:COMPUTERNAME${reset} ${cyan}${path}${reset}${green}${gitBranch}${reset}`n${arrow} "
        }
    }

} else {
    Write-Host ""
    Write-Host "  Oh My Posh is not installed." -ForegroundColor DarkGray
    Write-Host "  Install with:  scoop install oh-my-posh" -ForegroundColor DarkGray
    Write-Host "  Then restart this terminal." -ForegroundColor DarkGray
    Write-Host ""
}


# =============================================================================
# 2. KIRO — Terminal shell integration
#    Kiro is Amazon's AI code editor (https://kiro.dev)
#    This line enables shell integration features inside Kiro's terminal
# =============================================================================

if ($env:TERM_PROGRAM -eq "kiro") { . "$(kiro --locate-shell-integration-path pwsh)" }


# =============================================================================
# 3. PSREADLINE — history, autosuggestions, syntax highlighting
#    Install: scoop install psreadline  (or: Install-Module PSReadLine -Force)
# =============================================================================

if (Get-Module -ListAvailable -Name PSReadLine) {
    Import-Module PSReadLine

    # Behaviour
    Set-PSReadLineOption -EditMode Emacs                          # familiar keybindings
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd           # cursor at end on history search
    Set-PSReadLineOption -MaximumHistoryCount 200000
    Set-PSReadLineOption -HistoryNoDuplicates

    # Autosuggestions (like zsh-autosuggestions)
    Set-PSReadLineOption -PredictionSource History
    Set-PSReadLineOption -PredictionViewStyle ListView            # dropdown list view

    # Tokyo Night colours for syntax highlighting
    Set-PSReadLineOption -Colors @{
        Command            = "`e[38;5;111m"   # soft blue    — commands
        Parameter          = "`e[38;5;117m"   # sky cyan     — parameters
        String             = "`e[38;5;114m"   # muted green  — strings
        Variable           = "`e[38;5;141m"   # soft purple  — variables
        Operator           = "`e[38;5;210m"   # soft red     — operators
        Number             = "`e[38;5;215m"   # warm orange  — numbers
        Comment            = "`e[38;5;60m"    # grey-blue    — comments
        Keyword            = "`e[38;5;176m"   # orchid       — keywords
        Type               = "`e[38;5;74m"    # teal         — types
        InlinePrediction   = "`e[38;5;60m"    # grey-blue    — suggestions
    }

    # Keybindings to mirror Zsh config
    Set-PSReadLineKeyHandler -Chord "Ctrl+p"        -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Chord "Ctrl+n"        -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord "Ctrl+f"        -Function AcceptSuggestion       # accept inline suggestion
    Set-PSReadLineKeyHandler -Chord "Ctrl+Spacebar" -Function AcceptSuggestion
    Set-PSReadLineKeyHandler -Chord "UpArrow"       -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Chord "DownArrow"     -Function HistorySearchForward
    Set-PSReadLineKeyHandler -Chord "Tab"           -Function MenuComplete

} else {
    Write-Host ""
    Write-Host "  PSReadLine not found. Install with:" -ForegroundColor DarkGray
    Write-Host "  Install with:  scoop install psreadline" -ForegroundColor DarkGray
    Write-Host "  Or via PS Gallery: Install-Module PSReadLine -Force -Scope CurrentUser" -ForegroundColor DarkGray
    Write-Host ""
}


# =============================================================================
# 4. DEVINFO — print all installed tool versions (mirrors Zsh devinfo)
# =============================================================================

function devinfo {
    Write-Host ""
    Write-Host "  🖥  OS        : $([System.Runtime.InteropServices.RuntimeInformation]::OSDescription.Trim())" -ForegroundColor DarkGray

    $tools = @(
        @{ cmd = "python";    label = "🐍 Python   "; args = "--version" },
        @{ cmd = "node";      label = "⬡  Node      "; args = "--version" },
        @{ cmd = "npm";       label = "📦 npm       "; args = "--version" },
        @{ cmd = "java";      label = "☕ Java      "; args = "-version" },
        @{ cmd = "terraform"; label = "🏗  Terraform "; args = "version -json" },
        @{ cmd = "docker";    label = "🐳 Docker    "; args = "--version" },
        @{ cmd = "aws";       label = "☁️  AWS CLI   "; args = "--version" },
        @{ cmd = "go";        label = "🐹 Go        "; args = "version" },
        @{ cmd = "rustc";     label = "🦀 Rust      "; args = "--version" },
        @{ cmd = "ruby";      label = "💎 Ruby      "; args = "--version" },
        @{ cmd = "php";       label = "🐘 PHP       "; args = "--version" },
        @{ cmd = "git";       label = "🌿 Git       "; args = "--version" }
    )

    foreach ($t in $tools) {
        if (Get-Command $t.cmd -ErrorAction SilentlyContinue) {
            try {
                $ver = & $t.cmd ($t.args -split " ") 2>&1 | Select-Object -First 1
                # Terraform returns JSON — extract version string
                if ($t.cmd -eq "terraform") {
                    $ver = ($ver | ConvertFrom-Json -ErrorAction SilentlyContinue).terraform_version
                }
                Write-Host "  $($t.label): $ver" -ForegroundColor Gray
            } catch {
                Write-Host "  $($t.label): (error reading version)" -ForegroundColor DarkGray
            }
        }
    }
    Write-Host ""
}


# =============================================================================
# 5. ALIASES — mirrors aliasrc from Zsh config
# =============================================================================

# --- Navigation ---
function .. { Set-Location .. }
function ... { Set-Location ../.. }
function .... { Set-Location ../../.. }
function ~ { Set-Location $HOME }

# --- File listing (mirrors ls aliases) ---
function l   { Get-ChildItem -Force @args }
function ll  { Get-ChildItem -Force @args | Format-List }
function la  { Get-ChildItem -Force -Hidden @args }
function lt  { Get-ChildItem -Force @args | Sort-Object LastWriteTime -Descending }
function lS  { Get-ChildItem -Force @args | Sort-Object Length -Descending }

# --- Editor ---
Set-Alias -Name vi  -Value vim  -Option AllScope -ErrorAction SilentlyContinue
Set-Alias -Name vim -Value vim  -Option AllScope -ErrorAction SilentlyContinue

# --- Grep equivalent ---
function grep { Select-String @args }
function ftext { Get-ChildItem -Recurse | Select-String @args }

# --- Git ---
function gitpush {
    param([Parameter(Mandatory)][string]$Message)
    git add .
    git commit -m $Message
    git pull --rebase
    git push
}

function gitupdate {
    # Update key path to match your SSH key filename
    $keyPath = "$HOME\.ssh\id_ed25519"
    if (Test-Path $keyPath) {
        ssh-add $keyPath
        ssh -T git@github.com
    } else {
        Write-Host "SSH key not found at $keyPath — update gitupdate in your profile." -ForegroundColor Yellow
    }
}

Set-Alias -Name gp  -Value gitpush
Set-Alias -Name gu  -Value gitupdate

function gs  { git status }
function gl  { git log --oneline --graph --decorate -15 }
function gco { git checkout @args }
function gcb { git checkout -b @args }
function gaa { git add -A }
function gcm { git commit -m @args }
function gd  { git diff @args }
function gds { git diff --staged }
function grb { git rebase @args }
function gst { git stash }
function gstp{ git stash pop }

# --- Python ---
Set-Alias -Name py -Value python

function venv {
    python -m venv .venv
    .\.venv\Scripts\Activate.ps1
}
function activate { .\.venv\Scripts\Activate.ps1 }
function pyver { python --version }

# --- Node / React ---
function nodever { node --version; npm --version }
function nr  { npm run @args }
function nrd { npm run dev }
function nrb { npm run build }
function nrt { npm run test }
function nri { npm install @args }

# --- Terraform ---
Set-Alias -Name tf -Value terraform
function tfi { terraform init }
function tfp { terraform plan }
function tfa { terraform apply }
function tfd { terraform destroy }
function tfver { terraform version }
function tfw { terraform workspace list }

# --- Java ---
function javaver { java -version }
function mvnw { .\mvnw @args }
function gradlew { .\gradlew @args }

# --- Go ---
function gorun   { go run . }
function gobuild { go build ./... }
function gotest  { go test ./... }
function gotidy  { go mod tidy }
function gover   { go version }

# --- Rust ---
function cb     { cargo build }
function cr     { cargo run }
function ct     { cargo test }
function ccheck { cargo check }
function cfmt   { cargo fmt }
function rustver{ rustc --version }

# --- Ruby ---
function rubyver { ruby --version }
function be  { bundle exec @args }
function bi  { bundle install }
function rs  { bundle exec rails server }
function rc  { bundle exec rails console }

# --- PHP ---
function phpver { php --version }
function cpa { composer install }
function cpu { composer update }
function cpd { composer dump-autoload }

# --- Docker ---
Set-Alias -Name dk -Value docker
function dkc    { docker compose @args }
function dkcu   { docker compose up -d }
function dkcd   { docker compose down }
function dkps   { docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" }
function dkclean{ docker system prune }       # no -f — always prompts
function dklogs { docker logs -f @args }

# --- Utilities ---
function ports  { netstat -ano | Select-String "LISTENING" }
function myip   { (Invoke-RestMethod ifconfig.me/ip).Trim() }
function path   { $env:PATH -split ";" }
function now    { Get-Date -Format "yyyy-MM-dd HH:mm:ss" }
function cls    { Clear-Host }
function reload { . $PROFILE }

# Open profile in editor
function edit-profile { & $env:EDITOR $PROFILE }

# --- VPN (OpenVPN via sc/services — rename to match your service name) ---
function vpn-start  { Start-Service  "OpenVPNServiceInteractive" -ErrorAction SilentlyContinue }
function vpn-stop   { Stop-Service   "OpenVPNServiceInteractive" -ErrorAction SilentlyContinue }
function vpn-status { Get-Service    "OpenVPNServiceInteractive" -ErrorAction SilentlyContinue }


# =============================================================================
# 6. STARTUP MESSAGE
# =============================================================================

Write-Host ""
Write-Host "  PowerShell $($PSVersionTable.PSVersion) — Developer Profile loaded." -ForegroundColor DarkGray
Write-Host "  Run devinfo to see installed tool versions." -ForegroundColor DarkGray
Write-Host ""
