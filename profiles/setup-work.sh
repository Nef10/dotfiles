#!/usr/bin/env zsh

step "Updating Outlook settings"
zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/outlook.csv set
