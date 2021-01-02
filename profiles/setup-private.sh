#!/usr/bin/env zsh

step "Setup Project folder"
PROJECTS_DIR="$HOME/Projects"
if [[ -d "${PROJECTS_DIR}" ]]; then
    info "Project folder already exists"
else
    mkdir "{$PROJECTS_DIR}"
    success "Project folder created"
    step "Initializing repo"
    (cd "${PROJECTS_DIR}"; repo init -u git@github.com:Nef10/repo-manifest.git)
    success "Initialized repo"
    step "Downloading repositories"
    (cd "${PROJECTS_DIR}"; repo sync)
    success "Downloaded repositories"
    step "Checking out branches and downloading git lfs files"
    (cd "${PROJECTS_DIR}"; repo forall -p -c 'git checkout $REPO_RREV && git lfs pull')
    success "Checked out branches and downloaded git lfs files"
fi
