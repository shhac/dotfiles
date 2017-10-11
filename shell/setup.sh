sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/zsh.sh)"
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/fonts.sh)"

echo "" >> ~/.zshrc
curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/aliases.sh >> ~/.zshrc

