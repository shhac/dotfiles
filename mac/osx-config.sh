# OSX Defaults
# Show all files and extensions, in list mode
defaults write com.apple.Finder AppleShowAllFiles YES
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1
defaults write com.apple.Finder FXPreferredViewStyle Nlsv
sudo find / -name '.DS_Store' -exec rm {} \;
chflags nohidden ~/Library
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Trackpad bottom right for right-click
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadCornerSecondaryClick -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.trackpadCornerClickBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Disable "natural" scrolling
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Fast key repeat speed
defaults write NSGlobalDomain ApplePressAndHoldEnabled -int 0
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# No swipe navigation in Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool FALSE

# Save screenshots as PNG with no shadow to a folder on the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# No automatic substitution
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

