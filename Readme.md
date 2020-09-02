# Installing parts

In order to enable / install some part of these dotfiles, execute the setup bash script in the setup directory and pass the parts that you'd like to install.  
Any file not prefixed by `.` inside the setup folder is a valid part.

## Example:

To setup the machine for rust development, run `setup/.setup.sh rust`

# List all installed atom packages

`apm list --installed --bare`

# Cleaning up homebrew

In order to clean up homebrew:

- brew bundle dump
- Remove all unwanted packages in the generated Brewfile then and run
- brew bundle --force cleanup

# Thanks to

- @jessfraz and her [dotfiles repository](https://github.com/jessfraz/dotfiles)
