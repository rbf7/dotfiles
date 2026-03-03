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

# 4. Allow profile to run (one-time, run as Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# 5. Reload
. $PROFILE
```

---

## Dependencies

### Kiro Terminal Integration

If you use [Kiro](https://kiro.dev) (Amazon's AI code editor), the profile automatically enables shell integration when running inside Kiro's terminal. No setup needed — the line is already there and only activates when `$env:TERM_PROGRAM` equals `"kiro"`, so it's completely harmless in any other terminal.

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
| `gp "msg"` | `git add . && commit && pull --rebase && push` |
| `gu` | Refresh SSH agent for GitHub |
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
| `edit-profile` | Open profile in `$EDITOR` |

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

## Troubleshooting

**Icons don't render / show as boxes**
Install a Nerd Font: `oh-my-posh font install` then set it in Windows Terminal Settings → Font face. Recommended: `CaskaydiaCove Nerd Font` or `JetBrainsMono Nerd Font`.

**`oh-my-posh : The term is not recognized`**
Scoop installs binaries to `~\scoop\shims` — restart Windows Terminal after installing. If it still fails, add it manually:
```powershell
$env:PATH += ";$HOME\scoop\shims"
```

**`cannot be loaded because running scripts is disabled`**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**Symlink requires Administrator**
Run Windows Terminal as Administrator when creating the symlink, or use the copy method instead.

**PSReadLine `ListView` prediction not showing**
Requires PSReadLine 2.2+:
```powershell
scoop install psreadline
# Or via PowerShell Gallery
Install-Module PSReadLine -Force -Scope CurrentUser
```

**Oh My Posh PATH not found after scoop install**
Scoop installs to `~\scoop\shims` — make sure it's on your PATH:
```powershell
scoop install oh-my-posh
# If still not found, restart Windows Terminal — scoop updates PATH automatically
```
