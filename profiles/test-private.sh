#!/usr/bin/env zsh

step "Project folder"
PROJECTS_DIR="$HOME/Projects"
if [[ -d "${PROJECTS_DIR}" ]]; then
    success "Project folder exists"
else
    warning "Project folder does not exist"
fi
