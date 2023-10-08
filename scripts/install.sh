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
  vim \
  wget \

git config --global user.email "89762294+unfamiliarish@users.noreply.github.com"
git config --global user.name "unfamiliarish"

# need to restart for flatpak to be added to env var XDG_DATA_DIRS
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

# ---

out "installing apps"

apt install -y \
  nautilus-dropbox \
  keepassxc \

flatpak install -y flathub md.obsidian.Obsidian
# echo 'alias obsidian="flatpak run md.obsidian.Obsidian"' >> .bash_aliases

out "installing chrome"
exists google-chrome &> /dev/null
if [ $? -ne 0 ]
then
  wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
  dpkg -i google-chrome-stable_current_amd64.deb
  remove -f *google*
else
  yes
fi

out "installing sublime"
exists subl &> /dev/null
if [ $? -ne 0 ] 
then 
  wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/sublimehq-archive.gpg > /dev/null
  echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list
  sudo apt update
  sudo apt install sublime-text
else 
  yes
fi

out "installing vscode"
exists code &> /dev/null
which code
if [ $? -ne 0 ]
then 
  wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
  install -o root -g root -m 644 packages.microsoft.gpg /etc/apt/trusted.gpg.d/
  sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list'
  rm -f packages.microsoft.gpg
  sudo apt update
  sudo apt install code
else
  yes
fi
 
# code repos setup 

mkdir -p $HOME/code

# i'm not sure this repo is really neccessary

if [ ! -d $HOME/code/overthewire ]; then
  git clone git@github.com:unfamiliarish/overthewire.git $HOME/code/overthewire
fi

if [ ! -d $HOME/code/aoc ]; then
  git clone git@github.com:unfamiliarish/aoc.git $HOME/code/aoc
fi

mkdir -p $HOME/.obsidian

if [ ! -d $HOME/.obsidian/my-brain ]; then
  git clone git@github.com:unfamiliarish/obsidian--my-brain.git $HOME/.obsidian/my-brain
fi

# config 

# assuming that $HOME/.config exists - may or may not be true

out "configuring settings"

out "ssh"

mkdir -p $HOME/.ssh
if [ ! -f $HOME/.ssh/id_ed25519 ]; then
  ssh-keygen -t ed25519 -C "gcchwalik+unfamiliarish@gmail.com"
  eval "$(ssh-agent -s)"
  ssh-add $HOME/.ssh/id_ed25519
fi

# copy sublime user settings and keymaps into sublime
out "sublime preferences"
cp $HOME/.dotfiles/preferences/sbl/* $HOME/.config/sublime-text/Packages/User/

# start up apps that need interaction
# dropbox should open by default after prev install complete

# open a bunch of chrome tabs
# - log in to chrome
# - enable chrome sync
# - manage chrome extensions
# - set keyboard shortcut "enter zapper mode"
# - confirm can access email
# - save ssh key into GH (will need to login first as unfamiliarish)
out "chrome tabs for setup"

google-chrome \
  "https://accounts.google.com/" \
  "https://mail.google.com/" \
  "https://github.com/settings/keys" \
  &>/dev/null &

out "cannot create chrome:// hyperlinks in all shells"
# https://stackoverflow.com/questions/53694504/open-chrome-urls-from-the-command-line
# https://github.com/jordansissel/xdotool/
out "printing links - click on to open in browser"
echo "chrome://settings/syncSetup"
echo "chrome://extensions/"
echo "chrome://extensions/shortcuts"

# restart to have flatpak links for XDG_DATA_DIRS linked correctly
# reboot
