#!/bin/bash
# Shell configuration setup
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common utilities if available
if [ -f "$SCRIPT_DIR/../lib/utils.sh" ]; then
    source "$SCRIPT_DIR/../lib/utils.sh"
else
    # Fallback functions if utils not available
    error_exit() { echo "Error: $1" >&2; exit 1; }
    success() { echo "✅ $1"; }
    info() { echo "ℹ️ $1"; }
    warning() { echo "⚠️ $1"; }
    prompt_yes_no() { 
        [[ "${INTERACTIVE:-true}" == "false" ]] && return 0
        read -p "$1 [Y/n]: " response
        [[ "$response" =~ ^[Nn] ]] && return 1 || return 0
    }
fi

echo "🐚 Setting up shell configuration..."

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if prompt_yes_no "Install Oh My Zsh? (enhanced shell with themes and plugins)"; then
        echo "📦 Installing Oh My Zsh..."
        # Use updated repository URL
        CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || error_exit "Oh My Zsh installation failed"
        success "Oh My Zsh installed"
    else
        info "Skipping Oh My Zsh installation"
    fi
else
    info "Oh My Zsh already installed"
fi

# Install Powerline fonts via Homebrew (more reliable than git clone)
if command -v brew >/dev/null 2>&1; then
    if prompt_yes_no "Install programming fonts? (Nerd Fonts with icons and ligatures)"; then
        echo "🔤 Installing Powerline fonts..."
        brew tap homebrew/cask-fonts 2>/dev/null || true
        brew install --cask font-meslo-lg-nerd-font font-fira-code-nerd-font 2>/dev/null || echo "Fonts may already be installed"
        success "Programming fonts installed"
    else
        info "Skipping font installation"
    fi
else
    warning "Homebrew not found, skipping font installation"
fi

# Configure shell environment
if prompt_yes_no "Install custom shell configurations? (aliases, functions, completions)"; then
    echo "📁 Creating configuration directories..."
    mkdir -p ~/.zsh/conf.d

    echo "📄 Installing shell configuration files..."
    cp "$SCRIPT_DIR/conf.d/"* ~/.zsh/conf.d/ || error_exit "Failed to copy configuration files"
    success "Shell configuration files installed"
else
    info "Skipping shell configuration files"
fi

# Copy custom theme if it exists
if [ -f "$SCRIPT_DIR/themes/ataganoster.zsh-theme" ]; then
    if prompt_yes_no "Install custom ataganoster theme? (enhanced prompt with git info)"; then
        echo "🎨 Installing custom theme..."
        cp "$SCRIPT_DIR/themes/ataganoster.zsh-theme" ~/.oh-my-zsh/themes/
        success "Custom theme installed"
    else
        info "Skipping custom theme"
    fi
fi

# Update .zshrc with custom configuration loading if not already present
if prompt_yes_no "Configure .zshrc to load custom configurations?"; then
    echo "⚙️ Configuring .zshrc..."
    if ! grep -q "Load custom configurations" ~/.zshrc 2>/dev/null; then
        cat << 'EOF' >> ~/.zshrc

# Load custom configurations
for file in ~/.zsh/conf.d/*; do
    [ -r "$file" ] && source "$file"
done
EOF
        success "Custom configuration loading added to .zshrc"
    else
        info ".zshrc already configured for custom configurations"
    fi
else
    info "Skipping .zshrc configuration"
fi

# Set up Oh My Zsh plugins
if [ -f ~/.zshrc ]; then
    if prompt_yes_no "Configure Oh My Zsh plugins and theme?"; then
        echo "🔌 Configuring Oh My Zsh plugins..."
        # Update plugins to include git-open if not already present
        if grep -q "plugins=(git)" ~/.zshrc && ! grep -q "git-open" ~/.zshrc; then
            sed -i.bak 's/plugins=(git)/plugins=(git git-open)/' ~/.zshrc
            success "Added git-open plugin"
        fi
        
        # Set theme to ataganoster if available and not already set
        if [ -f ~/.oh-my-zsh/themes/ataganoster.zsh-theme ] && ! grep -q 'ZSH_THEME="ataganoster"' ~/.zshrc; then
            sed -i.bak 's/ZSH_THEME="[^"]*"/ZSH_THEME="ataganoster"/' ~/.zshrc
            success "Set ataganoster theme"
        fi
        
        # Set DEFAULT_USER for theme if not already set
        if ! grep -q "DEFAULT_USER" ~/.zshrc; then
            # Add DEFAULT_USER after ZSH_THEME line
            sed -i.bak '/ZSH_THEME=/a\
\
export DEFAULT_USER="paul"' ~/.zshrc
            success "Set DEFAULT_USER for theme"
        fi
    else
        info "Skipping Oh My Zsh plugin configuration"
    fi
fi

# Set up local environment PATH
if prompt_yes_no "Set up local environment configuration? (PATH and environment variables)"; then
    echo "🛤️ Setting up local environment..."
    if [ -f "$SCRIPT_DIR/local-env.sh" ]; then
        source "$SCRIPT_DIR/local-env.sh" || echo "Warning: Local environment setup failed"
        success "Local environment configured"
    else
        warning "Local environment script not found"
    fi
else
    info "Skipping local environment setup"
fi

success "Shell configuration complete!"
echo ""
info "Please restart your terminal or run 'source ~/.zshrc' to apply changes"