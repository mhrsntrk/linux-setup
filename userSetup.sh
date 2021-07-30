#!/bin/bash

sudo apt-get update

# Install neovim and plugin manager and copy configuration file
sudo apt-get -y install neovim

sudo cp -R ~/dotfiles/.config .

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

#Install other tools
sudo apt-get -y install bat

sudo apt-get -y install fd-find

sudo apt-get -y install figlet

# Copy other configuration files

sudo cp ~/dotfiles/.tmux.conf .

sudo cp ~/dotfiles/.gitconfig .

sudo cp ~/dotfiles/modular.flf /usr/share/figlet

#Install zsh and oh-my-zsh and copy configuration file

sudo apt-get -y install zsh

n | sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

sudo cp ~/dotfiles/.zshrc .

git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

git clone https://github.com/spaceship-prompt/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt" --depth=1

ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

mkdir ~/developer

chsh -s $(which zsh)

source .zshrc