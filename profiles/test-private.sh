#!/usr/bin/env zsh

step "Project folder"
PROJECTS_DIR="$HOME/Projects"
if [[ -d "${PROJECTS_DIR}" ]]; then
    success "Project folder exists"
else
    warning "Project folder does not exist"
fi

step "SSH Keys"
checkFileExists "id_rsa.pub" "$HOME/.ssh/id_rsa.pub"
checkFileExists "id_rsa_ci.pub" "$HOME/.ssh/id_rsa_ci.pub"
checkFileExists "id_rsa_ghg.pub" "$HOME/.ssh/id_rsa_ghg.pub"

step "GPG Keys"
if [[ $(gpg --list-secret-keys 2>/dev/null | grep -w C8AACEF6A67C274C511187F231655A5065AD2BFD) ]] ; then
    success "GPG key installed"
else
    warning "GPG key not installed"
fi

step "AWS"
diff_file "AWS Config" $DOTFILES_REPO/aws/config $HOME/.aws/config
checkFileExists ".aws/credentials" $HOME/.aws/credentials
