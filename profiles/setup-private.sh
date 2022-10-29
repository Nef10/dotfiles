#!/usr/bin/env zsh

step "Updating KeepingYouAwake settings"
zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/keeping_you_awake.csv set

step "Setup SSH Keys"
SSH_DIR="$HOME/.ssh"
cp "$DOTFILES_REPO/ssh/publicKeys/id_rsa.pub" "$SSH_DIR/id_rsa.pub"
cp "$DOTFILES_REPO/ssh/publicKeys/id_rsa_ci.pub" "$SSH_DIR/id_rsa_ci.pub"
cp "$DOTFILES_REPO/ssh/publicKeys/id_rsa_ghg.pub" "$SSH_DIR/id_rsa_ghg.pub"

step "Setup GPG Key"
if [[ $(gpg --list-secret-keys 2>/dev/null | grep -w C8AACEF6A67C274C511187F231655A5065AD2BFD) ]] ; then
    info "GPG key already installed"
else
    opsignin
    temp_file=$(mktemp)
    trap "rm -f $temp_file" 0 2 3 15
    op document get "private.key" --output $temp_file
    gpg --import --batch $temp_file &> /dev/null
    expect -c 'spawn gpg --edit-key C8AACEF6A67C274C511187F231655A5065AD2BFD trust quit; send "5\ry\r"; expect eof' &> /dev/null
    success "Installed GPG Key"
    rm -f $temp_file
fi

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

step "AWS"
if [[ ! -d $HOME/.aws ]]; then
    mkdir $HOME/.aws
fi
copy_file "AWS Config" $DOTFILES_REPO/aws/config $HOME/.aws/config
touch $HOME/.aws/credentials
