# Terminal Theme

This terminal theme is based on https://github.com/nathanbuchar/atom-one-dark-terminal with some minor modifications.

## Use

The theme will be installed by the main script by inserting the content of `atom-one-dark.xml` into the correct plist file. If you want to install it manually, open the `atom-one-dark.terminal` file.

## Adjust

To adjust the theme, first install it, then change it in the settings of the terminal app. Finally you can  export it either into a `.terminal` directly from the settings, or you can generate an `.xml` file with this command: `plutil -extract Window\ Settings.atom-one-dark xml1 -o - ~/Library/Preferences/com.apple.Terminal.plist > theme.xml` (Thanks to https://apple.stackexchange.com/a/344464/229497)