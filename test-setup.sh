#!/usr/bin/env zsh

main() {
    PROFILE=$(cat $DOTFILES_REPO/profile)
    DEFAULT_BREW_FILE_PATH="${DOTFILES_REPO}/brew/macOS.Brewfile"
    PROFILE_BREW_FILE_PATH="${DOTFILES_REPO}/brew/${PROFILE}.Brewfile"

    diff_repo
    diff_brew_completions
    diff_swift_completions
    diff_missing_brew
    diff_mas
    diff_brew_packages
    diff_brew_casks
    diff_brew_taps
    diff_settings
    diff_terminal_theme
    diff_git
    diff_ssh
    diff_zsh
    diff_vscode_missing_extensions
    diff_vscode_extensions
    diff_vscode_settings
    diff_quartz_filters
    diff_home_applications
    profile_specifics
}

DOTFILES_REPO=$HOME/.dotfiles

function diff_repo() {
    step "dotfiles repository"
    if [[ $(git -C $DOTFILES_REPO status --porcelain) ]]; then
        warning "Changes found:"
        git -C $DOTFILES_REPO status -s | prependInfo
    else
        if [[ $(git -C $DOTFILES_REPO log origin/main..HEAD | cat) ]]; then
            warning "Your local branch is ahead of remote"
        else
            success "No difference found"
        fi
    fi
}

function diff_brew_completions() {
    step "Brew completions"
    if brew completions state | grep -q "are linked"; then
        success "Brew completions are linked"
    else
        warning "brew completions are not linked"
    fi
}

function diff_swift_completions() {
    step "Swift completions"
    if test -e ~/.zfunctions/_swift; then
        success "Swift completions already installed"
    else
        warning "Swift completions are not installed"
    fi
}

function diff_missing_brew() {
    step "Uninstalled from Brew"
    if ! cat $DEFAULT_BREW_FILE_PATH $PROFILE_BREW_FILE_PATH | brew bundle check --no-upgrade --file=- &> /dev/null; then
        warning "Not all brew requirements are installed"
        cat $DEFAULT_BREW_FILE_PATH $PROFILE_BREW_FILE_PATH | brew bundle check --file=- --verbose --no-upgrade | grep → --color=never | cut -c2- | prependInfo
    else
        success "No difference found"
    fi
}

function diff_mas() {
    step "Additional AppStore Apps"
    MAS_SAME=0
    MAS_ID_TARGET=$(cat $DEFAULT_BREW_FILE_PATH $PROFILE_BREW_FILE_PATH | grep "mas \"" | grep -Eo '[0-9]+')
    mas list | grep -Eo '^[0-9]+ ' | while read -r mas_id ;
    do
        if ! echo $MAS_ID_TARGET | grep -c $mas_id &> /dev/null; then
            MAS_SAME=1
            SOFTWARE_ENTRY=$(mas list | grep $mas_id )
            SOFTWARE_NAME=${SOFTWARE_ENTRY#"$mas_id "}
            warning "$SOFTWARE_NAME is installed but not included in the Brewfile"
        fi
    done
    if [[ "$MAS_SAME" -eq 0 ]]; then
        success "No difference found"
    fi

}

function diff_brew_packages() {
    step "Additional Brew packages"
    BREW_SAME=0
    BREW_TARGET=$(cat $DEFAULT_BREW_FILE_PATH $PROFILE_BREW_FILE_PATH | brew bundle list --file=-)
    brew leaves | while read -r brew_name ;
    do
        if ! echo $BREW_TARGET | grep -c $brew_name &> /dev/null; then
            BREW_SAME=1
            warning "$brew_name is installed but not included in the Brewfile"
        fi
    done
    if [[ "$BREW_SAME" -eq 0 ]]; then
        success "No difference found"
    fi
}

function diff_brew_casks() {
    step "Additional Brew Casks"
    CASKS_SAME=0
    CASKS_TARGET=$(cat $DEFAULT_BREW_FILE_PATH $PROFILE_BREW_FILE_PATH | brew bundle list --casks --file=-)
    brew list --cask | while read -r casks_name ;
    do
        if ! echo $CASKS_TARGET | grep -c $casks_name &> /dev/null; then
            CASKS_SAME=1
            warning "$casks_name is installed but not included in the Brewfile"
        fi
    done
    if [[ "$CASKS_SAME" -eq 0 ]]; then
        success "No difference found"
    fi

}

function diff_brew_taps() {
    step "Additional Brew Taps"
    TAPS_SAME=0
    TAPS_TARGET=$(cat $DEFAULT_BREW_FILE_PATH $PROFILE_BREW_FILE_PATH | brew bundle list --taps --file=-)
    brew bundle dump --file=- | brew bundle list --taps --file=- | while read -r tap_name ;
    do
        if ! echo $TAPS_TARGET | grep -c $tap_name &> /dev/null; then
            TAPS_SAME=1
            warning "$tap_name is tapped but not included in the Brewfile"
        fi
    done
    if [[ "$TAPS_SAME" -eq 0 ]]; then
        success "No difference found"
    fi

}

function diff_settings() {
    step "macOS Settings"
    zsh $DOTFILES_REPO/settings/settings.sh $DOTFILES_REPO/settings/macOS.csv
    step "Xcode Settings"
    zsh $DOTFILES_REPO/settings/settings.sh $DOTFILES_REPO/settings/xcode.csv
    step "The Unarchiver Settings"
    zsh $DOTFILES_REPO/settings/settings.sh $DOTFILES_REPO/settings/the_unarchiver.csv
    step "Syntax Highlight Settings"
    zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/syntax_highlight.csv
    step "Rectangle Settings"
    zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/rectangle.csv
    step "macOS Configuration"
    zsh $DOTFILES_REPO/macOS/macOS.sh
}

function diff_terminal_theme() {
    step "Terminal Theme"
    zsh $DOTFILES_REPO/terminal-theme/terminal-theme.sh
}

function diff_vscode_missing_extensions() {
    step "Uninstalled VSCode Extensions"
    EXTENSIONS_SAME=0
    EXTENSIONS_TARGET=$(code --list-extensions)
    cat $DOTFILES_REPO/vscode/extensions.txt $DOTFILES_REPO/vscode/extensions-$PROFILE.txt | while read -r extension_name ;
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
    step "Additional VSCode Extensions"
    EXTENSIONS_SAME=0
    EXTENSIONS_TARGET=$(cat $DOTFILES_REPO/vscode/extensions.txt $DOTFILES_REPO/vscode/extensions-$PROFILE.txt)
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
    diff_file "VSCode Keybindings" $DOTFILES_REPO/vscode/keybindings.json $HOME/Library/Application\ Support/Code/User/keybindings.json
}

function diff_git() {
    diff_file ".gitconfig" $DOTFILES_REPO/git/.gitconfig_template $HOME/.gitconfig
}

function diff_ssh() {
    SSH_CONFIG_TEMPLATE="$DOTFILES_REPO/ssh/config_template_$PROFILE"
    diff_file "ssh config" $SSH_CONFIG_TEMPLATE $HOME/.ssh/config
}

function diff_zsh() {
    diff_file ".zshrc" $DOTFILES_REPO/zsh/.zshrc_template $HOME/.zshrc
}

function diff_quartz_filters() {
    diff_file "Quartz Filter Minimal" $DOTFILES_REPO/quartz/Reduce\ File\ Size\ Minimal.qfilter $HOME/Library/Filters/Reduce\ File\ Size\ Minimal.qfilter
    diff_file "Quartz Filter Medium" $DOTFILES_REPO/quartz/Reduce\ File\ Size\ Medium.qfilter $HOME/Library/Filters/Reduce\ File\ Size\ Medium.qfilter
    diff_file "Quartz Filter Extreme" $DOTFILES_REPO/quartz/Reduce\ File\ Size\ Extreme.qfilter $HOME/Library/Filters/Reduce\ File\ Size\ Extreme.qfilter
    step "Additional Quartz filters"
    ADDITIONAL_FILTERS=0
    ls $HOME/Library/Filters/*.qfilter | while read filename ;
    do
        if [[ ! ( "$filename" = "$HOME/Library/Filters/Reduce File Size Minimal.qfilter" || "$filename" = "$HOME/Library/Filters/Reduce File Size Medium.qfilter" || "$filename" = "$HOME/Library/Filters/Reduce File Size Extreme.qfilter" ) ]] then
            ADDITIONAL_FILTERS=1
            warning "Quartz filter $filename is installed but not included in the dotfiles"
        fi
    done
    if [[ "$ADDITIONAL_FILTERS" -eq 0 ]]; then
        success "No additional quartz filters found"
    fi
}

function diff_home_applications() {
    step "Hidden flag of Application folder in home directory"
    if [[ -d $HOME/Applications ]]; then
        if [[ $(stat -f "%Xf" $HOME/Applications) -eq 8000 ]]; then
            success "No difference found"
        else
            warning "Folder not hidden"
        fi
    else
        warning "Application folder in home directory does not exist"
    fi
}

function profile_specifics() {
    . ${DOTFILES_REPO}/profiles/test-${PROFILE}.sh
}

# helpers

function diff_file() {
    step "${1}"
    if diff -q $2 $3 &> /dev/null; then
        success "No difference found"
    else
        warning "${1} different:"
        diff $2 $3 || true
    fi
}

function checkFileExists() {
    if [[ -f "$2" ]]; then
       success "$1 exists"
    else
        warning "$1 does not exist"
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
