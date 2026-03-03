#!/usr/bin/env bash
set -euo pipefail

mode="${1:-}"

usage() {
  cat <<USAGE
Usage:
  ./scripts/zsh-history-preview.sh 1   # Ctrl+R fuzzy history (fzf)
  ./scripts/zsh-history-preview.sh 2   # Popup history widget on Ctrl+Space (fzf)
USAGE
}

if [[ -z "$mode" || ("$mode" != "1" && "$mode" != "2") ]]; then
  usage
  exit 1
fi

if ! command -v zsh >/dev/null 2>&1; then
  echo "zsh is not installed."
  exit 1
fi

tmpdir="$(mktemp -d)"
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT

cat > "$tmpdir/.zshrc" <<'ZSHRC'
autoload -Uz colors && colors
PROMPT='%F{cyan}[history-preview]%f %~ %# '

print -P "%F{yellow}Temporary test shell loaded (no changes written to your real .zshrc).%f"
print "Type some commands, then test the history keybindings."
print "Exit this shell to return."

# Make sure history works in this temporary shell.
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000
setopt HIST_IGNORE_DUPS
setopt SHARE_HISTORY
ZSHRC

if [[ "$mode" == "1" ]]; then
  cat >> "$tmpdir/.zshrc" <<'ZSHRC'
print -P "%F{green}Mode 1: Ctrl+R fuzzy history (fzf)%f"
if command -v fzf >/dev/null 2>&1; then
  # Try common distro install paths first.
  if [[ -f /usr/share/fzf/key-bindings.zsh ]]; then
    source /usr/share/fzf/key-bindings.zsh
  elif [[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  elif [[ -f "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh"
  fi

  # Fallback: provide our own Ctrl+R widget if no binding was loaded.
  if ! bindkey | grep -q '"^R"'; then
    fzf_ctrl_r_widget() {
      local selected
      selected=$(fc -rl 1 | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//' | awk '!seen[$0]++' | fzf --height 40% --reverse --prompt='history> ')
      if [[ -n "$selected" ]]; then
        LBUFFER+="$selected"
      fi
      zle redisplay
    }
    zle -N fzf_ctrl_r_widget
    bindkey '^R' fzf_ctrl_r_widget
  fi

  print "Try: press Ctrl+R and type part of a previous command."
else
  print -P "%F{red}fzf not found. Install it first (e.g. sudo apt install fzf).%f"
fi
ZSHRC
else
  cat >> "$tmpdir/.zshrc" <<'ZSHRC'
print -P "%F{green}Mode 2: Popup history widget on Ctrl+Space (fzf)%f"
if command -v fzf >/dev/null 2>&1; then
  fzf_history_widget() {
    local selected
    selected=$(fc -rl 1 | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//' | awk '!seen[$0]++' | fzf --height 40% --reverse --prompt='history> ')
    if [[ -n "$selected" ]]; then
      LBUFFER+="$selected"
    fi
    zle redisplay
  }
  zle -N fzf_history_widget
  bindkey '^ ' fzf_history_widget
  print "Try: press Ctrl+Space to open history list."
else
  print -P "%F{red}fzf not found. Install it first (e.g. sudo apt install fzf).%f"
fi
ZSHRC
fi

ZDOTDIR="$tmpdir" zsh -i