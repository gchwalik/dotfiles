# install git

apt -y update 
apt -y upgrade
apt -y autoremove

apt install -y git

git clone https://github.com/unfamiliarish/dotfiles.git ~/.dotfiles
