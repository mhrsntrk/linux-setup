# dotfiles

# Installation

SSH into your server and install git if it is not installed:
```bash
sudo apt-get update
sudo apt-get install git
```

Clone this repository into your home directory:
```bash
git clone https://github.com/mhrsntrk/dotfiles.git
```

Run the setup script
```bash
bash dotfiles/setup.sh
```

When the setup is completed, switch created user.
```bash
su - {username}
```

Clone the repo again.
```bash
cd ~
git clone https://github.com/mhrsntrk/dotfiles.git
```

Run the user setup script
```bash
bash dotfiles/userSetup.sh
```
