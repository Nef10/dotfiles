#!/usr/bin/env zsh

main() {
    UPDATE=1
    step "Checking for updates of dotfiles repository"
    git -C $HOME/.dotfiles fetch &> /dev/null
    if [ $(git -C $HOME/.dotfiles rev-parse HEAD) '==' $(git -C $HOME/.dotfiles rev-parse @{u}) ]; then
        success "Already up to date"
        UPDATE=0
        if [[ "$1" = "--force" ]]; then
            warning "Forcing update"
            UPDATE=1
        fi
    fi
    if [[ "$UPDATE" -eq 1 ]]; then
        warning "Update needed"
        step "Updating..."
        git -C $HOME/.dotfiles pull | prependInfo # pull first, so the script is updated before executing
        $HOME/.dotfiles/setup-mac-os.sh --update
    fi
    step "Update Homebrew"
    update=$(brew update | head -n 1)
    if [[ $update == "Already up-to-date." ]]; then
        success "Already up to date"
    else
        echo $update | prependInfo
    fi
    step "Update Software installed via Homebrew"
    if [[ $(brew outdated) ]]; then
        warning "The following Software is outdated and will be updated:"
        brew outdated -q | prependInfo
        brew upgrade
    else
        success "Already up-to-date"
    fi
    step "Update tldr"
    if tldr --update; then
        success "Updated"
    else
        warning "Could not update tldr"
    fi
}

function step() {
    print -P "%F{blue}=> $1%f"
}

function warning() {
    print -P "%F{yellow}==> $1%f"
}

function success() {
    print -P "%F{green}==> $1%f"
}

function prependInfo() {
    while read line;
    do
        print -P "%F{white}===> $line%f";
    done;
}

main "$@"
