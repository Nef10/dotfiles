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
SSH_DIR="$HOME/.ssh"
if [[ -d "${SSH_DIR}" ]]; then
    info ".ssh folder already exists"
else
    mkdir "${SSH_DIR}"
fi
install_ssh_key "id_rsa"
install_ssh_key "id_rsa_ci"
install_ssh_key "id_rsa_ghg"

# Helper

function install_ssh_key() {
    if [[ -f "$SSH_DIR/$1" ]]; then
        info "$1 already installed"
    else
        if [[ -z "$OP_SESSION_my" ]]; then
            warning "Logging into 1Password, your credentials are required:"
            eval "$(op signin my.1password.ca steffen.koette@gmail.com)"
        fi
        cp "$DOTFILES_REPO/ssh/publicKeys/$1.pub" "$SSH_DIR/$1.pub"
        op get document "$1" --output $SSH_DIR/$1
        chmod 600 "$SSH_DIR/$1"
        ssh-add -K "$SSH_DIR/$1"
        success "Installed $1"
    fi
}
