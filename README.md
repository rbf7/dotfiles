# dotfiles — Universal Zsh Developer Config

A portable, pure-Zsh configuration that works identically on **WSL**, **Debian/Ubuntu**, and **macOS** with no external prompt tools required. Drop it on any machine, source it, and your developer environment is ready.

---

## Files

| File | Purpose |
|------|---------|
| `.zshrc` | Main Zsh config — prompt, plugins, keybindings, aliases |
| `aliasrc` | Shared aliases and shell functions, sourced by `.zshrc` |

---

## Quick Install

```bash
# Clone your dotfiles repo
git clone git@github.com:you/dotfiles.git ~/dotfiles

# Symlink into home directory
ln -sf ~/dotfiles/.zshrc ~/.zshrc
ln -sf ~/dotfiles/aliasrc ~/aliasrc

# Reload
source ~/.zshrc
```

---

## The Developer Prompt

The prompt is built entirely in **pure Zsh** using `vcs_info` and `precmd` — no Starship, no Oh My Posh, no external dependencies. Tool badges appear **contextually**, only when they are relevant to the current directory.

```
you@machine ~/projects/myapp (main!)  🐍 py:3.12.1  ⬡ node:20.11.0
❯
```

```
you@machine ~/infra/prod (main)  🏗 tf:1.7.3  ☁️ aws:prod
❯
```

### Prompt segments

| Badge | Appears when... | Trigger |
|-------|----------------|---------|
| `🐍 py:x.x.x` | Python virtualenv is active | `$VIRTUAL_ENV` is set |
| `⬡ node:x.x.x` | In a Node.js project | `package.json` in cwd |
| `🏗 tf:x.x.x` | In a Terraform project | `*.tf` files in cwd |
| `☕ java:x.x.x` | In a Java project | `pom.xml` or `build.gradle` in cwd |
| `🐹 go:x.x.x` | In a Go project | `go.mod` in cwd |
| `🦀 rust:x.x.x` | In a Rust project | `Cargo.toml` in cwd |
| `💎 ruby:x.x.x` | In a Ruby project | `Gemfile` in cwd |
| `🐘 php:x.x.x` | In a PHP project | `composer.json` in cwd |
| `🎯 kotlin:x.x` | In a Kotlin project | `build.gradle.kts` in cwd |
| `☁️ aws:profile` | AWS profile is active | `$AWS_PROFILE` is set |
| `🐳 context` | Non-default Docker context | Docker context ≠ `default` |
| `(branch!+)` | Inside a Git repo | Always — `!` = unstaged, `+` = staged |

**Right prompt:** `✓` (green, last command succeeded) or `✗ 127` (red, with exit code) + current time.

### `devinfo` command

Run `devinfo` at any time to print a full summary of all installed tool versions:

```
  🖥  OS        : wsl
  🐍 Python    : 3.12.1
  ⬡  Node      : 20.11.0
  📦 npm        : 10.2.4
  ☕ Java       : 21.0.2
  🏗  Terraform : v1.7.3
  🐳 Docker     : 25.0.2
  ☁️  AWS CLI   : 2.15.10
  🐹 Go         : 1.22.0
  🦀 Rust       : 1.76.0
  💎 Ruby       : 3.3.0
  🐘 PHP        : 8.3.2
  🌿 Git        : 2.43.0
```

---

## Plugins (via zplug)

Plugins load gracefully — if `zplug` isn't installed, the config tells you exactly how to install it and continues without crashing.

| Plugin | What it does |
|--------|-------------|
| `zsh-autosuggestions` | Gray inline suggestions from history |
| `zsh-history-substring-search` | Smart `↑` / `↓` history filtering |
| `zsh-syntax-highlighting` | Color-codes commands as you type |
| `zsh-completions` | Extended tab completions |
| `git` | Git aliases and prompt info |
| `docker` | Docker tab completions |
| `aws` | AWS CLI completions |
| `terraform` | Terraform tab completions |
| `npm` / `node` | Node/npm completions |
| `python` | Python completions |
| `gradle` / `mvn` | Java build tool completions |
| `tmux` | Tmux integration |

### Install zplug

Use the official curl installer on all platforms (recommended):

```bash
curl -sL --proto-redir -all,https \
  https://raw.githubusercontent.com/zplug/zplug/master/scripts/install.sh | zsh
```

> Note: avoid `brew install zplug` here; this repo expects the curl layout for consistent behavior.

### Troubleshooting: "Failed to install" on macOS

There are two separate causes for this error on macOS:

**Cause 1 — Homebrew creates a broken/incomplete zplug directory.**
`brew install zplug` can create `/opt/homebrew/opt/zplug` but leave it missing `init.zsh`, `autoload/`, `bin/` and other required files. If the directory exists but is hollow, any `ZPLUG_HOME` check against the directory alone (not `init.zsh`) will wrongly trust it.

The `.zshrc` now guards against this by checking for `init.zsh` inside each candidate path, and prefers `~/.zplug` (the curl install) over Homebrew paths.

**Cause 2 — `$ZPLUG_HOME` points to the wrong place.**
Homebrew does not export `ZPLUG_HOME` automatically. Without it set correctly, zplug has no writable location to clone plugins into.

**Cause 3 — Ghost entry in `~/.zplug/packages.zsh`.**
zplug persists plugin definitions in `~/.zplug/packages.zsh`. If a previous broken install wrote a bare entry like `zplug "plugins/zsh-autosuggestions"` (no `from:` tag) into that file, zplug keeps trying to install it on every `zplug install` even after `.zshrc` is fixed. `zplug remove` does not exist as a command, so the fix is to clear the file manually:

```bash
# See what's in it
cat ~/.zplug/packages.zsh

# Clear it — .zshrc manages all plugin definitions, this file should be empty
echo "" > ~/.zplug/packages.zsh

# Verify the ghost is gone
zplug list

# Reinstall and reload
zplug install
source ~/.zshrc
```

**Fix — if you have a broken Homebrew zplug:**

```bash
# Remove the broken Homebrew install
brew uninstall zplug

# Install via curl — always creates a complete ~/.zplug
# Do NOT use brew install zplug — it creates an incomplete directory
curl -sL --proto-redir -all,https \
  https://raw.githubusercontent.com/zplug/zplug/master/scripts/install.sh | zsh

# Reload and install plugins
source ~/.zshrc
zplug install
source ~/.zshrc
```

**Cause 4 — System-wide zplug install with a non-root user (NAS, shared servers).**
When zplug is installed via `apt`, it lands in `/usr/share/zplug` which is owned by root. If `ZPLUG_HOME` points there, zplug tries to create `log/`, `cache/`, and `repos/` inside that system path and fails for any non-root user:

```
mkdir: cannot create directory '/usr/share/zplug/log': Permission denied
mkdir: cannot create directory '/usr/share/zplug/cache': Permission denied
mkdir: cannot create directory '/usr/share/zplug/repos': Permission denied
```

The fix is to always keep `ZPLUG_HOME` separate from the init script location. The init script can live anywhere — `ZPLUG_HOME` must always be `~/.zplug` (user-writable). The `.zshrc` now does this unconditionally.

**Does this affect macOS?** No — on macOS zplug is always in a user-owned location (Homebrew or `~/.zplug`).

---

## Troubleshooting: `install.sh` errors on Debian / WSL

**`local: can only be used in a function`**
Caused by an older version of `install.sh` that used `local` outside a function. Pull the latest version of the script — this is fixed.

**`ZPLUG_HOME: unbound variable`**
Caused by `set -u` (strict mode) in the script treating an unset `ZPLUG_HOME` as an error before the detection logic could run. Fixed in the current version using `${ZPLUG_HOME:-}` which safely returns empty instead of erroring when the variable is unset. Safe on macOS and Debian.

---

## Keybindings

| Keys | Action | Requires |
|------|--------|----------|
| `Ctrl+P` or `↑` | History search up (substring match) | `zsh-history-substring-search` plugin |
| `Ctrl+N` or `↓` | History search down | `zsh-history-substring-search` plugin |
| `Ctrl+F` | Accept inline autosuggestion | `zsh-autosuggestions` plugin |
| `Ctrl+R` | fzf fuzzy history search | `fzf` |
| `Ctrl+T` | fzf file picker — pastes selected path onto command line | `fzf` |
| `Alt+C` | fzf directory picker — `cd` into selection | `fzf` |
| `Ctrl+Space` | fzf history picker, **pre-filtered to what you've already typed** | `fzf` |

### `Ctrl+R` vs `Ctrl+Space`

Both open fzf over your history, but differ in starting state:

| Binding | Starts with... | Best for... |
|---------|---------------|-------------|
| `Ctrl+R` | Empty query — browse all history | Exploring history freely |
| `Ctrl+Space` | Query pre-filled with what you've typed | Type a few chars first, then open filtered list — equivalent to PSReadLine `ListView` in PowerShell |

### fzf shell integration

fzf bindings (`Ctrl+R`, `Ctrl+T`, `Alt+C`, `Ctrl+Space`) activate **automatically on shell startup** — no manual setup required beyond installing fzf.

The config detects the fzf version and takes the right path for each platform:

| Platform | fzf source | Method |
|----------|-----------|--------|
| macOS (Homebrew) | `brew install fzf` | `eval "$(fzf --zsh)"` — modern API (≥ 0.48) |
| Linux (Homebrew) | `brew install fzf` | `eval "$(fzf --zsh)"` — modern API (≥ 0.48) |
| Debian / Ubuntu / WSL | `apt install fzf` | Sources `key-bindings.zsh` directly — fallback for older apt builds |

```bash
# macOS / Linux (Homebrew)
brew install fzf

# Debian / Ubuntu / WSL
sudo apt update && sudo apt install -y fzf
```

After installing, open a new terminal — bindings register automatically.

---

## Alias Reference

### Navigation & Files

| Alias | Command |
|-------|---------|
| `l` | `ls -lFh` — long, type, human readable |
| `la` | `ls -lAFh` — include dotfiles |
| `lt` | `ls -ltFh` — sorted by date |
| `..` / `...` | Go up one / two directories |
| `fd` | `find . -type d -name` — only defined if `fd-find` / `fdfind` is not installed |
| `ff` | `find . -type f -name` |
| `ftext` | Full text search: `ftext "pattern"` |

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
| `py` | `python3` |
| `venv` | Create `.venv` and activate it |
| `activate` | `source .venv/bin/activate` |
| `pip` | `pip3` |

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
| `tfw` | `terraform workspace list` |

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

### Ruby

| Alias | Command |
|-------|---------|
| `be` | `bundle exec` |
| `bi` | `bundle install` |
| `rs` | `bundle exec rails server` |
| `rc` | `bundle exec rails console` |

### Docker

| Alias | Command |
|-------|---------|
| `dkcu` | `docker compose up -d` |
| `dkcd` | `docker compose down` |
| `dkps` | Pretty `docker ps` with names/ports |
| `dkclean` | `docker system prune` — prompts for confirmation |
| `dklogs` | `docker logs -f` |

### Debian / Ubuntu / WSL

| Alias | Command |
|-------|---------|
| `apt-up` | `apt update && apt full-upgrade -y && apt autoremove -y` |
| `apt-search` | `apt search` |
| `apt-show` | `apt show` |
| `apt-list` | `apt list --installed` |
| `update-grub` | `sudo update-grub` (when available) |
| `vpn-start` | Start OpenVPN client via systemctl (rename to match your service) |
| `vpn-stop` | Stop OpenVPN client via systemctl |
| `vpn-status` | Status of OpenVPN client |

### macOS

| Alias | Command |
|-------|---------|
| `brewup` | `brew update && brew upgrade && brew cleanup` |
| `brewlist` | `brew list` |
| `pbc` | `pbcopy` — pipe to clipboard |
| `pbp` | `pbpaste` — paste from clipboard |
| `finder` | `open .` — open current dir in Finder |

### Utilities

| Alias | Command |
|-------|---------|
| `reload` | `source ~/.zshrc` |
| `ports` | `lsof -i -P -n \| grep LISTEN` — falls back to `ss -tlnp` if lsof not installed |
| `myip` | Print your public IP |
| `path` | Print `$PATH` one entry per line |
| `now` | Print current datetime |
| `ex file` | Extract any archive format |

---

## IDE Integration

### VS Code

Shell integration activates automatically when Zsh runs inside VS Code's integrated terminal — no setup needed.

| Alias | Command |
|-------|---------|
| `vsc` | `code .` — open current dir |
| `vscd file1 file2` | Open diff view |
| `vsca folder` | Add folder to current workspace |

### IntelliJ IDEA / PyCharm

Enable the CLI launcher once inside the IDE: **Tools → Create Command-line Launcher**. This creates `idea` / `charm` on your PATH.

```bash
idea .      # open current directory in IDEA
charm .     # open current directory in PyCharm

# Shortcuts defined in .zshrc
idea-here   # same as: idea .
charm-here  # same as: charm .
```

On macOS, the `.zshrc` also searches JetBrains Toolbox script paths automatically if the binary isn't on PATH yet:
`~/Library/Application Support/JetBrains/Toolbox/scripts/`

---

## GitHub Copilot / Codex CLI

### Install `gh` CLI

`gh` is **not** in the default Debian apt repo — it needs GitHub's own apt repository.

```bash
# macOS
brew install gh

# Debian / Ubuntu / WSL — must add GitHub's repo first
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
  | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
  https://cli.github.com/packages stable main" \
  | sudo tee /etc/apt/sources.list.d/github-cli.list
sudo apt update && sudo apt install gh

# Windows (PowerShell — scoop)
scoop install gh
```

### Install Copilot extension and Codex CLI

```bash
# Authenticate first
gh auth login

# Install Copilot extension (all platforms)
gh extension install github/gh-copilot

# Install Codex CLI (requires Node/npm — all platforms)
npm install -g @githubnext/github-copilot-cli
```

### Commands

| Command | What it does |
|---------|-------------|
| `ghcs "query"` | Suggest a **shell** command |
| `ghce "query"` | **Explain** a command or error |
| `ghcg "query"` | Suggest a **git** command |
| `codex "query"` | Full Codex CLI for code generation |

### Examples

```bash
ghcs "find all files larger than 100mb modified in the last week"
ghce "what does git rebase -i HEAD~3 do"
ghcg "undo last commit but keep my changes"
codex "write a bash script that monitors disk usage and alerts at 90%"
```

Tab completion for `gh` registers automatically when the shell loads.

---

## OS Support

| Environment | Status |
|-------------|--------|
| macOS (Intel) | ✅ Full support |
| macOS (Apple Silicon) | ✅ Full support |
| Debian / Ubuntu | ✅ Full support |
| WSL 2 (Windows) | ✅ Full support, auto-detected |
| Git Bash | ⚠️ Runs Bash, not Zsh — use a separate `.bashrc` |

All system-specific aliases (`apt`, `brew`, VPN, etc.) are wrapped in `command -v` guards and only activate if the tool exists on the current machine.

---

## Suggested Language Additions

The following languages are not yet in this config but are worth adding if you use them:

| Language | Trigger file | Detection command |
|----------|-------------|-------------------|
| **Swift** | `Package.swift` | `swift --version` |
| **Lua** | `*.lua` / `.luarc.json` | `lua -v` |
| **Elixir** | `mix.exs` | `elixir --version` |
| **Scala** | `build.sbt` | `scala -version` |
| **Dart / Flutter** | `pubspec.yaml` | `dart --version` |
| **C / C++** | `CMakeLists.txt` | `gcc --version` |
| **Zig** | `build.zig` | `zig version` |

To add any of these, copy the pattern from an existing language block in `precmd()` inside `.zshrc` and adapt the trigger file and version command.

---

## History

200,000 entries, shared across all shell sessions, with duplicate suppression and immediate write — you never lose a command.

---

## Dotfiles repo structure (recommended)

```
~/dotfiles/
  .zshrc
  aliasrc
  README.md
  install.sh
```

`install.sh` (included in this repo) does the following in order:

1. Verifies it is being run from the dotfiles repo root
2. **Backs up** any existing `~/.zshrc` or `~/aliasrc` before overwriting (timestamped `.backup` file)
3. Symlinks `.zshrc` and `aliasrc` into `$HOME`
4. Checks if **Zsh** is installed — offers to install it if not
5. Offers to set Zsh as your **default shell** if it isn't already
6. Checks if **zplug** is installed — offers to install via curl if not (never `brew install zplug` — Homebrew produces an incomplete install). If already installed, automatically clears any ghost entries from `~/.zplug/packages.zsh` that would cause `Failed to install` errors
7. Checks if **autojump** is installed — offers to install it if not
8. Checks if **fzf** is installed — offers to install it if not. On Linux/WSL without Homebrew, warns that the apt version is old (<0.48) and the legacy `key-bindings.zsh` fallback will be used for Ctrl+R / Ctrl+Space
9. Reports which **optional dev tools** are missing (git, docker, node, python3, terraform, go, rust, ruby, php, java, **fzf**) with the right install command for your OS
10. On macOS, checks for **Homebrew** and offers to install it

```bash
bash install.sh
```




