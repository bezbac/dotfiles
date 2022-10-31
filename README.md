# Install order on a new machine

1. Install 1Password
2. Setup Apple iCloud
3. Execute the ./install.sh from this repository

# Cleaning up homebrew

In order to clean up homebrew:

- brew bundle dump
- Remove all unwanted packages in the generated Brewfile then and run
- brew bundle --force cleanup

# Thanks to

- @jessfraz and their [dotfiles repository](https://github.com/jessfraz/dotfiles)
- @driesvints and their [dotfiles repository](https://github.com/driesvints/dotfiles)
- @mathiasbynens and their [dotfiles repository](https://github.com/mathiasbynens/dotfiles)
