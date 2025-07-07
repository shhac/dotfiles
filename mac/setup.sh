#!/bin/bash
# macOS setup script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Error handling function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

echo "🍎 Setting up macOS environment..."

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    error_exit "This script is only for macOS"
fi

# Install Homebrew if not present
if ! command -v brew >/dev/null 2>&1; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || error_exit "Homebrew installation failed"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ -f "/opt/homebrew/bin/brew" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
fi

# Update Homebrew
echo "📦 Updating Homebrew..."
brew update

# Essential development tools
echo "🔧 Installing essential tools..."
brew install git tig diff-so-fancy

# Modern development tools
echo "🚀 Installing modern development tools..."
brew install doppler graphite thefuck

# Additional utilities
echo "🛠️ Installing utilities..."
brew install rig tldr pwgen

# GUI applications (using modern syntax)
echo "📱 Installing GUI applications..."
brew install --cask font-fira-code visual-studio-code iterm2

# Python (remove python2 as it's deprecated)
echo "🐍 Installing Python..."
brew install python3

# Install NVM and setup Node.js
echo "📦 Setting up Node.js via NVM..."
if [ ! -d "$HOME/.nvm" ]; then
    mkdir -p ~/.nvm
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash || error_exit "NVM installation failed"
    
    # Source NVM for current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Install latest stable Node.js
    nvm install --lts
    nvm alias default lts/*
    nvm use default
    
    # Install global packages
    npm install -g npm-check git-open serve
fi

# Run macOS system configuration
echo "⚙️ Configuring macOS settings..."
if [ -f "$SCRIPT_DIR/osx-config.sh" ]; then
    source "$SCRIPT_DIR/osx-config.sh" || echo "Warning: macOS configuration partially failed"
fi

# Setup git configuration
echo "🔧 Setting up git..."
if [ -f "$SCRIPT_DIR/../git/setup.sh" ]; then
    source "$SCRIPT_DIR/../git/setup.sh" || error_exit "Git setup failed"
fi

# Setup shell configuration  
echo "🐚 Setting up shell..."
if [ -f "$SCRIPT_DIR/../shell/setup.sh" ]; then
    source "$SCRIPT_DIR/../shell/setup.sh" || error_exit "Shell setup failed"
fi

# Setup vim configuration
echo "📝 Setting up vim..."
if [ -f "$SCRIPT_DIR/../vim/setup.sh" ]; then
    source "$SCRIPT_DIR/../vim/setup.sh" || error_exit "Vim setup failed"
fi

# Add macOS-specific shell configuration
echo "🍎 Adding macOS shell configuration..."
if [ -f "$SCRIPT_DIR/osx-shell.sh" ]; then
    if ! grep -q "afk=" ~/.zshrc 2>/dev/null; then
        echo "" >> ~/.zshrc
        echo "# macOS-specific aliases" >> ~/.zshrc
        cat "$SCRIPT_DIR/osx-shell.sh" >> ~/.zshrc
    fi
fi

# Setup thefuck alias
if command -v thefuck >/dev/null 2>&1; then
    if ! grep -q "thefuck --alias eep" ~/.zshrc 2>/dev/null; then
        echo "" >> ~/.zshrc
        echo 'eval "$(thefuck --alias eep)"' >> ~/.zshrc
    fi
fi

echo "✅ macOS setup complete!"
echo ""
echo "🔄 Please restart your terminal or run 'source ~/.zshrc' to apply changes"
echo "🎨 For iTerm2 color scheme, manually import from: mac/iterm2-profiles/Default.json"