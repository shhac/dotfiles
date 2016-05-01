#################################################
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
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
# Fast key repeat speed
defaults write NSGlobalDomain KeyRepeat -int 0
# No swipe navigation in Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool FALSE
# Save screenshots as PNG with no shadow to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
# Show icons for hard drives, servers, and removable media on the desktop
defaults write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool true
defaults write com.apple.finder ShowMountedServersOnDesktop -bool true
defaults write com.apple.finder ShowRemovableMediaOnDesktop -bool true

#################################################
# ZSH
# 1. Install
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
# 2. Theme

#################################################
# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew tap caskroom/cask

#################################################
# Git
# 1. Install
brew install git
# 2. Configure
sh -c "$(curl -fsSL https://raw.github.com/shhac/setup/master/git/settings.sh)"
sh -c "$(curl -fsSL https://raw.github.com/shhac/setup/master/git/aliases.sh)"

#################################################
# Powerline fonts
git clone https://github.com/powerline/fonts ~/powerline-fonts
~/powerline-fonts/install.sh
rm -rf ~/powerline-fonts

#################################################
# iterm2
# 1. Install
brew cask install iterm2
# 2. Theme

#################################################
# Environment/Framework/Etc
brew install node mongo robomongo
curl https://install.meteor.com/ | sh
