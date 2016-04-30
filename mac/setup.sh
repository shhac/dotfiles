# OSX Defaults
defaults write com.apple.Finder AppleShowAllFiles YES
defaults write com.apple.NetworkBrowser BrowseAllInterfaces 1
defaults write com.apple.Finder FXPreferredViewStyle Nlsv
sudo find / -name '.DS_Store' -exec rm {} \;
chflags nohidden ~/Library
# key repeat speed?
# No swipe navigation in Chrome
defaults write com.google.Chrome AppleEnableSwipeNavigateWithScrolls -bool FALSE

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

