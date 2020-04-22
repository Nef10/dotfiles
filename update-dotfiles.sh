#!/usr/bin/env zsh

main() {
    UPDATE=1
    print -P "%F{blue}=> Checking for updates...%f"
    git -C $HOME/.dotfiles fetch &> /dev/null
    if [ $(git -C $HOME/.dotfiles rev-parse HEAD) '==' $(git -C $HOME/.dotfiles rev-parse @{u}) ]; then
        print -P "%F{green}===> Already up to date.%f"
        UPDATE=0
        if [[ "$1" = "--force" ]]; then
            print -P "%F{yellow}===> Forcing update needed%f"
            UPDATE=1
        fi
    fi
    if [[ "$UPDATE" -eq 1 ]]; then
        print -P "%F{white}===> Update needed%f"
        print -P "%F{blue}=> Updating...%f"
        git -C $HOME/.dotfiles pull # pull first, so the script is updated before executing
        $HOME/.dotfiles/setup-mac-os.sh --no-pull
    fi
}

main "$@"
