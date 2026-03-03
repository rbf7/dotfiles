# PowerShell Profile — Developer Config

PowerShell 7+ (`pwsh`) profile for Windows 11/10. Mirrors the Zsh dotfiles config in aliases, developer shortcuts, and Tokyo Night colour scheme.

---

## Quick Install

```powershell
# 1. Find your profile path
echo $PROFILE

# 2. Create the directory if it doesn't exist
New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE)

# 3. Copy or symlink the profile
# Option A — symlink (recommended, stays in sync with your dotfiles repo)
New-Item -ItemType SymbolicLink -Path $PROFILE `
  -Target "C:\path\to\dotfiles\Microsoft.PowerShell_profile.ps1" -Force

# Option B — copy
Copy-Item Microsoft.PowerShell_profile.ps1 $PROFILE -Force

# 4. Allow profile to run — REQUIRED, one-time setup
#    -Scope CurrentUser never requires Administrator rights
#    Without this you get: "cannot be loaded... not digitally signed"
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# 5. Reload
. $PROFILE
```

> **Corporate machine (OneDrive, managed by IT)?**
> `-Scope CurrentUser` is safe and does not require admin rights — it only affects your own user account. If IT has locked `MachinePolicy` or `UserPolicy` you may need to ask them, but `CurrentUser` scope works on most managed machines.

---

## Dependencies

### Kiro Terminal Integration

If you use [Kiro](https://kiro.dev) (Amazon's AI code editor), the profile enables shell integration when running inside Kiro's terminal **and** when the `kiro` CLI is available. No setup needed — it only activates when `$env:TERM_PROGRAM` equals `"kiro"` and the command exists, so it's harmless in other terminals.

### Oh My Posh (prompt)

```powershell
# Install Scoop if you haven't already (run as normal user, not Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression

# Install Oh My Posh
scoop install oh-my-posh

# Install a Nerd Font for icons to render correctly
oh-my-posh font install
```

Restart Windows Terminal after installing the font, then set it as your terminal font in Settings → Profiles → Appearance → Font face.

The profile uses the **tokyo** theme (`tokyo.omp.json`) which is included with Oh My Posh. If it can't find the theme file it falls back to a minimal pure-PowerShell Tokyo Night prompt automatically — no crash, no ugly default.

### PSReadLine (autosuggestions, syntax highlighting, keybindings)

PSReadLine ships with PowerShell 7 but may be outdated. Update it:

```powershell
scoop install psreadline
# Or via PowerShell Gallery
Install-Module PSReadLine -Force -Scope CurrentUser
```

---

## Prompt

The Oh My Posh tokyo theme shows:

- Git branch + dirty state
- Current directory
- Exit code indicator
- Language versions contextually per directory (Python, Node, Terraform, Go, Rust, Java, etc.)
- Time on the right

If Oh My Posh is not installed, the profile renders a fallback prompt in the same **Tokyo Night** colour palette using pure ANSI codes — no engine needed.

---

## Keybindings

Matches the Zsh config keybindings:

| Keys | Action |
|------|--------|
| `Ctrl+P` / `↑` | History search backward |
| `Ctrl+N` / `↓` | History search forward |
| `Ctrl+F` / `Ctrl+Space` | Accept inline suggestion |
| `Tab` | Menu completion |

---

## Alias Reference

### Navigation

| Alias | Command |
|-------|---------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `~` | `cd $HOME` |

### File Listing

| Alias | Command |
|-------|---------|
| `l` | `Get-ChildItem -Force` |
| `ll` | Long format list |
| `la` | Include hidden files |
| `lt` | Sorted by date |
| `lS` | Sorted by size |

### Git

| Alias | Command |
|-------|---------|
| `gpush "msg"` | `git add . && commit && pull --rebase && push` |
| `gup` | Refresh SSH agent for GitHub |
| `gs` | `git status` |
| `gl` | Pretty log graph (last 15) |
| `gcb` | `git checkout -b` |
| `gcm` | `git commit -m` |
| `gd` / `gds` | diff / diff staged |
| `gst` / `gstp` | stash / stash pop |

### Python

| Alias | Command |
|-------|---------|
| `py` | `python` |
| `venv` | Create `.venv` and activate |
| `activate` | `.\.venv\Scripts\Activate.ps1` |

### Node / React

| Alias | Command |
|-------|---------|
| `nrd` | `npm run dev` |
| `nrb` | `npm run build` |
| `nrt` | `npm run test` |
| `nri` | `npm install` |

### Terraform

| Alias | Command |
|-------|---------|
| `tf` | `terraform` |
| `tfi` | `terraform init` |
| `tfp` | `terraform plan` |
| `tfa` | `terraform apply` |
| `tfd` | `terraform destroy` |

### Go

| Alias | Command |
|-------|---------|
| `gorun` | `go run .` |
| `gobuild` | `go build ./...` |
| `gotest` | `go test ./...` |
| `gotidy` | `go mod tidy` |

### Rust

| Alias | Command |
|-------|---------|
| `cb` | `cargo build` |
| `cr` | `cargo run` |
| `ct` | `cargo test` |
| `cfmt` | `cargo fmt` |

### Docker

| Alias | Command |
|-------|---------|
| `dk` | `docker` |
| `dkcu` | `docker compose up -d` |
| `dkcd` | `docker compose down` |
| `dkps` | Pretty `docker ps` |
| `dkclean` | `docker system prune` — always prompts |
| `dklogs` | `docker logs -f` |

### Utilities

| Alias | Command |
|-------|---------|
| `devinfo` | Print all installed tool versions |
| `reload` | `. $PROFILE` |
| `ports` | Show listening ports |
| `myip` | Print public IP |
| `path` | Print `$PATH` one entry per line |
| `now` | Print current datetime |
| `edit-profile` | Open profile in VS Code → Notepad++ → Notepad (whichever is found first) |

### VPN

```powershell
vpn-start   # Start-Service OpenVPNServiceInteractive
vpn-stop    # Stop-Service  OpenVPNServiceInteractive
vpn-status  # Get-Service   OpenVPNServiceInteractive
```

Update the service name to match yours. Find it with:

```powershell
Get-Service | Where-Object { $_.Name -like "*vpn*" -or $_.Name -like "*openvpn*" }
```

---

## IDE Integration

### VS Code

Shell integration activates automatically when PowerShell runs inside VS Code's terminal **and** the `code` CLI is available — no extra setup needed. It enables command decorations, terminal history, and quick fix suggestions.

| Alias | Command |
|-------|---------|
| `vsc` | `code .` — open current dir |
| `vscd file1 file2` | Open diff view |
| `vsca folder` | Add folder to current workspace |

### IntelliJ IDEA

Requires enabling the command-line launcher first: **Tools → Create Command-line Launcher** inside IDEA. This creates the `idea` binary on your PATH.

```powershell
idea .          # open current directory
idea myproject  # open specific project
```

The profile falls back to searching common JetBrains Toolbox install paths if `idea` isn't on PATH yet.

### PyCharm

Same as IDEA — enable via **Tools → Create Command-line Launcher** to create the `charm` binary.

```powershell
charm .         # open current directory
charm myproject # open specific project
```

---

## GitHub Copilot / Codex CLI

### Install

```powershell
# 1. Install gh CLI
scoop install gh

# 2. Authenticate
gh auth login

# 3. Install Copilot extension
gh extension install github/gh-copilot

# 4. Install Codex CLI
npm install -g @githubnext/github-copilot-cli
```

### Commands

| Command | What it does |
|---------|-------------|
| `ghcs "query"` | Suggest a **shell** command for your query |
| `ghce "query"` | **Explain** a command or error message |
| `ghcg "query"` | Suggest a **git** command for your query |
| `codex "query"` | Full Codex CLI for code generation |

### Examples

```powershell
ghcs "find all files larger than 100mb"
ghce "what does git rebase -i HEAD~3 do"
ghcg "undo last commit but keep my changes"
codex "write a PowerShell script to monitor disk usage"
```

Tab completion for `gh` is registered automatically when the profile loads.

Tab completion for `codex` is also registered automatically if Codex CLI is installed. Note: the Codex CLI uses `powershell` (not `pwsh`) as the shell identifier — the profile handles this correctly.

## Testing (Pester)

Run the PowerShell tests from the repository root:

```powershell
Invoke-Pester -Path .\tests\powershell
```

If tests are executed from a `\\wsl.localhost\...` path and script signing blocks execution, use a process-scoped bypass for the current shell only:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
Invoke-Pester -Path .\tests\powershell
```

If your environment still loads Windows PowerShell Pester 3.x, keep using the tests in this repo (they are written with Pester 3-compatible `Should` syntax).

---


## Troubleshooting

**Icons don't render / show as boxes**
Install a Nerd Font: `oh-my-posh font install` then set it in Windows Terminal Settings → Font face. Recommended: `CaskaydiaCove Nerd Font` or `JetBrainsMono Nerd Font`.

**`oh-my-posh : The term is not recognized`**
Scoop installs binaries to `~\scoop\shims` — restart Windows Terminal after installing. If it still fails, add it manually:
```powershell
$env:PATH += ";$HOME\scoop\shims"
```

**`cannot be loaded... not digitally signed`** (OneDrive / corporate machines)

The most common cause on OneDrive-synced profiles: Windows attaches a Zone.Identifier stream to cloud-synced files marking them as from the internet. Two steps fix it permanently:

```powershell
# Step 1 — set execution policy (no admin needed, CurrentUser scope only)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Step 2 — remove the internet zone flag from the profile file
Unblock-File -Path $PROFILE

# Step 3 — reload
. $PROFILE
```

To verify IT Group Policy is not the blocker:
```powershell
Get-ExecutionPolicy -List
```
If MachinePolicy or UserPolicy shows AllSigned or Restricted, IT is blocking it. If both show Undefined, Unblock-File + RemoteSigned is all you need.

For one-off test execution on `\\wsl.localhost\...` paths, you can also use:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force
```

**Alias is not writeable: alias gp is read-only**

gp is a built-in PowerShell read-only alias for Get-ItemProperty. The profile uses gpush and gup instead, and all Set-Alias calls include -Force. Pull the latest profile — already fixed.

**`-Match` / `-BeNullOrEmpty` is not a valid Should operator (Pester)**

You are running an older Pester engine (typically 3.x) against tests written for newer syntax. Pull the latest `tests/powershell/*.Tests.ps1` from this repo (already converted to Pester 3-compatible `Should Match` / `Should BeNullOrEmpty`) or upgrade to Pester 5+.

**`Get-PSReadLineKeyHandler` already exists when reloading profile**

This is caused by importing PSReadLine repeatedly. The profile now imports PSReadLine only when not already loaded. Pull the latest `Microsoft.PowerShell_profile.ps1`, then restart PowerShell and run `. $PROFILE` once.

**Symlink requires Administrator**
Run Windows Terminal as Administrator when creating the symlink, or use the copy method instead.

**PSReadLine `ListView` prediction not showing**
Requires PSReadLine 2.2+:
```powershell
scoop install psreadline
# Or via PowerShell Gallery
Install-Module PSReadLine -Force -Scope CurrentUser
```

**`Cannot bind argument to parameter 'Command' because it is an empty string`** (Codex CLI)

Caused by `codex completion pwsh` — `pwsh` is not a valid shell name for the Codex CLI. The valid value is `powershell`. The profile now uses the correct name and guards against empty output before invoking. Pull the latest profile — already fixed.

**Oh My Posh PATH not found after scoop install**
Scoop installs to `~\scoop\shims` — make sure it's on your PATH:
```powershell
scoop install oh-my-posh
# If still not found, restart Windows Terminal — scoop updates PATH automatically
```


