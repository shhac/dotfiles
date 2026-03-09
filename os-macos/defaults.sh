# macOS Defaults

# Show all files, use column view
sudo defaults write com.apple.Finder AppleShowAllFiles YES
sudo defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1
sudo defaults write com.apple.Finder FXPreferredViewStyle clmv
# sudo find / -name '.DS_Store' -exec rm {} \;
chflags nohidden ~/Library

# Trackpad: two-finger right-click (no corner click)
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true
defaults -currentHost write NSGlobalDomain com.apple.trackpad.enableSecondaryClick -bool true

# Disable "natural" scrolling
# defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false

# Fast key repeat speed
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
defaults write NSGlobalDomain KeyRepeat -int 1
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# Save screenshots as PNG with no shadow
defaults write com.apple.screencapture location -string "${HOME}/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true

# Show icons for external drives and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

# No automatic substitution
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
