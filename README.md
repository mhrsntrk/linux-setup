# dotfiles

# Installation
SSH into your server and install git if it is not installed:
```bash
sudo apt-get update
sudo apt-get install git
```

Clone this repository into your home directory:
```bash
cd ~
git clone https://github.com/mhrsntrk/dotfiles.git
```

Run the setup script
```bash
cd dotfiles
bash setup.sh
```

When setup completed, switch created user.
```bash
su - mhrsntrk
```

Clone the repository again to install & copy remaining files.
```bash
cd ~
git clone https://github.com/mhrsntrk/dotfiles.git
```

Run the user setup script
```bash
bash dotfiles/userSetup.sh
```

open neovim and install the plugins
```bash
nvim
```

```nvim
:PlugInstall
:CocInstall coc-marketplace
:CocInstall coc-json coc-prettier coc-html coc-css coc-json coc-tailwindcss coc-tsserver coc-graphql coc-spell-checker coc-yaml coc-eslint
```

