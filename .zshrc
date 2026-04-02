export ZSH="$HOME/.oh-my-zsh"
export EDITOR="nvim"
export VISUAL="nvim"
export LC_CTYPE="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

# Add local bin to PATH (for mise and other user-installed tools)
export PATH="$HOME/.local/bin:$PATH"

if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

ZSH_THEME="spaceship"
plugins=(git zsh-autosuggestions sudo z)

source "$ZSH/oh-my-zsh.sh"

killport() {
  local pid
  pid="$(lsof -ti ":$1" || true)"
  if [[ -n "$pid" ]]; then
    printf 'PORT: %s\nPID: %s\n' "$1" "$pid"
    kill -9 "$pid"
  else
    printf 'No process found on port %s\n' "$1"
  fi
}

SPACESHIP_PROMPT_ADD_NEWLINE="true"
SPACESHIP_CHAR_SYMBOL="⚡"
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
alias myip='curl -4 ifconfig.me; printf "\\n"'
alias dev='cd ~/developer'
alias copyssh='xclip -sel clip < ~/.ssh/id_ed25519.pub 2>/dev/null || wl-copy < ~/.ssh/id_ed25519.pub'
alias vim='nvim'

if [[ -f "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme" ]]; then
  source "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
fi
