#!/usr/bin/env bash

main() {
    quit_system_preferences
    configure_system
    configure_dock
    configure_finder
    configure_menu_bar
    configure_calendar
    configure_xcode
    configure_safari
    configure_text_edit
    configure_app_store
    configure_terminal $1
    configure_misc
}

function quit_system_preferences() {
    # Close any open System Preferences panes, to prevent them from overriding
    # settings we’re about to change
    quit "System Preferences"
}

function configure_system() {
    # Enable Power Nap on all power modes
    sudo pmset -a darkwakes 1

    # Enable minimize on double click
    defaults write NSGlobalDomain AppleMiniaturizeOnDoubleClick -bool true
    defaults write NSGlobalDomain AppleActionOnDoubleClick -string "Minimize"

    # Increase window resize speed for Cocoa applications
    defaults write NSGlobalDomain NSWindowResizeTime -float 0.07

    # Expand save panel by default
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Save to disk (not to iCloud) by default
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Automatically quit printer app once the print jobs complete
    defaults write com.apple.print.PrintingPrefs "Quit When Finished" -bool true

    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

    # Map `click or tap with two fingers` to the secondary click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 0
    defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 0

    # Enable three finger drag
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
    defaults -currentHost write -g com.apple.trackpad.threeFingerDragGesture -bool true
    defaults -currentHost write -g com.apple.trackpad.threeFingerHorizSwipeGesture -int 0
    defaults -currentHost write -g com.apple.trackpad.threeFingerVertSwipeGesture -int 0

    # Look up
    # Tap with three fingers
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2

    # Enable full keyboard access for all controls which enables Tab selection in modal dialogs
    defaults write NSGlobalDomain AppleKeyboardUIMode -int 3
}

function configure_dock() {
    # Set the icon size of Dock items to 53 pixels
    defaults write com.apple.dock tilesize -int 53

    # Lock the dock size
    defaults write com.apple.Dock size-immutable -bool yes

    # Enable Dock Magnification
    defaults write com.apple.dock magnification -bool true

    # Enable App Exposé
    # Swipe down with three/four fingers
    defaults write com.apple.dock showAppExposeGestureEnabled -bool true

    # Disable Automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false

    # Allow scrolling to open and close stacks
    defaults write com.apple.dock scroll-to-open -bool true

    ## Hot corners
    ## Possible values:
    ##  0: no-op
    ##  2: Mission Control
    ##  3: Show application windows
    ##  4: Desktop
    ##  5: Start screen saver
    ##  6: Disable screen saver
    ##  7: Dashboard
    ## 10: Put display to sleep
    ## 11: Launchpad
    ## 12: Notification Center
    ## Top right screen corner → Notification Center
    defaults write com.apple.dock wvous-tr-corner -int 12
    defaults write com.apple.dock wvous-tr-modifier -int 0
    ## Bottom right screen corner → Desktop
    defaults write com.apple.dock wvous-br-corner -int 4
    defaults write com.apple.dock wvous-br-modifier -int 0

    # Restart
    quit "Dock"
}

function configure_finder() {
    # open new windows in my home dir
    defaults write com.apple.finder NewWindowTarget -string "PfHm"
    defaults write com.apple.finder NewWindowTargetPath -string "file://$HOME"

    # Show icons for hard drives, servers, and removable media on the desktop
    defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
    defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
    defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # enable status bar
    defaults write com.apple.finder ShowStatusBar -bool true

    # enable path bar
    defaults write com.apple.finder ShowPathbar -bool true

    # Show full path in title
    defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

    # When performing a search, search the current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # show all filename extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true

    # Disable the warning when changing a file extension
    defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Automatically open a new Finder window when a volume is mounted
    defaults write com.apple.frameworks.diskimages auto-open-ro-root -bool true
    defaults write com.apple.frameworks.diskimages auto-open-rw-root -bool true
    defaults write com.apple.finder OpenWindowForNewRemovableDisk -bool true

    # Enable snap-to-grid for icons on the desktop and in other icon views
    /usr/libexec/PlistBuddy -c "Set :DesktopViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :FK_StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist
    /usr/libexec/PlistBuddy -c "Set :StandardViewSettings:IconViewSettings:arrangeBy grid" ~/Library/Preferences/com.apple.finder.plist

    # Enable AirDrop over Ethernet and on unsupported Macs running Lion
    defaults write com.apple.NetworkBrowser BrowseAllInterfaces -bool true

    # Expand the following File Info panes:
    # “General”, “Open with”, and “Sharing & Permissions”
    defaults write com.apple.finder FXInfoPanesExpanded -dict \
    	General -bool true \
    	OpenWith -bool true \
    	Privileges -bool true

    # Do not write .DS_Store files on Network and USB devices
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Restart
    quit "Finder"
}

function configure_menu_bar() {
    # Show some more icons
    defaults write com.apple.systemuiserver menuExtras -array \
      "/System/Library/CoreServices/Menu Extras/Bluetooth.menu" \
      "/System/Library/CoreServices/Menu Extras/Battery.menu" \
      "/System/Library/CoreServices/Menu Extras/Clock.menu" \
      "/System/Library/CoreServices/Menu Extras/User.menu" \
      "/System/Library/CoreServices/Menu Extras/AirPort.menu" \
      "/System/Library/CoreServices/Menu Extras/Volume.menu" \
      "/System/Library/CoreServices/Menu Extras/Displays.menu"

    # Show battery percentage
    defaults write com.apple.menuextra.battery ShowPercent -bool true

    # Format for clock
    defaults write com.apple.menuextra.clock DateFormat -string 'EEE MMM d  HH:mm:ss'
    defaults write com.apple.menuextra.clock FlashDateSeparators -bool false
    defaults write com.apple.menuextra.clock IsAnalog -bool false

    # Restart
    quit SystemUIServer
}

function configure_calendar() {
  quit "Calendar"

  # Start Week on Monday
  defaults write com.apple.iCal "first day of week" -int 1

  # Show week numbers
  defaults write com.apple.iCal "Show Week Numbers" -bool true

  # Show events in year view
  defaults write com.apple.iCal "Show heat map in Year View" -bool true

  # Enable time zone support
  defaults write com.apple.iCal "TimeZone support enabled" -bool true

  # Show 18 hours
  defaults write com.apple.iCal "number of hours displayed" -int 18
}

function configure_xcode() {
    quit "Xcode"

    # Trim trailing whitespace
    defaults write com.apple.dt.Xcode DVTTextEditorTrimTrailingWhitespace -bool true

    # Trim whitespace only lines
    defaults write com.apple.dt.Xcode DVTTextEditorTrimWhitespaceOnlyLines -bool true

    # Show line numbers
    defaults write com.apple.dt.Xcode DVTTextShowLineNumbers -bool true
}

function configure_safari() {
    quit "Safari"

    # Disable AutoFill
    defaults write com.apple.Safari AutoFillFromAddressBook -bool false
    defaults write com.apple.Safari AutoFillPasswords -bool false
    defaults write com.apple.Safari AutoFillCreditCardData -bool false
    defaults write com.apple.Safari AutoFillMiscellaneousForms -bool false

    # Enable “Do Not Track”
    defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
}

function configure_text_edit() {
    quit "TextEdit"

    # Enable Grammar check
    defaults write com.apple.TextEdit CheckGrammarWithSpelling -bool true

    # Use plain text mode for new TextEdit documents
    defaults write com.apple.TextEdit RichText -int 0

    # Show HTML as source code
    defaults write com.apple.TextEdit IgnoreHTML -bool true

    # Open and save files as UTF-8 in TextEdit
    defaults write com.apple.TextEdit PlainTextEncoding -int 4
    defaults write com.apple.TextEdit PlainTextEncodingForWrite -int 4
}

function configure_app_store() {
    quit "App Store"

    # Enable the automatic update check
    defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

    # Check for software updates daily, not just once per week
    defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

    # Download newly available updates in background
    defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

    # Turn on app auto-update
    defaults write com.apple.commerce AutoUpdate -bool true
}

function configure_terminal() {
    start=$(grep -n "<dict>" $1/terminal-theme/atom-one-dark.terminal | cut -f1 -d:)
    end=$(grep -n "</dict>" $1/terminal-theme/atom-one-dark.terminal | cut -f1 -d:)
    theme=$(tail -n +$start $1/terminal-theme/atom-one-dark.terminal | head -n $((end-start+1)))
    defaults write com.apple.terminal "Window Settings" -dict-add "atom-one-dark" "$theme"
    defaults write com.apple.terminal "Default Window Settings" -string "atom-one-dark"
    defaults write com.apple.terminal "Startup Window Settings" -string "atom-one-dark"
}

function configure_misc() {
    # Prevent Time Machine from prompting to use new hard drives as backup volume
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true

    # Prevent Photos from opening automatically when devices are plugged in
    defaults -currentHost write com.apple.ImageCapture disableHotPlug -bool true
}

function quit() {
    app=$1
    killall "$app" > /dev/null 2>&1
}

main "$@"
