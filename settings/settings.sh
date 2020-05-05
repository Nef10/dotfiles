#!/usr/bin/env zsh

# Parameter 1: csv file name
# Parameter 2: if set to set will change the settings which are not correct
# Parameter 3 (or 2 if not set): If set to verbose will prevent grouping of settings per app if all are already set correctly

function settings() {

    if [[ $2 == "set" ]]; then
        correctColor="white"
        noDifference="Settings are already set correctly"
    else
        correctColor="green"
        noDifference="No difference found"
    fi

    while IFS=, read -r app description domain setting type value currentHost overrideCurrentValueComparison
    do

        if [[ $app == "app" ]]; then # skip csv header
            continue
        fi

        if [[ $app != $lastApp ]]; then
            if [[ $allInAppCorrect == true && $2 != "verbose" && $3 != "verbose" ]]; then
                print -P "%F{$correctColor}===> $noDifference%f"
            fi
            allInAppCorrect=true

            if [[ $2 == "set" && $app != "Misc" ]]; then
                killall "$lastApp" > /dev/null 2>&1
            fi
            print -P "%F{white}==> $app"
            if [[ $2 == "set" && $app != "Misc" ]]; then
                killall "$app" > /dev/null 2>&1
            fi
        fi

        if [[ $currentHost == "true" ]]; then
            current=$(defaults -currentHost read $domain $setting)
        else
            current=$(defaults read $domain $setting)
        fi

        if [[ $value == *"$"* ]]; then
            value=$(eval echo "$value")
        fi

        if [[ $overrideCurrentValueComparison != "false" ]]; then
            # in case we must set some more complext values with xml syntax
            expected=$overrideCurrentValueComparison
            # remove all whitespace, except between quotes, from output (See https://stackoverflow.com/a/17302816/3386893)
            current=$(awk 'BEGIN {FS = OFS = "\""} /^[[:space:]]*$/ {next} {for (i=1; i<=NF; i+=2) gsub(/[[:space:]]/,"",$i)} 1' <<< $current | tr -d '\n' )
        elif [[ $type == "bool" ]]; then
            if [[ $value == "true" ]]; then
                expected=1
            else
                expected=0
            fi
        else
            expected=$value
        fi

        if [[ $current != $expected ]]; then
            allInAppCorrect=false
            if [[ $2 == "set" ]]; then
                if [[ $currentHost == "true" ]]; then
                    if [[ $type == "xml" ]]; then
                        defaults -currentHost write $domain $setting $value
                    else
                        defaults -currentHost write $domain $setting -$type $value
                    fi
                else
                    if [[ $type == "xml" ]]; then
                        defaults write $domain $setting $value
                    else
                        defaults write $domain $setting -$type $value
                    fi
                fi
                print -P "%F{green}===> $description: Set $domain $setting to $expected (old value $current)%f"
            else
                print -P "%F{yellow}===> $description: $domain $setting ist set to $current instead of $expected%f"
            fi
        else
            if [[ ( $app != $lastApp || $description != $lastDescription ) && ( $2 == "verbose" || $3 == "verbose" ) ]]; then # Some settings are saved to multiple locations, only print out once
                print -P "%F{$correctColor}===> $description ist set correctly%f"
            fi
        fi

        lastApp=$app
        lastDescription=$description

    done < $1

    if [[ $allInAppCorrect && $2 != "verbose" && $3 != "verbose" ]]; then
        print -P "%F{$correctColor}===> $noDifference%f"
    fi
}

settings "$@"