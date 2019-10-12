#!/usr/bin/env zsh

main() {
    ask_for_sudo
    clone_dotfiles_repo
    install_homebrew
    install_packages_with_brewfile
    setup_macOS_defaults
    setup_rbenv
    configure_zsh
    setup_terminal_theme
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
        exit 1
    fi
}

function setup_rbenv() {
    step "Setting up rbenv"
    addToZshrcIfNeeded "eval \"\$(rbenv init -)\"" "rbenv"
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
            exit 1
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
            exit 1
        fi
    fi
}

function setup_terminal_theme() {
    echo ""
    action "To finish the installation you need to set the terminal profile."
    action "Therefore, we will open a new terminal window. Please open the settings in this new new window,"
    action "go to profiles, select the current one, and click Default to finish the installation."
    echo ""
    read -s -k '?Press any key to continue.'
    open ${DOTFILES_REPO}/terminal-theme/atom-one-dark.terminal
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
            exit 1
        fi
    fi
}

function configure_zsh() {
    step "Configuring zsh"

    ZSH_FUNCTIONS_DIR="$HOME/.zfunctions"
    addToZshrcIfNeeded "fpath=( \"\$HOME/.zfunctions\" \$fpath )" ".zfunctions"

    ZSH_PLUGIN_DIR="$HOME/.zsh-plugins"

    SPACESHIP_DIR="$ZSH_PLUGIN_DIR/spaceship-prompt"
    clone_or_update "Spaceship promt" $SPACESHIP_DIR "https://github.com/denysdovhan/spaceship-prompt.git"

    step "Linking spaceship promt"
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
                    exit 1
                fi
            else
                error "failed to create $ZSH_FUNCTIONS_DIR dir"
                exit 1
            fi
        fi
    fi

    addToZshrcIfNeeded "autoload -U promptinit; promptinit" "autoload promitinit"
    addToZshrcIfNeeded "prompt spaceship" "prompt spaceship"

    SYNTAX_HIGHLIGHTING_DIR="$ZSH_PLUGIN_DIR/zsh-syntax-highlighting"
    clone_or_update "zsh-syntax-highlighting" $SYNTAX_HIGHLIGHTING_DIR "https://github.com/zsh-users/zsh-syntax-highlighting.git"

    addToZshrcIfNeeded "ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)" "zsh-syntax-highlighting config"
    addToZshrcIfNeeded "source $SYNTAX_HIGHLIGHTING_DIR/zsh-syntax-highlighting.zsh" "zsh-syntax-highlighting"
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
            exit 1
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
            exit 1
        fi
    fi
}

function pull_latest() {
    step "Pulling latest changes in ${1} repository"
    if git -C $1 pull origin master &> /dev/null; then
        success "Pull in ${1} successful"
    else
        error "Please pull latest changes in ${1} repository manually"
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
        exit 1
    fi
}

function coloredEcho() {
    local exp="$1";
    local color="$2";
    local arrow="$3";
    if ! [[ $color =~ '^[0-9]$' ]] ; then
       case $(echo $color | tr '[:upper:]' '[:lower:]') in
        black) color=0 ;;
        red) color=1 ;;
        green) color=2 ;;
        yellow) color=3 ;;
        blue) color=4 ;;
        magenta) color=5 ;;
        cyan) color=6 ;;
        white|*) color=7 ;; # white or invalid color
       esac
    fi
    tput bold;
    tput setaf "$color";
    echo "$arrow $exp";
    tput sgr0;
}

function step() {
    coloredEcho "$1" blue "=>"
}

function info() {
    coloredEcho "$1" white "===>"
}

function success() {
    coloredEcho "$1" green "===>"
}

function error() {
    coloredEcho "$1" red "===>"
}

function action() {
    coloredEcho "$1" magenta "=>"
}

main "$@"
