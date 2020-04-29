#!/usr/bin/env zsh

main() {

    killall "The Unarchiver" > /dev/null 2>&1

    # Don't modify date of extracted files
    defaults write cx.c3.theunarchiver changeDateOfFiles -bool false

    # Create folder only if there is more than one top level item
    defaults write cx.c3.theunarchiver createFolder -int 1

    # Delete archive after extraction
    defaults write cx.c3.theunarchiver deleteExtractedArchive -bool true

    # Extract to same folder as archive
    defaults write cx.c3.theunarchiver extractionDestination -int 1

    # Set modification date of the extracted folder to the modification data of the archive
    defaults write cx.c3.theunarchiver folderModifiedDate -int 2

    # Open extracted items in Finder
    defaults write cx.c3.theunarchiver selectExtractedItem -bool true

}

main "$@"
