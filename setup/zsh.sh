#!/bin/bash
require homebrew starship aliases autojump thefuck

if command -v zsh -V &> /dev/null
then
    echo "zsh seems to be already installed"
else
    echo "Installing zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

	git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
	git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

if [ -e ~/.zshrc ]
then
    echo "zsh config seems to be already symlinked"
else
    echo "Symlinking zsh config"
    ln -s $DOTFILE_ROOT/.zshrc ~/.zshrc
fi