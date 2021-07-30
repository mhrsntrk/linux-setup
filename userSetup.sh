#!/bin/bash

sudo apt-get update

# Install neovim and plugin manager and copy configuration file
sudo apt-get install neovim

sudo cp -R dotfiles/.config .

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

#Install other tools
sudo apt-get install bat

sudo apt-get install fd-find

sudo apt-get install figlet

# Copy other configuration files

cp /dotfiles/.tmux.conf .

cp /dotfiles/.gitconfig .

sudo cp /dotfiles/Modular.flf /usr/share/figlet

#Install zsh and oh-my-zsh and copy configuration file
sudo apt-get install zsh

cp dotfiles/.zshrc .

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"