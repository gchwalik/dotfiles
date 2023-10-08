# functions

out() {
  BLUE='\033[1;34m'
  NONE='\033[0m'

  echo "\n${BLUE}#### $1${NONE}"
}

exists() {
  which $1 &> /dev/null
}

yes() {
  echo "already exists"
}


cat /etc/apt/sources.list.d/vscode.list
cat /etc/apt/sources.list.d/sublime-text.list
cat /etc/apt/sources.list.d/google-chrome.list

# apt up-to-date
out "running 'apt update'"
apt -y update 

out "running 'apt upgrade'"
apt -y upgrade

out "running 'apt autoremove'"
apt -y autoremove

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

# grep "flatpak" .profile &> /dev/null
# if [ $? -ne 0 ]; then
#   printf "\nexport XDG_DATA_DIRS=\"/var/lib/flatpak/exports/share:/home/${USER}/.local/share/flatpak/exports/share:$XDG_DATA_DIRS\"" >> .profile
# fi

out "installing apps"
# mkdir apps
# chown $SUDO_UID:$SUDO_GID apps 
apt install -y \
  nautilus-dropbox \
  keepassxc \

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

out "installing obsidian"
# ls apps/md.obsidian.Obsidian | grep "cannot access"
# if [ $? -ne 0 ]
# then
#   flatpak install -y flathub md.obsidian.Obsidian
# fi
flatpak install -y flathub md.obsidian.Obsidian
echo 'alias obsidian="flatpak run md.obsidian.Obsidian"' >> .bash_aliases

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
mkdir -p ~/code 
cd ~/code 

git clone https://github.com/unfamiliarish/overthewire.git overthewire
git clone https://github.com/unfamiliarish/aoc.git aoc


# start up apps that need interaction 
# chrome, dropbox, 


# restart to have flatpak links for XDG_DATA_DIRS linked correctly
# reboot
