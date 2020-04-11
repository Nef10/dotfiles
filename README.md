# Dotfiles

This repository contains scripts to bootstrap my Mac.

It does:
- configure MacOS settings, as well as settings of system software
- install software via brew, including applications via cask and mas
- configure my dotfiles for various tools (git, ssh, zsh)
- configure VSCode, and install extensions

This work was inspried by https://github.com/sam-hosseini/dotfiles and https://github.com/mathiasbynens/dotfiles. The terminal theme is based on https://github.com/nathanbuchar/atom-one-dark-terminal. It is intended for Macs running on Catalina with zsh as shell.

## Use

### Install

To install use the following line at own risk: (Please don't actually do this - it is not good practice to just execute random code from the internet - and it uses my settings which you probably want to adjust beforehand - at least the git user)
```
curl --silent https://raw.githubusercontent.com/Nef10/dotfiles/master/setup-mac-os.sh | zsh
```

### Tracking changes and updates

To update your machine with the latest improvements done, execute:
```
update_dotfiles
```

It will check for new commits in the repo, pull them and execute the bootstrap again. This will override any changes you made to certain settings. To reset your changes even though no new commits are present, run with the `--force` flag. To check which changes you made, which might be overridden, execute:
```
diff_dotfiles_setup
```




