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

alias path='echo -e ${PATH//:/\\n}'

## Git

alias g='git'

alias ga='git add'
alias gaa='git add --all'

alias gs='git status'
alias gu='git push'
alias gl='git pull'
alias gf='git fetch'

alias gd='git diff'
alias gds='git diff --staged'

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

# Homebrew command not found (see https://github.com/Homebrew/homebrew-command-not-found)

if brew command command-not-found-init > /dev/null 2>&1; then eval "$(brew command-not-found-init)"; fi

# Functions

## dotfiles

function update_dotfiles() {
    $HOME/.dotfiles/update-dotfiles.sh "$@"
}

function diff_dotfiles_setup() {
    $HOME/.dotfiles/test-setup.sh
}

## git

function gb() { # git back after feature branch is merged
    if [[ -z $(git status --porcelain) ]]; then
        branchab=$(git status --porcelain=2 --branch | grep "# branch.ab")
        if [[ ! -z $branchab ]]; then
            if [[ ! -z $(grep "+0" <<< $branchab) ]]; then
                mainBranch="master"
                branch=$(git name-rev --name-only HEAD)
                remote=$(git config branch.$branch.remote)
                git fetch $remote $mainBranch &>/dev/null
                if [[ ! $(git cherry $remote/$mainBranch $branch | grep "^+") ]]; then
                    if [[ $(git remote prune $remote --dry-run | grep "\[would prune\] $remote/$branch") ]]; then
                        git checkout $mainBranch &>/dev/null
                        git pull &>/dev/null
                        git branch -D $branch &>/dev/null
                        git fetch --prune $remote &>/dev/null
                        print -P "%F{green}Deleted local branch $branch, checked $mainBranch out%f"
                    else
                        print -P "%F{red}Branch $branch was not deleted from remote $remote%f"
                    fi
                else
                print -P "%F{red}Not all commits from you local branch $branch have been merged to $mainBranch%f"
                fi
            else
                print -P "%F{red}Your branch is ahead of the remote%f"
            fi
        else
            print -P "%F{red}Your branch is not tracking any remote branch%f"
        fi
    else
        print -P "%F{red}You have uncommitted changes%f"
    fi
}

## misc

function cdf() { # cd to folder open in finder
	cd "$(osascript -e 'tell app "Finder" to get POSIX path of (insertion location as alias)')";
}

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

function port() {
    sudo lsof -i :$1
}
