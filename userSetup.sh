#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

source "${SCRIPT_DIR}/setupLibrary.sh"

clone_or_update() {
  local repo_url=${1}
  local destination=${2}
  local extra_arg=${3:-}

  if [[ -d "$destination/.git" ]]; then
    git -C "$destination" pull --ff-only
  elif [[ -n "$extra_arg" ]]; then
    git clone "$extra_arg" "$repo_url" "$destination"
  else
    git clone "$repo_url" "$destination"
  fi
}

install_oh_my_zsh() {
  if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  fi

  clone_or_update https://github.com/zsh-users/zsh-autosuggestions "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
  clone_or_update https://github.com/spaceship-prompt/spaceship-prompt.git "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt" '--depth=1'

  if [[ ! -L "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme" ]]; then
    ln -sf "$HOME/.oh-my-zsh/custom/themes/spaceship-prompt/spaceship.zsh-theme" "$HOME/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
  fi
}

copy_repo_assets() {
  install -d -m 755 "$HOME/.config"
  cp "$SCRIPT_DIR/.tmux.conf" "$HOME/.tmux.conf"
  cp "$SCRIPT_DIR/.gitconfig" "$HOME/.gitconfig"
  cp "$SCRIPT_DIR/.zshrc" "$HOME/.zshrc"
  cp "$SCRIPT_DIR/Modular.flf" "$HOME/.local/share/figlet/Modular.flf"
  rm -rf "$HOME/.config/nvim"
  cp -R "$SCRIPT_DIR/.config/nvim" "$HOME/.config/nvim"
  rm -rf "$HOME/.config/opencode"
  cp -R "$SCRIPT_DIR/.config/opencode" "$HOME/.config/opencode"
}

install_lazygit() {
  if ! command -v lazygit &>/dev/null; then
    log 'Installing lazygit...'
    LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": *"v\K[^"]*')
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
    tar xf lazygit.tar.gz lazygit
    sudo install lazygit -D -t /usr/local/bin/
    rm -f lazygit lazygit.tar.gz
  fi
}

install_neovim() {
  if ! command -v nvim &>/dev/null; then
    log 'Installing Neovim from PPA...'
    sudo add-apt-repository -y ppa:neovim-ppa/unstable
    APT_UPDATED=false
    run_apt_update_once
    sudo apt install -y neovim
  fi
}

install_opencode() {
  if ! command -v opencode &>/dev/null; then
    log 'Installing opencode...'
    curl -fsSL https://opencode.ai/install | bash
  fi
}

main() {
  load_config
  ensure_packages bat fd-find figlet git tmux zsh curl gpg pinentry-curses build-essential unzip fzf ripgrep eza jq htop tree gh mosh
  install -d -m 755 "$HOME/.local/share/figlet" "$HOME/developer" "$HOME/.config"

  install_neovim
  install_lazygit
  install_opencode

  install_oh_my_zsh
  copy_repo_assets

  if is_true "$INSTALL_MISE"; then
    "${SCRIPT_DIR}/install/mise.sh"
  fi

  if is_true "$INSTALL_GPG"; then
    "${SCRIPT_DIR}/install/gpg.sh"
  fi

  if [[ "${SHELL:-}" != "$(command -v zsh)" ]]; then
    chsh -s "$(command -v zsh)"
  fi

  log 'User environment bootstrap completed.'
}

main "$@"
