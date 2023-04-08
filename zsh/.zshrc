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
CORRECT_IGNORE_FILE='.*'

# Environment variables

export LESS=-R # let less output ANSI color escape sequences in raw, so the output can be colorized
export EDITOR=nano

# Brew

if [ "$(uname -p)" = "i386" ]; then
  if [ -f "/usr/local/bin/brew" ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
else
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Completion

fpath=( "$HOME/.zfunctions" "$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath )
autoload -Uz compinit compaudit
compinit
compaudit

eval "$(op completion zsh)"; compdef _op op # 1password CLI completion

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

# Misc

eval "$(thefuck --alias fix)"
export NODE_BUILD_DEFINITIONS="$(brew --prefix node-build-update-defs)/share/node-build"
eval "$(nodenv init -)"
eval "$(rbenv init -)"
eval "$(direnv hook zsh)"

# Starship promt

export STARSHIP_CONFIG=$HOME/.dotfiles/starship/config.toml
eval "$(starship init zsh)"

# Auto Suggestions

ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax Highlighting

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# History Searching

source "$HOMEBREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
export HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND=fg=black,bg=green,bold
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Homebrew command not found (see https://github.com/Homebrew/homebrew-command-not-found)

HB_CNF_HANDLER="$HOMEBREW_REPOSITORY/Library/Taps/homebrew/homebrew-command-not-found/handler.sh"
if [ -f "$HB_CNF_HANDLER" ]; then
  source "$HB_CNF_HANDLER";
fi

export HOMEBREW_NO_ENV_HINTS=1

# Path

path+=~/.mint/bin

# Source

source ~/.dotfiles/zsh/aliases.zsh
source ~/.dotfiles/zsh/functions.zsh
