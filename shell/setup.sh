#!/bin/bash
# Shell configuration setup
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Error handling function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

echo "🐚 Setting up shell configuration..."

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh My Zsh..."
    # Use updated repository URL
    CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || error_exit "Oh My Zsh installation failed"
fi

# Install Powerline fonts via Homebrew (more reliable than git clone)
echo "🔤 Installing Powerline fonts..."
if command -v brew >/dev/null 2>&1; then
    brew tap homebrew/cask-fonts 2>/dev/null || true
    brew install --cask font-meslo-lg-nerd-font font-fira-code-nerd-font 2>/dev/null || echo "Fonts may already be installed"
else
    echo "Warning: Homebrew not found, skipping font installation"
fi

# Create configuration directory
echo "📁 Creating configuration directories..."
mkdir -p ~/.zsh/conf.d

# Copy configuration files locally
echo "📄 Installing shell configuration files..."
cp "$SCRIPT_DIR/conf.d/"* ~/.zsh/conf.d/ || error_exit "Failed to copy configuration files"

# Copy custom theme if it exists
if [ -f "$SCRIPT_DIR/themes/ataganoster.zsh-theme" ]; then
    echo "🎨 Installing custom theme..."
    cp "$SCRIPT_DIR/themes/ataganoster.zsh-theme" ~/.oh-my-zsh/themes/
fi

# Update .zshrc with custom configuration loading if not already present
echo "⚙️ Configuring .zshrc..."
if ! grep -q "Load custom configurations" ~/.zshrc 2>/dev/null; then
    cat << 'EOF' >> ~/.zshrc

# Load custom configurations
for file in ~/.zsh/conf.d/*; do
    [ -r "$file" ] && source "$file"
done
EOF
fi

# Set up Oh My Zsh plugins
echo "🔌 Configuring Oh My Zsh plugins..."
if [ -f ~/.zshrc ]; then
    # Update plugins to include git-open if not already present
    if grep -q "plugins=(git)" ~/.zshrc && ! grep -q "git-open" ~/.zshrc; then
        sed -i.bak 's/plugins=(git)/plugins=(git git-open)/' ~/.zshrc
    fi
    
    # Set theme to ataganoster if available and not already set
    if [ -f ~/.oh-my-zsh/themes/ataganoster.zsh-theme ] && ! grep -q 'ZSH_THEME="ataganoster"' ~/.zshrc; then
        sed -i.bak 's/ZSH_THEME="[^"]*"/ZSH_THEME="ataganoster"/' ~/.zshrc
    fi
    
    # Set DEFAULT_USER for theme if not already set
    if ! grep -q "DEFAULT_USER" ~/.zshrc; then
        # Add DEFAULT_USER after ZSH_THEME line
        sed -i.bak '/ZSH_THEME=/a\
\
export DEFAULT_USER="paul"' ~/.zshrc
    fi
fi

# Set up local environment PATH
echo "🛤️ Setting up local environment..."
if [ -f "$SCRIPT_DIR/local-env.sh" ]; then
    source "$SCRIPT_DIR/local-env.sh" || echo "Warning: Local environment setup failed"
fi

echo "✅ Shell configuration complete!"
echo ""
echo "🔄 Please restart your terminal or run 'source ~/.zshrc' to apply changes"