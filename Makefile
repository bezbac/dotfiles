symlink_gitconfig:
	ln -s ~/Documents/Dev/dotfiles/.gitconfig ~/.gitconfig

symlink_fish:
	ln -s ~/Documents/Dev/dotfiles/fish/functions ~/.config/fish/functions
	ln -s ~/Documents/Dev/dotfiles/fish/completions ~/.config/fish/completions
	ln -s ~/Documents/Dev/dotfiles/fish/config.fish ~/.config/fish/config.fish
	ln -s ~/Documents/Dev/dotfiles/fish/conf.d ~/.config/fish/conf.d

symlink_omf:
	# Symlink oh my fish
	ln -s ~/Documents/Dev/dotfiles/omf ~/.config/omf

symlink_atom:
	ln -s ~/Documents/Dev/dotfiles/atom/init.coffee ~/.atom/init.coffee
	ln -s ~/Documents/Dev/dotfiles/atom/keymap.cson ~/.atom/keymap.cson
	ln -s ~/Documents/Dev/dotfiles/atom/packages.json ~/.atom/packages.json
	ln -s ~/Documents/Dev/dotfiles/atom/settings.json ~/.atom/settings.json
	ln -s ~/Documents/Dev/dotfiles/atom/snippets.json ~/.atom/snippets.json
	ln -s ~/Documents/Dev/dotfiles/atom/style.less ~/.atom/style.less

symlink_vscode:
	ln -s  ~/Documents/Dev/dotfiles/vscode/settings.json ~/Library/Application\ Support/Code/User/settings.json
	ln -s  ~/Documents/Dev/dotfiles/vscode/snippets/ ~/Library/Application\ Support/Code/User

symlink_editorconfig:
	ln -s ~/Documents/Dev/dotfiles/.editorconfig ~/.editorconfig

symlink_hyper:
	ln -s ~/Documents/Dev/dotfiles/.hyper-plugins/local ~/.hyper_plugins/local
	ln -s ~/Documents/Dev/dotfiles/.hyper.js ~/.hyper.js

install_homebrew:
	./homebrew/brew.sh

install:
	# Install tools & applications
	make install_homebrew

	# Symlink configurations
	make symlink_gitconfig
	make symlink_fish
	make symlink_omf
	make symlink_atom
	make symlink_editorconfig
	make symlink_hyper