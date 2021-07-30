#!/bin/bash

sudo apt-get update

#Install zsh and oh-my-zsh and copy configuration file
sudo apt-get install zsh    

sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

cp dotfiles/.zshrc .

# Install neovim and plugin manager and copy configuration file
sudo apt-get install neovim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

cp -R dotfiles/.config .

#Install other tools
sudo apt-get install bat

sudo apt-get install fd-find

sudo apt-get install figlet

# Copy other configuration files

cp /dotfiles/.tmux.conf .

cp /dotfiles/.gitconfig .

cp /dotfiles/Modular.flf /usr/share/figlet


