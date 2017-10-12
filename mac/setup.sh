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
brew install git
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/git/setup.sh)"

# iterm2
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/mac/terminal.sh)"

#################################################

brew install thefuck
echo "" >> ~/.zshrc
echo "eval \"\$(thefuck --alias eep)\"" >> ~/.zshrc

# Environment/Framework/Etc
brew install python3 python2 pwgen nvm mongo
brew cask install robo-3t atom visual-studio-code

mkdir ~/.nvm
echo "" >> ~/.zshrc
echo "export NVM_DIR=\"\$HOME/.nvm\"" >> ~/.zshrc
echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && . \"$NVM_DIR/nvm.sh\" # This loads nvm" >> ~/.zshrc
nvm install stable --latest-npm
nvm alias default stable

nvm install --latest-npm
npm i -g eslint eslint-plugin-meteor npm-check

curl https://install.meteor.com/ | sh

