#!/bin/bash

# symlink dotfiles to appropriate places

# pulled this script from online
# commented out all dotfiles i'm not using (most)
# they seem useful though so i'm keeping them around

DIR=$HOME/.dotfiles

DOTFILES=(
	# ".bin"
	".bashrc"
	".bash_aliases"
	# ".bash_profile"
	# ".gitconfig"
	".profile"
	# ".tmux.conf"
	# ".xinitrc"
	# ".config/cmus/cmus.theme"
	# ".config/compton.conf"
	# ".config/dunst"
	# ".config/feh"
	# ".config/mpv"
	# ".config/nvim"
	# ".local/share/fonts"
)

for dotfile in "${DOTFILES[@]}"; do
	rm -f "${HOME}/${dotfile}"
	ln -sf "${DIR}/${dotfile}" "${HOME}/${dotfile}"
done