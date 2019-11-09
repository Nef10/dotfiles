# Options

setopt auto_pushd             # Make cd push the old directory onto the directory stack
setopt auto_cd                # If a command can’t be executed and is the name of a directory, perform cd into it
setopt correct_all            # Try to correct the spelling of all arguments in a line
setopt menu_complete          # Show completion menu and auto insert first suggesting on first tab
setopt interactive_comments   # Allow comments in interactive shells
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # do not save commands which are duplicates of the previous
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data between zsh sessions

HISTSIZE=50000
SAVEHIST=10000

# Environment variables

export LESS=-R # let less output ANSI color escape sequences in raw, so the output can be colorized

# Completion

autoload -Uz compinit compaudit
compinit
compaudit

zstyle ':completion:*:*:*:*:*' menu select                # Show completion menu which allows navigation with arrow keys
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' # Case insensitive completion
zstyle ':completion:*' list-colors ''                     # Color the completion menu
zstyle ':completion::complete:*' use-cache 1              # Caching
zstyle ':completion::complete:*' cache-path ~/.zsh_cache  # Caching

zstyle ':completion:*::::' completer _expand _complete _ignored _approximate # allow one error for every three characters typed in approximate completer
zstyle -e ':completion:*:approximate:*' max-errors 'reply=( $(( ($#PREFIX+$#SUFFIX)/2 )) numeric )'

expand-or-complete-with-dots() { # Display red dots while waiting for completion
  [[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti rmam
  print -Pn "%{%F{red}......%f%}"
  [[ -n "$terminfo[rmam]" && -n "$terminfo[smam]" ]] && echoti smam

  zle expand-or-complete
  zle redisplay
}
zle -N expand-or-complete-with-dots
bindkey "^I" expand-or-complete-with-dots

# Alias

## Basics

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias md='mkdir -p'

alias ll='ls -lhFpGO'
alias la='ls -AlhFpGO'

alias grep="grep --color=auto"

## Git

alias g='git'

alias ga='git add'
alias gaa='git add --all'

alias gs='git status'
alias gu='git push'
alias gl='git pull'
alias gf='git fetch'
alias gd='git diff'

alias gc='git commit -m'
alias gca='git commit --amend --reuse-message=HEAD'

## Misc

alias battery='pmset -g batt'
alias software='system_profiler SPSoftwareDataType'
alias hardware='system_profiler SPHardwareDataType SPDisplaysDataType'

# Misc

eval "$(nodenv init -)"
eval "$(rbenv init -)"

# Spaceship promt

fpath=( "$HOME/.zfunctions" $fpath )
autoload -U promptinit; promptinit
prompt spaceship
export SPACESHIP_EXIT_CODE_SHOW=true   # Show exit code
export SPACESHIP_GIT_STATUS_STASHED="" # Hide notification if a stash exists

# Syntax Highlighting

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source $HOME/.dotfiles/checkout/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# History Searching

source /usr/local/share/zsh-history-substring-search/zsh-history-substring-search.zsh
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=fg=black,bg=green,bold
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Functions

## dotfiles

function update_dotfiles() {
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
        $HOME/.dotfiles/setup-mac-os.sh
    fi
}

function diff_dotfiles_setup() {
    $HOME/.dotfiles/test-setup.sh
}

## misc

function hide() {
    chflags hidden $1
}

function unhide() {
    chflags nohidden $1
}

function finder() {
    open .
}

function mute() {
    osascript -e 'set volume output muted true'
}

function unmute() {
    osascript -e 'set volume output muted false'
}

function volume() {
    if [[ -z $1 ]]; then
        osascript -e "output volume of (get volume settings)"
    else
        osascript -e "set volume output volume $1"
    fi
}