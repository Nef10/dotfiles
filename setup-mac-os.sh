#!/usr/bin/env zsh

main() {
    ask_for_sudo
    clone_dotfiles_repo
    install_homebrew
    install_packages_with_brewfile
    setup_macOS_defaults
    configure_zsh
    configure_vscode
    finish
}

DOTFILES_REPO=$HOME/.dotfiles

function ask_for_sudo() {
    step "Prompting for sudo password"
    if sudo --validate; then
        # Keep-alive
        while true; do sudo --non-interactive true; \
            sleep 10; kill -0 "$$" || exit; done 2>/dev/null &
        success "Sudo password updated"
    else
        error "Sudo password update failed"
    fi
}

function addToZshrcIfNeeded() {
    createZshrcIfNeeded
    FILE=$HOME/.zshrc
    step "Setting up ${2} in $FILE"
    if grep -Fxq $1 $FILE; then
        info "${2} alread set up in $FILE"
    else
        if echo "\n${1}" >> $FILE; then
            success "${2} successfully set up in $FILE"
        else
            error "Failed to set up ${2} in $FILE"
        fi
    fi
}

function createZshrcIfNeeded() {
    FILE=$HOME/.zshrc
    step "creating $FILE if needed"
    if test -e $FILE; then
        info "$FILE already exists"
    else
        if touch $FILE; then
            success "$FILE created successfully"
        else
            error "$FILE could not be created"
        fi
    fi
}

function finish() {
    echo ""
    success "Finished successfully!"
    info "Please restart your Terminal for the applied changes to take effect."
}

function install_homebrew() {
    step "Installing Homebrew"
    if hash brew 2>/dev/null; then
        info "Homebrew already exists"
    else
        if /usr/bin/ruby -e ${DOTFILES_REPO}/installers/homebrew; then
            success "Homebrew installation succeeded"
        else
            error "Homebrew installation failed"
        fi
    fi
}

function configure_zsh() {
    ZSH_PLUGIN_DIR="$DOTFILES_REPO/checkout"

    SPACESHIP_DIR="$ZSH_PLUGIN_DIR/spaceship-prompt"
    clone_or_update "Spaceship promt" $SPACESHIP_DIR "https://github.com/denysdovhan/spaceship-prompt.git"

    step "Linking spaceship promt"
    ZSH_FUNCTIONS_DIR="$HOME/.zfunctions"
    if test -L "$ZSH_FUNCTIONS_DIR/prompt_spaceship_setup"; then
        info "spaceship promt already linked"
    else
        step "creating $ZSH_FUNCTIONS_DIR dir"
        if test -e $ZSH_FUNCTIONS_DIR; then
            info "$ZSH_FUNCTIONS_DIR already exists"
        else
            if mkdir $ZSH_FUNCTIONS_DIR; then
                success "$ZSH_FUNCTIONS_DIR dir created"
                if ln -sf "$SPACESHIP_DIR/spaceship.zsh" "$ZSH_FUNCTIONS_DIR/prompt_spaceship_setup"; then
                    success "spaceship promt linked"
                else
                    error "spaceship promt linking failed"
                fi
            else
                error "failed to create $ZSH_FUNCTIONS_DIR dir"
            fi
        fi
    fi

    SYNTAX_HIGHLIGHTING_DIR="$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
    clone_or_update "zsh-syntax-highlighting" $SYNTAX_HIGHLIGHTING_DIR "https://github.com/zsh-users/zsh-syntax-highlighting.git"

    addToZshrcIfNeeded "source $DOTFILES_REPO/zsh/.zshrc" "link to .zshrc"
}

function configure_vscode() {
    VSCODE_FOLDER=$DOTFILES_REPO/vscode
    VSCODE_SETTINGS=$HOME/Library/Application\ Support/Code/User/settings.json
    step "Copying VSCode settings"
    if diff -q $VSCODE_FOLDER/settings.json $VSCODE_SETTINGS &> /dev/null; then
        info "VSCode settings already the same"
    else
        if cp $VSCODE_FOLDER/settings.json $VSCODE_SETTINGS; then
            success "VSCode settings copied"
        else
            error "Failed to copy VSCode settings"
        fi
    fi

    EXTENSIONS_INSTALLED=$(code --list-extensions)
    for plugin in `cat $VSCODE_FOLDER/plugins.txt`
    do
        step "Installing VSCode plugin $plugin"
        if echo $EXTENSIONS_INSTALLED | grep -c $plugin &> /dev/null; then
            info "VSCode plugin $plugin already installed"
        else
            if code --install-extension $plugin &> /dev/null; then
                success "VSCode plugin $plugin installed successfully"
            else
                error "Failed to install VSCode plugin $plugin"
            fi
        fi
    done
}

function install_packages_with_brewfile() {
    BREW_FILE_PATH="${DOTFILES_REPO}/brew/macOS.Brewfile"
    step "Installing packages within ${BREW_FILE_PATH}"
    if brew bundle check --file="$BREW_FILE_PATH" &> /dev/null; then
        info "Brewfile's dependencies are already satisfied"
    else
        if brew bundle --file="$BREW_FILE_PATH"; then
            success "Brewfile installation succeeded"
        else
            error "Brewfile installation failed"
        fi
    fi
}

function clone_dotfiles_repo() {
    clone_or_update "Dotfiles" ${DOTFILES_REPO} "https://github.com/Nef10/dotfiles.git"
}

function clone_or_update() {
    step "Cloning ${1} repository into ${2}"
    if test -e $2; then
        info "${2} already exists"
        pull_latest $2
    else
        if git clone "$3" $2; then
            success "${1} repository cloned into ${2}"
        else
            error "${1} repository cloning failed"
        fi
    fi
}

function pull_latest() {
    step "Pulling latest changes in ${1} repository"
    git -C $1 fetch &> /dev/null
    if [ $(git -C $HOME/.dotfiles rev-parse HEAD) '==' $(git -C $HOME/.dotfiles rev-parse @{u}) ]; then
        info "${1} already up to date"
    else
        if git -C $1 pull origin master &> /dev/null; then
            success "Pull in ${1} successful"
        else
            error "Failed, Please pull latest changes in ${1} repository manually"
        fi
    fi
}

function setup_macOS_defaults() {
    step "Updating macOS defaults"

    current_dir=$(pwd)
    cd ${DOTFILES_REPO}/macOS
    if bash defaults.sh; then
        cd $current_dir
        success "macOS defaults updated successfully"
    else
        cd $current_dir
        error "macOS defaults update failed"
    fi
}

function step() {
    print -P "%F{blue}=> $1%f"
}

function info() {
    print -P "%F{white}===> $1%f"
}

function success() {
    print -P "%F{green}===> $1%f"
}

function error() {
    print -P "%F{red}===> $1%f"
    print -P "%F{red}Aborting%f"
    exit 1
}

main "$@"
