# OSX settings
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/mac/osx-config.sh)"

# Shell
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/setup.sh)"
echo "" >> ~/.zshrc
curl -fsSL https://raw.github.com/shhac/dotfiles/master/mac/osx-shell.sh >> ~/.zshrc

# Homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
brew upgrade

# git
brew install git tig
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/git/setup.sh)"

# iterm2
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/mac/terminal.sh)"

#################################################

brew install rig tldr

# Modern development tools
brew install doppler graphite

brew install thefuck
echo "" >> ~/.zshrc
echo "eval \"\$(thefuck --alias eep)\"" >> ~/.zshrc

# Environment/Framework/Etc
brew install python3 python2 pwgen
brew cask install font-fira-code visual-studio-code

# Install NVM
mkdir ~/.nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.1/install.sh | bash
# echo "" >> ~/.zshrc
# echo "export NVM_DIR=\"\$HOME/.nvm\"" >> ~/.zshrc
# echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\" # This loads nvm" >> ~/.zshrc
nvm install stable --latest-npm
nvm alias default 'lts/*'

nvm install --latest-npm
npm i -g npm-check git-open serve

# curl https://install.meteor.com/ | sh

