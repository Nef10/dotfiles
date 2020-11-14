#!/usr/bin/env zsh

main() {
    ask_for_profile
    ask_for_sudo
    install_homebrew
    if [[ "$1" != "--update" ]]; then
        clone_dotfiles_repo
    fi
    install_packages_with_brewfile
    set_settings
    set_terminal_theme
    configure_zsh
    configure_git
    configure_ssh
    configure_vscode
    if [[ "$1" != "--update" ]]; then
        finish
    fi
}

DOTFILES_REPO=$HOME/.dotfiles

# Steps

function ask_for_profile() {
    step "Asking for profile"
    if [[ -f $DOTFILES_REPO/profile ]]; then
        PROFILE=$(cat $DOTFILES_REPO/profile)
        success "Found saved profile: $PROFILE"
    else
        info "Please enter the profile to be used (private|work):"
        read PROFILE
        success "Using profile: $PROFILE"
    fi
}

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

function clone_dotfiles_repo() {
    clone_or_update "Dotfiles" ${DOTFILES_REPO} "https://github.com/Nef10/dotfiles.git"
    echo $PROFILE > $DOTFILES_REPO/profile
}

function install_homebrew() {
    step "Installing Homebrew"
    if hash brew 2>/dev/null; then
        info "Homebrew already exists"
    else
        if true | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"; then
            success "Homebrew installation succeeded"
        else
            error "Homebrew installation failed"
        fi
    fi
}

function install_packages_with_brewfile() {
    DEFAULT_BREW_FILE_PATH="${DOTFILES_REPO}/brew/macOS.Brewfile"
    PROFILE_BREW_FILE_PATH="${DOTFILES_REPO}/brew/${PROFILE}.Brewfile"
    step "Installing software with brew"
    if cat $DEFAULT_BREW_FILE_PATH $PROFILE_BREW_FILE_PATH | brew bundle check --no-upgrade --file=- &> /dev/null; then
        info "Brewfile's dependencies are already satisfied"
    else
        if cat $DEFAULT_BREW_FILE_PATH $PROFILE_BREW_FILE_PATH | brew bundle --no-upgrade --file=-; then
            success "Brewfile installation succeeded"
        else
            error "Brewfile installation failed"
        fi
    fi
}

function set_settings() {
    step "Updating macOS settings"
    zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/macOS.csv set

    step "Updating The Unarchiver settings"
    zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/the_unarchiver.csv set

    step "Updating macOS configuration"
    zsh ${DOTFILES_REPO}/macOS/macOS.sh set
}

function set_terminal_theme() {
    step "Add Termial Theme"
    zsh ${DOTFILES_REPO}/terminal-theme/terminal-theme.sh $DOTFILES_REPO/terminal-theme/atom-one-dark.terminal
}

function configure_zsh() {
    ZSH_PLUGIN_DIR="$DOTFILES_REPO/checkout"

    SPACESHIP_DIR="$ZSH_PLUGIN_DIR/spaceship-prompt"
    clone_or_update "Spaceship prompt" $SPACESHIP_DIR "https://github.com/denysdovhan/spaceship-prompt.git"

    step "Linking spaceship prompt"
    ZSH_FUNCTIONS_DIR="$HOME/.zfunctions"
    if test -L "$ZSH_FUNCTIONS_DIR/prompt_spaceship_setup"; then
        info "spaceship prompt already linked"
    else
        step "creating $ZSH_FUNCTIONS_DIR dir"
        if test -e $ZSH_FUNCTIONS_DIR; then
            info "$ZSH_FUNCTIONS_DIR already exists"
        else
            if mkdir $ZSH_FUNCTIONS_DIR; then
                success "$ZSH_FUNCTIONS_DIR dir created"
            else
                error "failed to create $ZSH_FUNCTIONS_DIR dir"
            fi
            if ln -sf "$SPACESHIP_DIR/spaceship.zsh" "$ZSH_FUNCTIONS_DIR/prompt_spaceship_setup"; then
                success "spaceship prompt linked"
            else
                error "spaceship prompt linking failed"
            fi
        fi
    fi

    SYNTAX_HIGHLIGHTING_DIR="$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
    clone_or_update "zsh-syntax-highlighting" $SYNTAX_HIGHLIGHTING_DIR "https://github.com/zsh-users/zsh-syntax-highlighting.git"

    addTemplateToFileIfNeeded $DOTFILES_REPO/zsh/.zshrc_template ".zshrc source" $HOME/.zshrc
}

function configure_git() {
    addTemplateToFileIfNeeded $DOTFILES_REPO/git/.gitconfig_template ".gitconfig include" $HOME/.gitconfig
}

function configure_ssh() {
    if [[ ! -d $HOME/.ssh ]]; then
        mkdir $HOME/.ssh
    fi
    SSH_CONFIG_TEMPLATE="$DOTFILES_REPO/ssh/config_template_$PROFILE"
    addTemplateToFileIfNeeded $SSH_CONFIG_TEMPLATE "ssh config include" $HOME/.ssh/config
}

function configure_vscode() {
    if [[ ! -d $HOME/Library/Application\ Support/Code/User ]]; then
        mkdir -p $HOME/Library/Application\ Support/Code/User
    fi
    copy_file "VSCode settings" $DOTFILES_REPO/vscode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json
    copy_file "VSCode keybindings" $DOTFILES_REPO/vscode/keybindings.json $HOME/Library/Application\ Support/Code/User/keybindings.json

    EXTENSIONS_INSTALLED=$(code --list-extensions)
    for extension in `cat $DOTFILES_REPO/vscode/extensions.txt`
    do
        step "Installing VSCode extension $extension"
        if echo $EXTENSIONS_INSTALLED | grep -c $extension &> /dev/null; then
            info "VSCode extension $extension already installed"
        else
            if code --install-extension $extension &> /dev/null; then
                success "VSCode extension $extension installed successfully"
            else
                error "Failed to install VSCode extension $extension"
            fi
        fi
    done
}

function finish() {
    echo ""
    success "Finished successfully!"
    info "Please restart your Terminal for the applied changes to take effect."
}

# Git helper

function clone_or_update() {
    step "Cloning ${1} repository into ${2}"
    if test -e $2; then
        info "${2} already exists"
        pull_latest $1 $2
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
    if [ $(git -C $2 rev-parse HEAD) '==' $(git -C $2 rev-parse @{u}) ]; then
        info "${1} already up to date"
    else
        if git -C $2 pull origin master &> /dev/null; then
            success "Pull in ${1} successful"
        else
            error "Failed, please pull latest changes in ${1} repository manually"
        fi
    fi
}

# File helper

function createFileIfNeeded() {
    step "creating ${1} if needed"
    if test -e $1; then
        info "${1} already exists"
    else
        if touch $1; then
            success "${1} created successfully"
        else
            error "${1} could not be created"
        fi
    fi
}

function copy_file() {
    step "Copying ${1}"
    if diff -q $2 $3 &> /dev/null; then
        info "${1} already the same"
    else
        if cp $2 $3; then
            success "${1} copied"
        else
            error "Failed to copy ${1}"
        fi
    fi
}

function addTemplateToFileIfNeeded() {
    createFileIfNeeded $3
    step "Setting up ${2} in ${3}"
    if [[ -z $(comm -13 $3 $1) ]]; then
        info "${2} already set up in ${3}"
    else
        if echo "$(cat ${1})" >> $3; then
            success "${2} successfully set up in ${3}"
        else
            error "Failed to set up ${2} in ${3}"
        fi
    fi
}

# Print helper

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
