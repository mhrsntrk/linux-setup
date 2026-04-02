# =============================================================================
# ~/.zshrc - Zsh configuration (Linux version)
# =============================================================================

# -----------------------------------------------------------------------------
# PERFORMANCE PROFILING (uncomment both lines to benchmark startup)
# -----------------------------------------------------------------------------
# zmodload zsh/zprof

# -----------------------------------------------------------------------------
# OH MY ZSH SETUP
# -----------------------------------------------------------------------------
export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="nvim"

ZSH_THEME="spaceship"

# Plugins - zsh-syntax-highlighting MUST be last
plugins=(
  zsh-autosuggestions
  transfer
  per-directory-history
  sudo
  z
  zsh-syntax-highlighting
)

# Skip OMZ's compfix security check for faster startup
ZSH_DISABLE_COMPFIX=true

# Completion optimization - prevent duplicate compinit on reload
if [[ -z "$_OMZ_COMPINIT_DONE" ]]; then
  _OMZ_COMPINIT_DONE=1
  if [[ -f ~/.zcompdump ]]; then
    zcompile ~/.zcompdump 2>/dev/null
  fi
fi

source $ZSH/oh-my-zsh.sh

# -----------------------------------------------------------------------------
# LOCALE
# -----------------------------------------------------------------------------
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# -----------------------------------------------------------------------------
# PATH & ENVIRONMENT
# -----------------------------------------------------------------------------
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"
export GPG_TTY=$(tty)

# -----------------------------------------------------------------------------
# FUNCTIONS
# -----------------------------------------------------------------------------

# Kill process running on a specific port
killport() {
  local port="${1:-}"
  
  if [[ -z "$port" ]]; then
    echo "Usage: killport <port>" >&2
    return 1
  fi
  
  if ! [[ "$port" =~ ^[0-9]+$ ]]; then
    echo "Error: Port must be a number" >&2
    return 1
  fi
  
  if ! command -v lsof &>/dev/null; then
    echo "Error: lsof not installed" >&2
    return 1
  fi
  
  local pids
  pids=$(lsof -ti :"$port" 2>/dev/null)
  
  if [[ -z "$pids" ]]; then
    echo "No process found using port $port"
    return 0
  fi
  
  echo "Found PID(s) on port $port: $pids"
  echo "$pids" | xargs kill 2>/dev/null
  
  local pids_still
  pids_still=$(lsof -ti :"$port" 2>/dev/null)
  
  if [[ -z "$pids_still" ]]; then
    echo "Process(es) terminated successfully!"
    return 0
  fi
  
  echo "Force killing remaining PID(s): $pids_still"
  echo "$pids_still" | xargs kill -9 2>/dev/null
  echo "Done!"
}

# Attach to or create tmux session
tmuxon() {
  local session_name="01101101"
  tmux attach -t "$session_name" 2>/dev/null && return
  tmux new -s "$session_name"
}

# -----------------------------------------------------------------------------
# ALIASES
# -----------------------------------------------------------------------------

# System
alias c='clear'
alias e='exit'

# Git
alias ga='git add'
alias gc='git commit -m'
alias gs='git status'
alias gp='git pull'
alias gf='git fetch'

# Development
alias vim="nvim"
alias dev="cd ~/developer"
alias zshrc="$EDITOR ~/.zshrc"
alias zshreload='source ~/.zshrc'

# Networking
alias myip='curl -s http://ipecho.net/plain; echo'

# eza aliases (if installed)
if command -v eza &>/dev/null; then
  alias ls='eza --all --long --group-directories-first --icons --header --time-style long-iso --git --hyperlink --color-scale=size --octal-permissions --binary --no-permissions'
  alias lt='eza --tree --level=2 --long --icons'
else
  alias ls='ls -la --color=auto'
  alias lt='tree -L 2'
fi

# -----------------------------------------------------------------------------
# TOOL INTEGRATIONS
# -----------------------------------------------------------------------------

# fzf
if command -v fzf &>/dev/null; then
  if fzf --zsh &>/dev/null 2>&1; then
    eval "$(fzf --zsh)"
  elif [[ -f /usr/share/doc/fzf/examples/completion.zsh ]]; then
    source /usr/share/doc/fzf/examples/completion.zsh
    source /usr/share/doc/fzf/examples/key-bindings.zsh
  fi
fi

# mise (if installed)
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
fi

# -----------------------------------------------------------------------------
# SPACESHIP PROMPT CONFIGURATION
# -----------------------------------------------------------------------------
SPACESHIP_PROMPT_ADD_NEWLINE="true"
SPACESHIP_CHAR_SYMBOL="\uf0e7"
SPACESHIP_CHAR_SUFFIX=("  ")
SPACESHIP_CHAR_COLOR_SUCCESS="yellow"
SPACESHIP_PROMPT_DEFAULT_PREFIX="$USER"
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW="true"
SPACESHIP_USER_SHOW="true"
SPACESHIP_TIME_SHOW="true"
SPACESHIP_PROMPT_ASYNC="true"

# -----------------------------------------------------------------------------
# PERFORMANCE PROFILING OUTPUT (uncomment both lines to benchmark startup)
# -----------------------------------------------------------------------------
# zprof
