#!/usr/bin/env zsh

step "Updating KeepingYouAwake settings"
zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/keeping_you_awake.csv set

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

step "Setup SSH Keys"
install_ssh_key "id_rsa"
install_ssh_key "id_rsa_ci"
install_ssh_key "id_rsa_ghg"
