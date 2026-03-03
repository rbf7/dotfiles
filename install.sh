#!/usr/bin/env bash
# =============================================================================
# install.sh — Dotfiles installer
# Targets: Debian / Ubuntu / WSL (Debian) / macOS
# Usage:   bash install.sh   ← always use 'bash', never 'sh' or 'zsh'
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Colours
# -----------------------------------------------------------------------------
C_GREEN='\033[0;32m'
C_YELLOW='\033[1;33m'
C_RED='\033[0;31m'
C_BLUE='\033[0;34m'
C_RESET='\033[0m'

info()    { echo -e "${C_BLUE}[INFO]${C_RESET}  $*"; }
success() { echo -e "${C_GREEN}[OK]${C_RESET}    $*"; }
warn()    { echo -e "${C_YELLOW}[WARN]${C_RESET}  $*"; }
error()   { echo -e "${C_RED}[ERROR]${C_RESET} $*"; }

# -----------------------------------------------------------------------------
# Must be run from the dotfiles repo root
# -----------------------------------------------------------------------------
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "$DOTFILES_DIR/.zshrc" || ! -f "$DOTFILES_DIR/aliasrc" ]]; then
  error "Run this script from the root of your dotfiles repo."
  error "Expected to find: .zshrc and aliasrc in: $DOTFILES_DIR"
  exit 1
fi

echo ""
echo "  ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗"
echo "  ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝"
echo "  ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗"
echo "  ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║"
echo "  ██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║"
echo "  ╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝"
echo ""
echo "  Universal Zsh Developer Config — Installer"
echo "  Dotfiles dir: $DOTFILES_DIR"
echo ""


# -----------------------------------------------------------------------------
# OS detection
# -----------------------------------------------------------------------------
OS="other"
case "$OSTYPE" in
  darwin*) OS="mac" ;;
  linux*)
    OS="linux"
    grep -qi microsoft /proc/version 2>/dev/null && OS="wsl"
    ;;
esac

info "Detected OS: $OS"


# -----------------------------------------------------------------------------
# Helper: backup a file if it exists and is not already a symlink to us
# -----------------------------------------------------------------------------
backup_if_needed() {
  local target="$1"
  if [[ -f "$target" && ! -L "$target" ]]; then
    local backup="${target}.backup.$(date +%Y%m%d_%H%M%S)"
    warn "Existing file found: $target"
    warn "Backing up to:       $backup"
    mv "$target" "$backup"
  fi
}


# -----------------------------------------------------------------------------
# Helper: create symlink
# -----------------------------------------------------------------------------
link_file() {
  local src="$1"
  local dest="$2"
  backup_if_needed "$dest"
  ln -sf "$src" "$dest"
  success "Linked: $dest → $src"
}


# -----------------------------------------------------------------------------
# 1. Symlink dotfiles
# -----------------------------------------------------------------------------
echo ""
info "Linking dotfiles..."

link_file "$DOTFILES_DIR/.zshrc"  "$HOME/.zshrc"
link_file "$DOTFILES_DIR/aliasrc" "$HOME/aliasrc"


# -----------------------------------------------------------------------------
# 2. Ensure Zsh is installed
# -----------------------------------------------------------------------------
echo ""
info "Checking Zsh..."

if ! command -v zsh >/dev/null 2>&1; then
  warn "Zsh is not installed."
  if [[ "$OS" == "mac" ]]; then
    info "Installing via Homebrew..."
    brew install zsh
  elif [[ "$OS" == "linux" || "$OS" == "wsl" ]]; then
    info "Installing via apt..."
    sudo apt update && sudo apt install -y zsh
  fi
else
  success "Zsh found: $(zsh --version)"
fi

# Offer to set Zsh as default shell if it isn't already
if [[ "$SHELL" != "$(command -v zsh)" ]]; then
  warn "Zsh is not your default shell (current: $SHELL)"
  printf "  Set Zsh as default shell now? [y/N] "; read -r _reply
  if [[ "$_reply" =~ ^[Yy]$ ]]; then
    chsh -s "$(command -v zsh)"
    success "Default shell changed to Zsh. Log out and back in for it to take effect."
  fi
fi


# -----------------------------------------------------------------------------
# 3. Install zplug
# -----------------------------------------------------------------------------
echo ""
info "Checking zplug..."

# ZPLUG_HOME must always be user-writable (~/.zplug).
# Never point it at a system path like /usr/share/zplug — non-root users
# will get "Permission denied" when zplug tries to create log/cache/repos.
export ZPLUG_HOME="$HOME/.zplug"

_zplug_found=false

for _p in \
  /usr/share/zplug/init.zsh \
  "$HOME/.zplug/init.zsh" \
  /usr/local/opt/zplug/init.zsh \
  /opt/homebrew/opt/zplug/init.zsh
do
  [[ -f "$_p" ]] && _zplug_found=true && break
done

if [[ "$_zplug_found" == true ]]; then
  success "zplug already installed."

  # Clean ghost entries from packages.zsh.
  # If a previous broken install stored bare plugin names like
  # "plugins/zsh-autosuggestions" (no from: tag) in packages.zsh,
  # zplug keeps retrying them even after .zshrc is fixed — causing
  # "Failed to install" errors forever. All plugin definitions live
  # in .zshrc so packages.zsh should be empty.
  if [[ -n "${ZPLUG_HOME:-}" && -f "$ZPLUG_HOME/packages.zsh" ]]; then
    _ghost=$(grep -v '^\s*$' "$ZPLUG_HOME/packages.zsh" 2>/dev/null || true)
    if [[ -n "$_ghost" ]]; then
      warn "Found ghost entries in $ZPLUG_HOME/packages.zsh:"
      echo "$_ghost"
      warn "Clearing them — .zshrc manages all plugin definitions."
      echo "" > "$ZPLUG_HOME/packages.zsh"
      success "packages.zsh cleared."
    fi
  fi
else
  warn "zplug not found."
  printf "  Install zplug now? [y/N] "; read -r _reply
  if [[ "$_reply" =~ ^[Yy]$ ]]; then
    # Always use curl — brew install zplug creates an incomplete directory
    # that causes "Failed to install" plugin errors.
    info "Installing zplug via curl (recommended over Homebrew)..."
    curl -sL --proto-redir -all,https \
      https://raw.githubusercontent.com/zplug/zplug/master/scripts/install.sh | zsh
    success "zplug installed."
  else
    warn "Skipping zplug. Plugins will not load until it is installed."
  fi
fi


# -----------------------------------------------------------------------------
# 4. Install autojump
# -----------------------------------------------------------------------------
echo ""
info "Checking autojump..."

if command -v autojump >/dev/null 2>&1; then
  success "autojump already installed."
else
  warn "autojump not found."
  printf "  Install autojump now? [y/N] "; read -r _reply
  if [[ "$_reply" =~ ^[Yy]$ ]]; then
    if [[ "$OS" == "mac" ]]; then
      brew install autojump
    elif [[ "$OS" == "linux" || "$OS" == "wsl" ]]; then
      sudo apt update && sudo apt install -y autojump
    fi
    success "autojump installed."
  else
    warn "Skipping autojump. The 'j' command will not be available."
  fi
fi


# -----------------------------------------------------------------------------
# 5. Check optional dev tools — report what's missing, don't force install
# -----------------------------------------------------------------------------
echo ""
info "Checking optional developer tools..."

_missing=()
_tools=(git docker node python3 terraform go rustc ruby php java)

for _t in "${_tools[@]}"; do
  if command -v "$_t" >/dev/null 2>&1; then
    success "$_t"
  else
    warn "$_t — not found"
    _missing+=("$_t")
  fi
done

if [[ ${#_missing[@]} -gt 0 ]]; then
  echo ""
  warn "Missing tools: ${_missing[*]}"
  if [[ "$OS" == "mac" ]]; then
    info "Install missing tools with Homebrew, e.g.:"
    echo "    brew install ${_missing[*]}"
  elif [[ "$OS" == "linux" || "$OS" == "wsl" ]]; then
    info "Install missing tools with apt, e.g.:"
    echo "    sudo apt install -y ${_missing[*]}"
    info "Note: some tools (terraform, rust, node) are better installed via"
    info "their official installers rather than apt."
  fi
fi


# -----------------------------------------------------------------------------
# 6. macOS extras — Homebrew check
# -----------------------------------------------------------------------------
if [[ "$OS" == "mac" ]]; then
  echo ""
  info "Checking Homebrew (macOS)..."
  if command -v brew >/dev/null 2>&1; then
    success "Homebrew found: $(brew --version | head -1)"
  else
    warn "Homebrew not found."
    printf "  Install Homebrew now? [y/N] "; read -r _reply
    if [[ "$_reply" =~ ^[Yy]$ ]]; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      success "Homebrew installed."
    fi
  fi
fi


# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo ""
echo "  ─────────────────────────────────────────"
success "Dotfiles installed successfully."
echo ""
info "Next steps:"
echo "    1. Start a new Zsh session:  zsh"
echo "    2. Or reload in place:       source ~/.zshrc"
echo "    3. Run 'devinfo' to confirm your tool versions."
echo "  ─────────────────────────────────────────"
echo ""
