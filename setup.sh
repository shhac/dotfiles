#!/bin/bash
# Main dotfiles setup script
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling function
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Success message function
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Warning message function
warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Info message function
info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

echo "🚀 Starting dotfiles setup..."
echo "📂 Dotfiles directory: $DOTFILES_DIR"
echo ""

# Check prerequisites
info "Checking prerequisites..."
command -v git >/dev/null 2>&1 || error_exit "git is required but not installed"
command -v curl >/dev/null 2>&1 || error_exit "curl is required but not installed"

# Detect operating system
OS_TYPE=""
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="Linux"
elif [[ "$OSTYPE" == "cygwin" ]]; then
    OS_TYPE="Cygwin"
else
    warning "Unknown operating system: $OSTYPE"
fi

info "Detected OS: $OS_TYPE"
echo ""

# Setup git configuration
echo "🔧 Setting up git configuration..."
if [ -f "$DOTFILES_DIR/git/setup.sh" ]; then
    chmod +x "$DOTFILES_DIR/git/setup.sh"
    source "$DOTFILES_DIR/git/setup.sh" || error_exit "Git setup failed"
    success "Git configuration complete"
else
    error_exit "Git setup script not found"
fi
echo ""

# Setup shell configuration  
echo "🐚 Setting up shell configuration..."
if [ -f "$DOTFILES_DIR/shell/setup.sh" ]; then
    chmod +x "$DOTFILES_DIR/shell/setup.sh"
    source "$DOTFILES_DIR/shell/setup.sh" || error_exit "Shell setup failed"
    success "Shell configuration complete"
else
    error_exit "Shell setup script not found"
fi
echo ""

# Setup vim configuration
echo "📝 Setting up vim configuration..."
if [ -f "$DOTFILES_DIR/vim/setup.sh" ]; then
    chmod +x "$DOTFILES_DIR/vim/setup.sh"
    source "$DOTFILES_DIR/vim/setup.sh" || error_exit "Vim setup failed"
    success "Vim configuration complete"
else
    warning "Vim setup script not found, skipping"
fi
echo ""

# Run OS-specific setup
if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "🍎 Setting up macOS configuration..."
    if [ -f "$DOTFILES_DIR/mac/setup.sh" ]; then
        chmod +x "$DOTFILES_DIR/mac/setup.sh"
        source "$DOTFILES_DIR/mac/setup.sh" || error_exit "macOS setup failed"
        success "macOS configuration complete"
    else
        warning "macOS setup script not found, skipping"
    fi
elif [[ "$OS_TYPE" == "Cygwin" ]]; then
    echo "🖥️ Setting up Cygwin configuration..."
    if [ -f "$DOTFILES_DIR/cygwin/setup.sh" ]; then
        chmod +x "$DOTFILES_DIR/cygwin/setup.sh"
        source "$DOTFILES_DIR/cygwin/setup.sh" || error_exit "Cygwin setup failed"
        success "Cygwin configuration complete"
    else
        warning "Cygwin setup script not found, skipping"
    fi
fi

echo ""
echo "🎉 Dotfiles setup complete!"
echo ""
echo "📋 What was configured:"
echo "  • Git aliases and configuration"
echo "  • Shell (zsh) with Oh My Zsh"
echo "  • Custom shell functions and aliases"
echo "  • Vim configuration"
if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "  • macOS system preferences"
    echo "  • Homebrew packages"
fi
echo ""
echo "🔄 Next steps:"
echo "  1. Restart your terminal or run 'source ~/.zshrc'"
echo "  2. Review git configuration with 'git config --global --list'"
if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "  3. Import iTerm2 color scheme from mac/iterm2-profiles/Default.json"
fi
echo ""
echo "📖 For individual component setup, run:"
echo "  • ./git/setup.sh    - Git configuration only"
echo "  • ./shell/setup.sh  - Shell configuration only"
echo "  • ./vim/setup.sh    - Vim configuration only"
if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "  • ./mac/setup.sh    - macOS full setup"
fi