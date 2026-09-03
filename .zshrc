# ~/.zshrc — reconstructed 2026-06-14 from live session + Claude shell snapshot.
# oh-my-zsh removed; aphrodite prompt runs standalone. Paths reflect your current
# migrated setup (SSD bun, postgresql@17, ~/.nvm). Old oh-my-zsh file: ~/.zshrc.bck

# ---------------------------------------------------------------------------
# History
# ---------------------------------------------------------------------------
HISTFILE="$HOME/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt extendedhistory
setopt histfindnodups
setopt histignorealldups
setopt histignoredups
setopt histignorespace
setopt histreduceblanks
setopt incappendhistory
setopt sharehistory
setopt nohashdirs
setopt promptsubst

# ---------------------------------------------------------------------------
# Environment
# ---------------------------------------------------------------------------
export EDITOR=vim

# Toolchains / SDKs
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
export ANDROID_HOME=/Volumes/ssd/andorid
export DOTNET_ROOT=/Volumes/ssd/dotnet
export NUGET_PACKAGES=/Volumes/ssd/dotnet/nuget-packages
export DOTNET_CLI_TELEMETRY_OPTOUT=1
export GOCACHE=/Volumes/ssd/go/build
export GOMODCACHE=/Volumes/ssd/go/mod
export OLLAMA_MODELS=/Volumes/ssd/ollama-models
export SDKMAN_DIR=/Users/apo/.sdkman
export BUN_INSTALL=/Volumes/ssd/bun
export PNPM_HOME=/Volumes/ssd/pnpm-global/bin
export NVM_DIR=/Users/apo/.nvm
export NPM_CONFIG_CACHE=/Volumes/ssd/npm-cache

# Homebrew (caches relocated to the SSD volume)
export HOMEBREW_CACHE=/Volumes/ssd/brew/cache
export HOMEBREW_LOGS=/Volumes/ssd/brew/logs
export HOMEBREW_TEMP=/Volumes/ssd/brew/temp
export HOMEBREW_CASK_OPTS=--appdir=/Volumes/ssd/Applications
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1

# ---------------------------------------------------------------------------
# PATH (deduped; typeset -U drops later duplicates)
# ---------------------------------------------------------------------------
typeset -U path
path=(
  "$HOME/.local/bin"
  "$JAVA_HOME/bin"
  /opt/homebrew/opt/postgresql@17/bin
  "$BUN_INSTALL/bin"
  /Volumes/ssd/dotnet
  /Volumes/ssd/dotnet/tools
  /Volumes/ssd/dev/flutter/bin
  /opt/homebrew/bin
  /opt/homebrew/sbin
  "$PNPM_HOME"
  "$HOME/.cargo/bin"
  "$HOME/.orbstack/bin"
  /Applications/Obsidian.app/Contents/MacOS
  "$ANDROID_HOME/platform-tools"
  "$ANDROID_HOME/emulator"
  "$ANDROID_HOME/tools"
  "$HOME/go/bin"
  "$HOME/.lmstudio/bin"
  $path
)

# ---------------------------------------------------------------------------
# Completion
# ---------------------------------------------------------------------------
[ -d "$HOME/.docker/completions" ] && fpath=("$HOME/.docker/completions" $fpath)
autoload -Uz compinit && compinit

# ---------------------------------------------------------------------------
# Tooling init
# ---------------------------------------------------------------------------
# nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# bun
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# zoxide (provides `z`; aliased to `j` below)
command -v zoxide >/dev/null 2>&1 && eval "$(zoxide init zsh)"

# zsh-autosuggestions
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# ---------------------------------------------------------------------------
# Aliases
# ---------------------------------------------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias c=clear
alias h='cd ~'
alias v=nvim
alias lg=lazygit
alias j=z

# git
alias ga='git add'
alias gc='git commit -m'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gsw='git switch'
alias gf='git fetch'
alias gp='git pull'
alias gmp='git checkout main && git pull'
alias gs='git status'

# dotfiles (bare repo at ~/.dotfiles, work-tree is $HOME)
alias dot='git --git-dir=$HOME/.dotfiles --work-tree=$HOME'
alias dots='dot status'
alias dota='dot add'
alias dotc='dot commit -m'
alias dotp='dot push'
alias dotl='dot log --oneline -20'
# edit a file normally, then: dota ~/.zshrc && dotc "tweak" && dotp

# claude
alias cc='claude --dangerously-skip-permissions'
alias cc45='claude --effort max --model claude-opus-4-5-20251101 --dangerously-skip-permissions'
alias cr=tuicr
alias nte='cd /Volumes/ssd/obsidian/obsidian/0003_CLI/ && nvim'
# ---------------------------------------------------------------------------
# Prompt (aphrodite, standalone)
# ---------------------------------------------------------------------------
[ -f "$HOME/.zsh/aphrodite.zsh-theme" ] && source "$HOME/.zsh/aphrodite.zsh-theme"


# secrets live in ~/.zshrc.local (never tracked by the dotfiles repo)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

alias claudex='ANTHROPIC_BASE_URL=http://127.0.0.1:8317 \
ANTHROPIC_AUTH_TOKEN=$CLAUDEX_AUTH_TOKEN \
ANTHROPIC_DEFAULT_HAIKU_MODEL=gpt-5.6-sol \
CLAUDE_CODE_SUBAGENT_MODEL=gpt-5.6-sol \
CLAUDE_CODE_ALWAYS_ENABLE_EFFORT=1 \
CLAUDE_CODE_MAX_TOOL_USE_CONCURRENCY=3 \
ENABLE_TOOL_SEARCH=false \
claude --model gpt-5.6-sol --dangerously-skip-permissions'
# ---------------------------------------------------------------------------
# sdkman (MUST stay at the very end per sdkman convention)
# ---------------------------------------------------------------------------
[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ] && source "$SDKMAN_DIR/bin/sdkman-init.sh"

# YuzuDraw CLI
export PATH="/Users/apo/.yuzudraw/bin:$PATH"

if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
