nr() {
  if [ -f ".nvmrc" ] && ! [ -z "$(command -v nvm)" ]; then
    nvm use
  fi
  npm run "${@}"
}

# Set PATH to contain user's global npm install location
if [[ ! -e ~/.npm-global ]]; then
    if command -v npm >/dev/null 2>&1; then
        echo "npm is installed but ~/.npm-global does not exist"
        if read -q '?Would you like to set it up [Y/n]? '; then
            mkdir ~/.npm-global
            npm config set prefix '~/.npm-global'
            echo  # newline
            echo "~/.npm-global set up"
        else
            echo  # newline
        fi
    fi
fi
export PATH=~/.npm-global/bin:$PATH

# Auto-setup npm global directory (non-interactive)
setup_npm_global() {
    if command -v npm >/dev/null 2>&1 && [[ ! -e ~/.npm-global ]]; then
        echo "Setting up npm global directory..."
        mkdir -p ~/.npm-global
        npm config set prefix '~/.npm-global'
        echo "✅ npm global directory configured at ~/.npm-global"
    fi
}

# Call setup automatically if in a setup script context
if [[ -n "$DOTFILES_SETUP" ]]; then
    setup_npm_global
fi

