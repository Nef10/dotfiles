# dotfiles

function update_dotfiles() {
    $HOME/.dotfiles/update-dotfiles.sh "$@"
}

function diff_dotfiles_setup() {
    $HOME/.dotfiles/test-setup.sh
}

# git

function gb() { # git back after feature branch is merged
    if [[ -z $(git status --porcelain) ]]; then
        branchab=$(git status --porcelain=2 --branch | grep "# branch.ab")
        if [[ ! -z $branchab ]]; then
            if [[ ! -z $(grep "+0" <<< $branchab) ]]; then
                branch=$(git rev-parse --abbrev-ref HEAD)
                remote=$(git config branch.$branch.remote)
                mainBranch=$(git remote show $remote | sed -n "s/.*HEAD branch: \([^ ]*\).*/\1/p")
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

function grb() { # git create remote tracked branch
    branch=$(git rev-parse --abbrev-ref HEAD)
    remote=$(git config branch.$branch.remote)
    git checkout -b $1
    git push --set-upstream $remote $1
}

function geb() { # git create empty branch
    if [[ -z $(git status --porcelain) ]]; then
        git checkout --orphan $1
        git rm -rf .
        git commit --allow-empty -m "Create empty $1 branch"
        git push origin $1
    else
        print -P "%F{red}You have uncommitted changes%f"
    fi
}

# misc

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

function battery() {
    pmset -g batt
}

function software() {
    system_profiler SPSoftwareDataType
}

function hardware() {
    system_profiler SPHardwareDataType SPDisplaysDataType
}
