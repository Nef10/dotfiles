#!/usr/bin/env zsh

# Pass "set" parameter if you want to set the configuration, otherwise it will check if it correctly set

function main() {
    if [[ $1 != "set" ]]; then
        check_macos_configuration
    else
        set_macos_configuration
    fi
}

function set_macos_configuration() {
    if filevault_configuration_correct && software_updates_installed && powernap_configuration_correct ; then
        print -P "%F{white}==> macOS configuration already set correctly"
        return
    fi

    if ! filevault_configuration_correct; then
        print -P "%F{green}==> Enabling FileVault. It will prompt on the next login."
        print -P "%F{yellow}==> Afterwards, please make sure to backup your recovery key from the Desktop!"
        sudo fdesetup enable -defer $HOME/Desktop/FileVaultRecoveryKey.plist -forceatlogin 1
    fi
    if ! software_updates_installed; then
         print -P "%F{green}==> Installing Software Updates"
         softwareupdate --install --all
    fi
    if ! powernap_configuration_correct; then
        print -P "%F{green}==> Enable power nap for all power modes"
        sudo pmset -a powernap 1
    fi
}

function check_macos_configuration() {
    all_correct=true

    if ! filevault_configuration_correct; then
        all_correct=false
        print -P "%F{red}==> FileVault is disabled%f"
        return
    fi
    if ! software_updates_installed; then
        all_correct=false
        print -P "%F{yellow}==> Please update macOS / Software from the AppStore%f"
    fi
    if ! powernap_configuration_correct; then
        all_correct=false
        print -P "%F{yellow}==> Power nap is not enabled on all power modes%f"
    fi

    if [[ $all_correct == true ]]; then
        print -P "%F{green}==> No difference found%f"
    fi
}

function filevault_configuration_correct() {
    [[ $(fdesetup status | grep $Q -E "FileVault is (On|Off, but will be enabled after the next restart).") ]]
}

function software_updates_installed() {
    [[ $(softwareupdate -l 2>&1 | grep $Q "No new software available.") ]]
}

function powernap_configuration_correct() {
    [[ $(pmset -g custom 2>&1 | grep powernap | awk '{print $2}' | tail -1) == 1 && $(pmset -g custom 2>&1 | grep -m 1 powernap | awk '{print $2}') == 1 ]]
}

main "$@"
