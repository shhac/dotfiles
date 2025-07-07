sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/zsh.sh)"
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/fonts.sh)"

mkdir -p ~/.zsh/conf.d

curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/conf.d/fns.sh > ~/.zsh/conf.d/fns.sh
curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/conf.d/git.sh > ~/.zsh/conf.d/git.sh
curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/conf.d/net.sh > ~/.zsh/conf.d/net.sh
curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/conf.d/npm.sh > ~/.zsh/conf.d/npm.sh
curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/conf.d/nvm.sh > ~/.zsh/conf.d/nvm.sh
curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/conf.d/utl.sh > ~/.zsh/conf.d/utl.sh
curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/conf.d/doppler.sh > ~/.zsh/conf.d/doppler.sh
curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/conf.d/gt.sh > ~/.zsh/conf.d/gt.sh
curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/conf.d/claude.sh > ~/.zsh/conf.d/claude.sh

echo "" >> ~/.zshrc
cat <<EOF >> ~/.zshrc
# Load in custom extensions
source <(cat ~/.zsh/conf.d/*)
EOF

