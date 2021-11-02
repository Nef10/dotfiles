#!/usr/bin/env zsh

main() {
    ask_for_profile
    ask_for_sudo
    install_homebrew
    if [[ "$1" != "--update" ]]; then
        clone_dotfiles_repo
    fi
    install_packages_with_brewfile
    link_brew_completions
    install_swift_completions
    set_settings
    set_terminal_theme
    configure_zsh
    configure_git
    configure_ssh
    configure_vscode
    install_quartz_filter
    hide_home_applications
    profile_specifics
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
        success "Temporary sudo mode activated"
    else
        error "sudo failed"
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
        if true | bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
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

function link_brew_completions() {
    step "Linking brew completions"
    if brew completions state | grep -q "are linked"; then
        info "Brew completions are already linked"
    else
        brew completions link &> /dev/null
        success "Brew completions linked successfully"
    fi
}

function install_swift_completions() {
    step "Installing swift completions"
    ZSH_FUNCTIONS_DIR="$HOME/.zfunctions"
    if test -e "$ZSH_FUNCTIONS_DIR/_swift"; then
        info "Swift completions already installed"
    else
        step "Creating $ZSH_FUNCTIONS_DIR dir"
        if test -e $ZSH_FUNCTIONS_DIR; then
            info "$ZSH_FUNCTIONS_DIR already exists"
        else
            if mkdir $ZSH_FUNCTIONS_DIR; then
                success "$ZSH_FUNCTIONS_DIR dir created"
            else
                error "failed to create $ZSH_FUNCTIONS_DIR dir"
            fi
        fi
        swift package completion-tool generate-zsh-script > "$ZSH_FUNCTIONS_DIR/_swift"
        success "Swift completions installed successfully"
    fi
}

function set_settings() {
    step "Updating macOS settings"
    zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/macOS.csv set

    step "Updating The Unarchiver settings"
    zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/the_unarchiver.csv set

    step "Updating Syntax Highlight settings"
    zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/syntax_highlight.csv set

    step "Updating Rectangle settings"
    zsh ${DOTFILES_REPO}/settings/settings.sh $DOTFILES_REPO/settings/rectangle.csv set

    step "Updating macOS configuration"
    zsh ${DOTFILES_REPO}/macOS/macOS.sh set
}

function set_terminal_theme() {
    step "Add Termial Theme"
    zsh ${DOTFILES_REPO}/terminal-theme/terminal-theme.sh $DOTFILES_REPO/terminal-theme/atom-one-dark.terminal
}

function configure_zsh() {
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
    for extension in `cat $DOTFILES_REPO/vscode/extensions.txt $DOTFILES_REPO/vscode/extensions-$PROFILE.txt`
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

function install_quartz_filter() {
    if [[ ! -d $HOME/Library/Filters ]]; then
        mkdir -p $HOME/Library/Filters
    fi
    copy_file "Quartz Filter Minimal" $DOTFILES_REPO/quartz/Reduce\ File\ Size\ Minimal.qfilter $HOME/Library/Filters/Reduce\ File\ Size\ Minimal.qfilter
    copy_file "Quartz Filter Medium" $DOTFILES_REPO/quartz/Reduce\ File\ Size\ Medium.qfilter $HOME/Library/Filters/Reduce\ File\ Size\ Medium.qfilter
    copy_file "Quartz Filter Extreme" $DOTFILES_REPO/quartz/Reduce\ File\ Size\ Extreme.qfilter $HOME/Library/Filters/Reduce\ File\ Size\ Extreme.qfilter
}

function hide_home_applications() {
    step "Hiding Application folder in home directory"
    if [[ -d $HOME/Applications ]]; then
        if [[ $(stat -f "%Xf" $HOME/Applications) -eq 8000 ]]; then
            info "folder already hidden"
        else
            chflags hidden $HOME/Applications
            success "successfully hidden"
        fi
    else
        warning "Application folder in home directory does not exist"
    fi
}

function profile_specifics() {
    . ${DOTFILES_REPO}/profiles/setup-${PROFILE}.sh
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
        if git -C $2 pull origin main &> /dev/null; then
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

## helper

function install_ssh_key() {
    SSH_DIR="$HOME/.ssh"
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

# Print helper

function step() {
    print -P "%F{blue}=> $1%f"
}

function info() {
    print -P "%F{white}===> $1%f"
}

function warning() {
    print -P "%F{yellow}===> $1%f"
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
