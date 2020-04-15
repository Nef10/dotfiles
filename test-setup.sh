#!/usr/bin/env zsh

main() {
    diff_repo
    diff_missing_brew
    diff_mas
    diff_brew_packages
    diff_brew_casks
    diff_brew_taps
    diff_git
    diff_vscode_missing_extensions
    diff_vscode_extensions
    diff_vscode_settings
}

DOTFILES_REPO=$HOME/.dotfiles

function diff_repo() {
    step "dotfiles repository"
    if [[ $(git -C $DOTFILES_REPO status --porcelain) ]]; then
        warning "Changes found:"
        git -C $DOTFILES_REPO status -s
    else
        if [[ $(git log origin/master..HEAD | cat) ]]; then
            warning "Your local branch is ahead of remote"
        else
            success "No difference found"
        fi
    fi
}

function diff_missing_brew() {
    step "Uninstalled from Brew"
    if ! brew bundle check --no-upgrade --file=$DOTFILES_REPO/brew/macOS.Brewfile &> /dev/null; then
        warning "Not all brew requirements are installed"
    else
        success "No difference found"
    fi
}

function diff_mas() {
    step "Additional AppStore Apps"
    MAS_SAME=0
    MAS_ID_TARGET=$(grep "mas \"" $DOTFILES_REPO/brew/macOS.Brewfile | grep -Eo '[0-9]+')
    mas list | grep -Eo '^[0-9]+ ' | while read -r mas_id ;
    do
        if ! echo $MAS_ID_TARGET | grep -c $mas_id &> /dev/null; then
            MAS_SAME=1
            SOFTWARE_ENTRY=$(mas list | grep $mas_id )
            SOFTWARE_NAME=${SOFTWARE_ENTRY#"$mas_id "}
            warning "$SOFTWARE_NAME is installed but not included in the macOS.Brewfile"
        fi
    done
    if [[ "$MAS_SAME" -eq 0 ]]; then
        success "No difference found"
    fi

}

function diff_brew_packages() {
    step "Additional Brew packages"
    BREW_SAME=0
    BREW_TARGET=$(brew bundle list --file=$DOTFILES_REPO/brew/macOS.Brewfile)
    brew leaves | while read -r brew_name ;
    do
        if ! echo $BREW_TARGET | grep -c $brew_name &> /dev/null; then
            BREW_SAME=1
            warning "$brew_name is installed but not included in the macOS.Brewfile"
        fi
    done
    if [[ "$BREW_SAME" -eq 0 ]]; then
        success "No difference found"
    fi
}

function diff_brew_casks() {
    step "Additional Brew Casks"
    CASKS_SAME=0
    CASKS_TARGET=$(brew bundle list --casks --file=$DOTFILES_REPO/brew/macOS.Brewfile)
    brew cask list | while read -r casks_name ;
    do
        if ! echo $CASKS_TARGET | grep -c $casks_name &> /dev/null; then
            CASKS_SAME=1
            warning "$casks_name is installed but not included in the macOS.Brewfile"
        fi
    done
    if [[ "$CASKS_SAME" -eq 0 ]]; then
        success "No difference found"
    fi

}

function diff_brew_taps() {
    step "Additional Brew Taps"
    TAPS_SAME=0
    TAPS_TARGET=$(brew bundle list --taps --file=$DOTFILES_REPO/brew/macOS.Brewfile)
    brew bundle dump --file=- | brew bundle list --taps --file=- | while read -r tap_name ;
    do
        if ! echo $TAPS_TARGET | grep -c $tap_name &> /dev/null; then
            TAPS_SAME=1
            warning "$tap_name is tapped but not included in the macOS.Brewfile"
        fi
    done
    if [[ "$TAPS_SAME" -eq 0 ]]; then
        success "No difference found"
    fi

}

function diff_vscode_missing_extensions() {
    step "Uninstalled VSCode Extensions"
    EXTENSIONS_SAME=0
    EXTENSIONS_TARGET=$(code --list-extensions)
    cat $DOTFILES_REPO/vscode/extensions.txt | while read -r extension_name ;
    do
        if ! echo $EXTENSIONS_TARGET | grep -c $extension_name &> /dev/null; then
            EXTENSIONS_SAME=1
            warning "$extension_name is not installed but included in extensions.txt"
        fi
    done
    if [[ "$EXTENSIONS_SAME" -eq 0 ]]; then
        success "No difference found"
    fi
}

function diff_vscode_extensions() {
    step "VSCode Extensions"
    EXTENSIONS_SAME=0
    EXTENSIONS_TARGET=$(cat $DOTFILES_REPO/vscode/extensions.txt)
    code --list-extensions | while read -r extension_name ;
    do
        if ! echo $EXTENSIONS_TARGET | grep -c $extension_name &> /dev/null; then
            EXTENSIONS_SAME=1
            warning "$extension_name is installed but not included in extensions.txt"
        fi
    done
    if [[ "$EXTENSIONS_SAME" -eq 0 ]]; then
        success "No difference found"
    fi
}

function diff_vscode_settings() {
    diff_file "VSCode Settings" $DOTFILES_REPO/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
}

function diff_git() {
    diff_file ".gitconfig" $DOTFILES_REPO/git/.gitconfig_template $HOME/.gitconfig
}

function diff_file() {
    step "${1}"
    if diff -q $2 $3 &> /dev/null; then
        success "No difference found"
    else
        warning "${1} different:"
        diff $2 $3 || true
    fi
}

function step() {
    print -P "%F{blue}=> $1%f"
}

function warning() {
    print -P "%F{yellow}===> $1%f"
}

function success() {
    print -P "%F{green}===> $1%f"
}

main "$@"
