# Dotfiles ✨

Welcome to my personal dotfiles repository! Here you'll find the well-thought-out and tested configurations I use every day to make my development environment more efficient and enjoyable. 🏡

## Notes

Some of the configuration assumes this repository is saved locally under `~/dev/repos/bezbac/dotfiles`. In case you fork the repository, make sure to update the paths.

## Common things

#### My steps of setting up a new machine

1. Install 1Password
2. Setup Apple iCloud
3. Execute the ./install.sh from this repository

#### Cleaning up the homebrew

In order to clean up homebrew:

- `brew bundle dump`
- Remove all unwanted packages in the generated Brewfile then and run
- `brew bundle --force cleanup`

# Thanks to

I'd like to give a big thanks to the open-source community and everyone who shared dotfiles and ideas. Your work inspired and helped me create mine.

If you find these dotfiles useful or have suggestions, feel free to reach out.

Here are some repos I found helpful on my path:

- [dotfiles repository](https://github.com/jessfraz/dotfiles) of @jessfraz
- [dotfiles repository](https://github.com/driesvints/dotfiles) of @driesvints
- [dotfiles repository](https://github.com/mathiasbynens/dotfiles) of @mathiasbynens
