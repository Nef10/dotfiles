# Basics

alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'

alias md='mkdir -p'

alias ll='ls -lhFpGO'
alias la='ls -AlhFpGO'

alias grep="grep --color=auto"

alias path='echo -e ${PATH//:/\\n}'

# Git

alias g='git'

alias ga='git add'
alias gaa='git add --all'

alias gs='git status'
alias gu='git push'
alias gl='git pull'
alias gf='git fetch'

alias glb='git checkout -b'

alias gd='git diff'
alias gds='git diff --staged'

alias gc='git commit -m'
alias gca='git commit --amend --reuse-message=HEAD'

# M1

alias armzsh='arch -arm64 zsh'
alias rosettazsh='arch -x86_64 zsh'
