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

###

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

# there's a y/n in here somewhere, but i am not sure where
out "installing docker"
exists docker &> /dev/null
if [ $? -ne 0 ]
then
  apt-get install ca-certificates curl
  install -m 0755 -d /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
  apt-get update

  apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

  # set up docker group so don't have to run `sudo docker``
  groupadd docker
  usermod -aG docker $USER
  newgrp docker
else
  yes
fi

out "installing anki"
exists anki &> /dev/null
apt install zstd
if [ $? -ne 0 ]; then
  printf "please complete the installation steps for anki at:\n" ;
  printf "https://docs.ankiweb.net/platform/linux/installing.html#installing\n\n" ;
  google-chrome "https://docs.ankiweb.net/platform/linux/installing.html#installing"

  read -n1 -p "When you are done, please type 'y' or 'Y' or the script will exit: " doit
  case $doit in
    y|Y) ;;
    *) exit 0 ;;
  esac
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
