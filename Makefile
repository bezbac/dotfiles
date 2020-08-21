symlink_gitconfig:
	ln -s ~/Documents/Dev/dotfiles/.gitconfig ~/.gitconfig

symlink_starship:
	ln -s ~/Documents/Dev/dotfiles/starship.toml ~/.config/starship.toml

symlink_aliases:
	ln -s ~/Documents/Dev/dotfiles/.aliases ~/.aliases

symlink_fish:
	ln -s ~/Documents/Dev/dotfiles/fish/functions ~/.config/fish/functions
	ln -s ~/Documents/Dev/dotfiles/fish/completions ~/.config/fish/completions
	ln -s ~/Documents/Dev/dotfiles/fish/config.fish ~/.config/fish/config.fish
	ln -s ~/Documents/Dev/dotfiles/fish/conf.d ~/.config/fish/conf.d

symlink_zsh:
	sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
	
	ln -s ~/Documents/Dev/dotfiles/.zshrc ~/.zshrc

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

symlink_nvim:
	ln -s ~/Documents/Dev/dotfiles/nvim ~/.config/nvim

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