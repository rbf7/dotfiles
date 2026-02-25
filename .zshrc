############################################
# UNIVERSAL ZSH CONFIG (WSL + Linux + macOS)
# Portable — no external prompt tools needed
############################################


############################################
# 0. OS DETECTION (extended for WSL)
############################################

case "$OSTYPE" in
  darwin*) _ZSH_OS="mac"   ;;
  linux*)  _ZSH_OS="linux" ;;
  *)       _ZSH_OS="other" ;;
esac

# Detect WSL specifically (still Linux, but useful to know)
if [[ "$_ZSH_OS" == "linux" ]] && grep -qi microsoft /proc/version 2>/dev/null; then
  _ZSH_OS="wsl"
fi


############################################
# 1. BASIC SETUP
############################################

autoload -U colors && colors

EDITOR=vim
bindkey -e   # emacs keybindings (needed for our keybindings below)

ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'


############################################
# 2. PORTABLE DEVELOPER PROMPT (pure Zsh)
#    Works on WSL, Debian, macOS — no installs
#    Shows: git branch+dirty, Python venv,
#    Node (if package.json), Terraform (if *.tf),
#    AWS profile, exit code, time
############################################

autoload -Uz vcs_info
setopt PROMPT_SUBST

zstyle ':vcs_info:*'      enable git
zstyle ':vcs_info:git:*'  formats          ' (%b%u%c)'
zstyle ':vcs_info:git:*'  actionformats    ' (%b|%a)'
zstyle ':vcs_info:git:*'  check-for-changes true
zstyle ':vcs_info:git:*'  unstagedstr      '!'
zstyle ':vcs_info:git:*'  stagedstr        '+'

# Runs before every prompt render
precmd() {
  vcs_info

  # Python — only shown when a virtualenv is active
  _pp=""
  if [[ -n "$VIRTUAL_ENV" ]] && command -v python3 >/dev/null 2>&1; then
    _pp=" %F{yellow}🐍 py:$(python3 --version 2>&1 | awk '{print $2}')%f"
  fi

  # Node — only shown if package.json exists in current directory
  _pn=""
  if [[ -f "$PWD/package.json" ]] && command -v node >/dev/null 2>&1; then
    _pn=" %F{green}⬡ node:$(node --version | sed 's/v//')%f"
  fi

  # Terraform — only shown if .tf files exist in current directory
  _pt=""
  if command -v terraform >/dev/null 2>&1 && ls "$PWD"/*.tf 2>/dev/null | grep -q .; then
    local _tfver
    _tfver=$(terraform version 2>/dev/null | head -1 | awk '{print $2}' | sed 's/v//')
    _pt=" %F{cyan}🏗  tf:${_tfver}%f"
  fi

  # Java — only shown if pom.xml or build.gradle exists in current directory
  _pj=""
  if command -v java >/dev/null 2>&1 && [[ -f "$PWD/pom.xml" || -f "$PWD/build.gradle" ]]; then
    local _javaver
    _javaver=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}')
    _pj=" %F{208}☕ java:${_javaver}%f"
  fi

  # Go — only shown if go.mod exists in current directory
  _pgo=""
  if command -v go >/dev/null 2>&1 && [[ -f "$PWD/go.mod" ]]; then
    local _gover
    _gover=$(go version | awk '{print $3}' | sed 's/go//')
    _pgo=" %F{cyan}🐹 go:${_gover}%f"
  fi

  # Rust — only shown if Cargo.toml exists in current directory
  _prs=""
  if command -v rustc >/dev/null 2>&1 && [[ -f "$PWD/Cargo.toml" ]]; then
    local _rsver
    _rsver=$(rustc --version 2>/dev/null | awk '{print $2}')
    _prs=" %F{208}🦀 rust:${_rsver}%f"
  fi

  # Ruby — only shown if Gemfile exists in current directory
  _prb=""
  if command -v ruby >/dev/null 2>&1 && [[ -f "$PWD/Gemfile" ]]; then
    local _rbver
    _rbver=$(ruby --version 2>/dev/null | awk '{print $2}')
    _prb=" %F{red}💎 ruby:${_rbver}%f"
  fi

  # PHP — only shown if composer.json exists in current directory
  _pphp=""
  if command -v php >/dev/null 2>&1 && [[ -f "$PWD/composer.json" ]]; then
    local _phpver
    _phpver=$(php --version 2>/dev/null | head -1 | awk '{print $2}')
    _pphp=" %F{magenta}🐘 php:${_phpver}%f"
  fi

  # Kotlin — only shown if build.gradle.kts exists in current directory
  _pkt=""
  if command -v kotlin >/dev/null 2>&1 && [[ -f "$PWD/build.gradle.kts" ]]; then
    local _ktver
    _ktver=$(kotlin -version 2>&1 | awk '{print $3}')
    _pkt=" %F{blue}🎯 kotlin:${_ktver}%f"
  fi

  # AWS profile — only shown when AWS_PROFILE env var is set
  _pa=""
  if [[ -n "$AWS_PROFILE" ]]; then
    _pa=" %F{208}☁️  aws:${AWS_PROFILE}%f"
  fi

  # Docker context — only shown if docker is available and context is not default
  _pd=""
  if command -v docker >/dev/null 2>&1; then
    local _dctx
    _dctx=$(docker context show 2>/dev/null)
    [[ -n "$_dctx" && "$_dctx" != "default" ]] && _pd=" %F{33}🐳 ${_dctx}%f"
  fi
}

# ── Prompt layout ──────────────────────────────────────────────
# Line 1: user@host ~/path (git branch!)  🐍 node: tf: java: aws:
# Line 2: ❯  (green on success, red on error)
# Right:  ✓ / ✗<code>  HH:MM
# ───────────────────────────────────────────────────────────────
PROMPT='%F{magenta}%n%f%F{white}@%f%F{blue}%m%f %F{cyan}%~%f%F{red}${vcs_info_msg_0_}%f${_pp}${_pn}${_pt}${_pj}${_pgo}${_prs}${_prb}${_pphp}${_pkt}${_pa}${_pd}
%(?.%F{green}❯%f.%F{red}❯%f) '

RPROMPT='%(?.%F{green}✓%f.%F{red}✗ %?%f) %F{240}%T%f'

# Quick command to print all detected tool versions at once
devinfo() {
  echo ""
  echo "  🖥  OS       : $_ZSH_OS"
  command -v python3  >/dev/null 2>&1 && echo "  🐍 Python   : $(python3 --version 2>&1 | awk '{print $2}')"
  command -v node     >/dev/null 2>&1 && echo "  ⬡  Node     : $(node --version | sed 's/v//')"
  command -v npm      >/dev/null 2>&1 && echo "  📦 npm      : $(npm --version)"
  command -v java     >/dev/null 2>&1 && echo "  ☕ Java     : $(java -version 2>&1 | awk -F '\"' '/version/ {print $2}')"
  command -v terraform>/dev/null 2>&1 && echo "  🏗  Terraform: $(terraform version 2>/dev/null | head -1 | awk '{print $2}')"
  command -v docker   >/dev/null 2>&1 && echo "  🐳 Docker   : $(docker --version | awk '{print $3}' | tr -d ',')"
  command -v aws      >/dev/null 2>&1 && echo "  ☁️  AWS CLI  : $(aws --version 2>&1 | awk '{print $1}' | cut -d/ -f2)"
  command -v go       >/dev/null 2>&1 && echo "  🐹 Go       : $(go version | awk '{print $3}' | sed 's/go//')"
  command -v rustc    >/dev/null 2>&1 && echo "  🦀 Rust     : $(rustc --version | awk '{print $2}')"
  command -v ruby     >/dev/null 2>&1 && echo "  💎 Ruby     : $(ruby --version | awk '{print $2}')"
  command -v php      >/dev/null 2>&1 && echo "  🐘 PHP      : $(php --version | head -1 | awk '{print $2}')"
  command -v kotlin   >/dev/null 2>&1 && echo "  🎯 Kotlin   : $(kotlin -version 2>&1 | awk '{print $3}')"
  command -v git      >/dev/null 2>&1 && echo "  🌿 Git      : $(git --version | awk '{print $3}')"
  echo ""
}


############################################
# 3. HISTORY SETTINGS
############################################

HISTSIZE=200000
SAVEHIST=200000
HISTFILE=~/.zsh_history

setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS


############################################
# 4. ZPLUG INITIALIZATION & SETUP
############################################

_check_zplug() {
    # Always set ZPLUG_HOME first so zplug knows where to store plugins.
    # IMPORTANT: check for init.zsh inside the dir, not just the dir itself.
    # Homebrew can create the directory but leave it incomplete/broken,
    # which causes "Failed to install" errors even though the path exists.
    # Priority: curl/manual install (~/.zplug) → Homebrew Apple Silicon → Intel
    if [[ -z "$ZPLUG_HOME" ]]; then
        if   [ -f "$HOME/.zplug/init.zsh" ];                  then export ZPLUG_HOME="$HOME/.zplug"
        elif [ -f /opt/homebrew/opt/zplug/init.zsh ];         then export ZPLUG_HOME=/opt/homebrew/opt/zplug
        elif [ -f /usr/local/opt/zplug/init.zsh ];            then export ZPLUG_HOME=/usr/local/opt/zplug
        elif [ -f /usr/share/zplug/init.zsh ];                then export ZPLUG_HOME=/usr/share/zplug
        fi
    fi

    # Find the init script — use ZPLUG_HOME if set, else fall back to known paths
    if   [ -f "$ZPLUG_HOME/init.zsh" ];                 then ZPLUG_INIT_PATH="$ZPLUG_HOME/init.zsh"
    elif [ -f /usr/share/zplug/init.zsh ];              then ZPLUG_INIT_PATH=/usr/share/zplug/init.zsh
    else return 1
    fi
    return 0
}

_install_zplug_msg() {
    echo ""
    echo "zplug is not installed. It is required for plugins (history search, autosuggestions, completions)."
    echo ""
    if [ "$_ZSH_OS" = "mac" ]; then
        echo "  brew install zplug"
    elif [ "$_ZSH_OS" = "linux" ] || [ "$_ZSH_OS" = "wsl" ]; then
        echo "  sudo apt update && sudo apt install -y git curl"
    fi
    echo ""
    echo "Universal method:"
    echo "  curl -sL --proto-redir -all,https \\"
    echo "    https://raw.githubusercontent.com/zplug/zplug/master/scripts/install.sh | zsh"
    echo ""
}

if _check_zplug; then
    source "$ZPLUG_INIT_PATH"
else
    _install_zplug_msg
    return 1
fi


############################################
# 5. PLUGIN DEFINITIONS (via zplug)
############################################

# zsh-users plugins — explicit from:github required; without it zplug
# can fail to resolve the source on macOS Homebrew installs
zplug "zsh-users/zsh-autosuggestions",          from:github
zplug "zsh-users/zsh-history-substring-search", from:github
zplug "zsh-users/zsh-syntax-highlighting",      from:github
zplug "zsh-users/zsh-completions",              from:github

# Oh My Zsh plugins
zplug "plugins/command-not-found", from:oh-my-zsh
zplug "plugins/docker",            from:oh-my-zsh
zplug "plugins/aws",               from:oh-my-zsh
zplug "plugins/tmux",              from:oh-my-zsh
zplug "plugins/git",               from:oh-my-zsh
zplug "plugins/npm",               from:oh-my-zsh
zplug "plugins/node",              from:oh-my-zsh
zplug "plugins/python",            from:oh-my-zsh
zplug "plugins/terraform",         from:oh-my-zsh   # tf tab completions
zplug "plugins/gradle",            from:oh-my-zsh
zplug "plugins/mvn",               from:oh-my-zsh


############################################
# 6. PLUGIN INSTALLATION & LOADING
############################################

if ! zplug check --verbose; then
    echo ""
    echo "Installing missing zplug plugins..."
    zplug install
fi

zplug load


############################################
# 7. COMPLETION ENGINE
############################################

autoload -U compinit
zmodload zsh/complist
zstyle ':completion:*' menu select
compinit -C
_comp_options+=(globdots)


############################################
# 8. AWS CLI COMPLETION
############################################

_setup_aws_completion() {
    command -v aws >/dev/null 2>&1 || return 0

    local aws_completer_path
    aws_completer_path=$(command -v aws_completer 2>/dev/null)

    if [ -z "$aws_completer_path" ]; then
        for p in \
          /usr/local/bin/aws_completer \
          /usr/bin/aws_completer \
          /opt/homebrew/bin/aws_completer \
          /usr/local/aws/bin/aws_completer
        do
            [ -x "$p" ] && aws_completer_path="$p" && break
        done
        [ -z "$aws_completer_path" ] && return 0
    fi

    autoload -Uz bashcompinit && bashcompinit
    complete -C "$aws_completer_path" aws
}

_setup_aws_completion


############################################
# 9. KEYBINDINGS
############################################

if zplug check "zsh-users/zsh-history-substring-search"; then
    bindkey -M emacs '^P'    history-substring-search-up
    bindkey -M emacs '^N'    history-substring-search-down
    bindkey -M emacs '\e[A'  history-substring-search-up
    bindkey -M emacs '\e[B'  history-substring-search-down
fi

if zplug check "zsh-users/zsh-autosuggestions"; then
    bindkey '^F' autosuggest-accept
    bindkey '^ ' autosuggest-accept
fi


############################################
# 10. AUTOJUMP SETUP
############################################

_setup_autojump() {
    for f in \
      /usr/share/autojump/autojump.zsh \
      /etc/profile.d/autojump.sh \
      /usr/local/etc/profile.d/autojump.sh \
      /usr/local/share/autojump/autojump.zsh \
      /opt/homebrew/etc/profile.d/autojump.sh \
      /opt/homebrew/share/autojump/autojump.zsh \
      "$HOME/.autojump/etc/profile.d/autojump.sh"
    do
        [ -f "$f" ] && source "$f" && return 0
    done
    return 1
}

if ! _setup_autojump; then
    j() {
        echo ""
        echo "autojump is not installed — 'j' is unavailable."
        echo ""
        case "$_ZSH_OS" in
          mac)         echo "  brew install autojump" ;;
          linux|wsl)   echo "  sudo apt install -y autojump" ;;
          *)           echo "  Install autojump via your package manager." ;;
        esac
        echo ""
    }
fi


############################################
# 11. OPTIONAL PACKAGE HINTS
############################################

_check_packages() {
    local missing=()
    local tools=(autojump tmux docker aws node python3 terraform starship git)

    for t in "${tools[@]}"; do
        command -v "$t" >/dev/null 2>&1 || missing+=("$t")
    done

    [ ${#missing[@]} -eq 0 ] && return 0

    echo ""
    echo "Optional dev tools not installed: ${missing[*]}"
    echo ""
    case "$_ZSH_OS" in
      mac)        echo "  brew install ${missing[*]}" ;;
      linux|wsl)  echo "  sudo apt update && sudo apt install -y ${missing[*]}" ;;
    esac
    echo ""
}

# Uncomment to show package hints on startup:
# _check_packages


############################################
# 12. ALIASES & CUSTOM RESOURCES
############################################

# Load shared aliasrc if it exists
if [ -f "$HOME/aliasrc" ]; then
    source "$HOME/aliasrc"
fi


############################################
# 13. DEVELOPER ALIASES & SHORTCUTS
############################################

# --- Python ---
alias py='python3'
alias pip='pip3'
alias venv='python3 -m venv .venv && source .venv/bin/activate'
alias activate='source .venv/bin/activate'
alias pyver='python3 --version'

# --- Node / React ---
alias nodever='node --version && npm --version'
alias nr='npm run'
alias nrd='npm run dev'
alias nrb='npm run build'
alias nrt='npm run test'
alias nri='npm install'

# --- Terraform ---
alias tf='terraform'
alias tfi='terraform init'
alias tfp='terraform plan'
alias tfa='terraform apply'
alias tfd='terraform destroy'
alias tfver='terraform version'
alias tfw='terraform workspace list'

# --- Java ---
alias javaver='java -version'
alias mvnw='./mvnw'
alias gradlew='./gradlew'

# --- Docker ---
alias dk='docker'
alias dkc='docker compose'
alias dkcu='docker compose up -d'
alias dkcd='docker compose down'
alias dkps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dkclean='docker system prune -f'

# --- Git extras (on top of aliasrc gitpush/gitupdate) ---
alias gs='git status'
alias gl='git log --oneline --graph --decorate -15'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gaa='git add -A'
alias gcm='git commit -m'
alias gd='git diff'
alias gds='git diff --staged'
alias grb='git rebase'

# --- Go ---
alias gorun='go run .'
alias gobuild='go build ./...'
alias gotest='go test ./...'
alias gotidy='go mod tidy'
alias gover='go version'

# --- Rust ---
alias cb='cargo build'
alias cr='cargo run'
alias ct='cargo test'
alias ccheck='cargo check'
alias cfmt='cargo fmt'
alias rustver='rustc --version'

# --- Ruby ---
alias rubyver='ruby --version'
alias be='bundle exec'
alias bi='bundle install'
alias ber='bundle exec rails'
alias rs='bundle exec rails server'
alias rc='bundle exec rails console'

# --- PHP ---
alias phpver='php --version'
alias cpa='composer install'
alias cpu='composer update'
alias cpd='composer dump-autoload'

# --- Utilities ---
# lsof is not installed by default on Debian/WSL — fall back to ss (iproute2)
if command -v lsof >/dev/null 2>&1; then
    alias ports='lsof -i -P -n | grep LISTEN'
else
    alias ports='ss -tlnp'
fi
alias path='echo $PATH | tr ":" "\n"'
alias reload='source ~/.zshrc'
alias zshrc='${=EDITOR} ~/.zshrc'
alias aliasrc='${=EDITOR} ~/aliasrc'
alias myip='curl -s ifconfig.me && echo'


############################################
# 14. STARTUP HELP
############################################

_show_setup_help() {
    cat << 'EOF'

  Zsh developer config loaded.

  Prompt shows (contextually, only when relevant):
    🐍 py:x.x.x    — Python version  (when virtualenv active)
    ⬡  node:x.x.x  — Node version    (when package.json in cwd)
    🏗  tf:x.x.x   — Terraform        (when *.tf files in cwd)
    ☕ java:x.x.x  — Java version     (when pom.xml/build.gradle in cwd)
    🐹 go:x.x.x    — Go version       (when go.mod in cwd)
    🦀 rust:x.x.x  — Rust version     (when Cargo.toml in cwd)
    💎 ruby:x.x.x  — Ruby version     (when Gemfile in cwd)
    🐘 php:x.x.x   — PHP version      (when composer.json in cwd)
    🎯 kotlin:x.x  — Kotlin version   (when build.gradle.kts in cwd)
    ☁️  aws:profile  — AWS profile     (when AWS_PROFILE is set)
    🐳 ctx          — Docker context   (when non-default)

  Quick commands:
    devinfo         — print all installed tool versions
    reload          — reload this config
    j <pattern>     — autojump to a frequent directory

  Keybindings:
    Ctrl+P / ↑      — history search up
    Ctrl+N / ↓      — history search down
    Ctrl+F / Ctrl+Space — accept autosuggestion

EOF
}

_show_setup_help
