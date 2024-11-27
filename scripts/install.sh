#!/bin/bash

# functions

out() {
  BLUE='\033[1;34m'
  NONE='\033[0m'

  printf "\n${BLUE}#### $1${NONE}\n"
}

exists() {
  which $1 &> /dev/null
}

yes() {
  echo "already exists"
}

# apt up-to-date
out "running 'apt update'"
apt -y update 

out "running 'apt upgrade'"
apt -y upgrade

out "running 'apt autoremove'"
apt -y autoremove

# --- 

out "creating dotfile symlinks"

bash ./scripts/symlinks.sh

# ---

out "installing tools"
apt install -y \
  git \
  flatpak \
  ruby-full \
  vim \
  wget \

gem install rails

# need to restart for flatpak to be added to env var XDG_DATA_DIRS
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# installing pyenv
apt install -y make build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev
curl https://pyenv.run | bash

echo -e 'export PYENV_ROOT="$HOME/.pyenv"\nexport PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo -e 'eval "$(pyenv init --path)"\neval "$(pyenv init -)"' >> ~/.zshrc
exec "$SHELL"

# python3, latest as of 2024-06-09
pyenv install 3.12.4
pyenv global 3.12.4

# node and npm

### default script from: https://nodejs.org/en/download/package-manager/
### will get outdated
# installs nvm (Node Version Manager)
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# download and install Node.js (you may need to restart the terminal)
nvm install 20

# verifies the right Node.js version is in the environment
node -v # should print `v20.17.0`

# verifies the right npm version is in the environment
npm -v # should print `10.8.2`
###

# tmux
apt install tmux

# ---
out "pip installations"

python -m pip install django

# ---

out "installing apps"

apt install -y \
  nautilus-dropbox \
  keepassxc \

flatpak install -y flathub md.obsidian.Obsidian
# echo 'alias obsidian="flatpak run md.obsidian.Obsidian"' >> .bash_aliases

# assuming that $HOME/.config exists - may or may not be true
# have to install ssh before can run git commands

out "configuring settings"

out "ssh"

mkdir -p $HOME/.ssh
if [ ! -f $HOME/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -C "gcchwalik@gmail.com"
  eval "$(ssh-agent -s)"
  ssh-add $HOME/.ssh/id_ed25519
fi

out "github: global config & public key"

git config --global user.email "89762294+gchwalik@users.noreply.github.com"
git config --global user.name "gchwalik"
git config --global core.editor vim

printf "log into github and save this key to your account:\n"

cat $HOME/.ssh/id_ed25519.pub

out "next script"
printf "then run sudo -E ./scripts/install-apps-and-repos.sh\n"

