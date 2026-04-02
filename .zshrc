export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="nvim"
export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Add local bin to PATH (for mise and other user-installed tools)
export PATH="$HOME/.local/bin:$HOME/.opencode/bin:$PATH"

# Activate mise if installed
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

# Activate fzf if installed
if command -v fzf >/dev/null 2>&1; then
  eval "$(fzf --zsh 2>/dev/null || true)"
fi

ZSH_THEME="spaceship"
plugins=(zsh-autosuggestions sudo z)

source "$ZSH/oh-my-zsh.sh"

killport() {
  if [ -z "$1" ]; then
    echo "Usage: killport <port>"
    return 1
  fi
  local port="$1"
  local pids
  pids=$(lsof -ti :"$port" 2>/dev/null)
  if [ -z "$pids" ]; then
    echo "No process found running port $port"
    return 0
  fi
  echo "Found PID(s) using port $port: $pids"
  echo "$pids" | xargs kill 2>/dev/null
  sleep 1
  local pids_still
  pids_still=$(lsof -ti :"$port" 2>/dev/null)
  if [ -z "$pids_still" ]; then
    echo "Process(es) terminated successfully!"
    return 0
  fi
  echo "Force killing remaining PID(s): $pids_still"
  echo "$pids_still" | xargs kill -9 2>/dev/null
  echo "Done!"
}

tmuxon() {
  tmux attach -t main 2>/dev/null && return
  tmux new -s main
}

SPACESHIP_PROMPT_ADD_NEWLINE="true"
SPACESHIP_CHAR_SYMBOL="\uf0e7"
SPACESHIP_CHAR_SUFFIX=("  ")
SPACESHIP_CHAR_COLOR_SUCCESS="yellow"
SPACESHIP_PROMPT_DEFAULT_PREFIX="$USER"
SPACESHIP_PROMPT_FIRST_PREFIX_SHOW="true"
SPACESHIP_USER_SHOW="true"
SPACESHIP_TIME_SHOW="true"

alias c='clear'
alias e='exit'
alias gp='git pull'
alias gf='git fetch'
alias zshrc='$EDITOR ~/.zshrc'
alias zshreload='source ~/.zshrc'
alias myip='curl -4 ifconfig.me; printf "\n"'
alias dev='cd ~/developer'
alias vim='nvim'

# eza aliases (if installed)
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --all --long --group-directories-first --icons --header --time-style long-iso --git --color-scale=size'
  alias lt='eza --tree --level=2 --long'
fi

if [[ -f "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme" ]]; then
  source "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
fi

export GPG_TTY=$(tty)
