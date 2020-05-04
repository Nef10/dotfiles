#!/usr/bin/env zsh

# Pass file as parameter if you want to set the theme, otherwise it will check if it correctly set

function main() {
    if [[ -z $1 ]]; then
        check_terminal_theme
    else
        set_terminal_theme $1
    fi
}

function set_terminal_theme() {
    if window_setting_correct && default_window_setting_correct && startup_window_setting_correct; then
        print -P "%F{white}==> Terminal Theme already set"
        return
    fi

    if ! window_setting_correct; then
        start=$(grep -n "<dict>" $1 | cut -f1 -d:)
        end=$(grep -n "</dict>" $1 | cut -f1 -d:)
        theme=$(tail -n +$start $1 | head -n $((end-start+1)))
        defaults write com.apple.terminal "Window Settings" -dict-add "atom-one-dark" "$theme"
        print -P "%F{green}==> Added Terminal Theme"
    fi
    if ! default_window_setting_correct; then
        defaults write com.apple.terminal "Default Window Settings" -string "atom-one-dark"
         print -P "%F{green}==> Set Terminal Theme as default"
    fi
    if ! startup_window_setting_correct; then
        defaults write com.apple.terminal "Startup Window Settings" -string "atom-one-dark"
        print -P "%F{green}==> Set Terminal Theme as startup"
    fi
}

function check_terminal_theme() {
    all_correct=true

    if ! window_setting_correct; then
        all_correct=false
        print -P "%F{yellow}==> Terminal Theme was not added%f"
        return
    fi
    if ! default_window_setting_correct; then
        all_correct=false
        print -P "%F{yellow}==> Terminal Theme is not set as default%f"
    fi
    if ! startup_window_setting_correct; then
        all_correct=false
        print -P "%F{yellow}==> Terminal Theme is not set as startup%f"
    fi

    if [[ $all_correct == true ]]; then
        print -P "%F{green}==> No difference found%f"
    fi
}

function window_setting_correct() {
    [[ $(defaults read com.apple.terminal "Window Settings") == *"atom-one-dark"* ]]
}

function default_window_setting_correct() {
    [[ $(defaults read com.apple.terminal "Default Window Settings") == "atom-one-dark" ]]
}

function startup_window_setting_correct() {
    [[ $(defaults read com.apple.terminal "Startup Window Settings") == "atom-one-dark" ]]
}

main "$@"
