#!/usr/bin/env zsh

step "KeepingYouAwake Settings"
zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/keeping_you_awake.csv

step "Project folder"
PROJECTS_DIR="$HOME/Projects"
if [[ -d "${PROJECTS_DIR}" ]]; then
    success "Project folder exists"
else
    warning "Project folder does not exist"
fi
