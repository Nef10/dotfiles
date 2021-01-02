#!/usr/bin/env zsh

step "Setup Project folder"
PROJECTS_DIR="$HOME/Projects"
if [[ -d "${PROJECTS_DIR}" ]]; then
    info "Project folder already exists"
else
    mkdir "${PROJECTS_DIR}"
    success "Project folder created"
    step "Initializing repo"
    (cd "${PROJECTS_DIR}"; repo init -u git@github.com:Nef10/repo-manifest.git | cat)
    success "Initialized repo"
    step "Downloading repositories"
    (cd "${PROJECTS_DIR}"; repo --no-pager sync | cat)
    success "Downloaded repositories"
    step "Checking out branches and downloading git lfs files"
    (cd "${PROJECTS_DIR}"; repo --no-pager forall -p -c 'git checkout $REPO_RREV && git lfs pull' | cat)
    success "Checked out branches and downloaded git lfs files"
fi
