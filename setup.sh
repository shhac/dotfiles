#!/bin/bash
# Main dotfiles setup script
set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command line arguments
INTERACTIVE=true
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes|--non-interactive)
            INTERACTIVE=false
            shift
            ;;
        -h|--help)
            echo "Dotfiles Setup Script"
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -y, --yes, --non-interactive    Run without prompts (auto-yes to all)"
            echo "  -h, --help                      Show this help message"
            echo ""
            echo "Interactive mode (default) will prompt for each component."
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Load common utilities
source "$DOTFILES_DIR/lib/utils.sh"

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
    # Check if we're in WSL2
    if [ -f /proc/version ] && grep -q Microsoft /proc/version; then
        OS_TYPE="WSL2"
    else
        OS_TYPE="Linux"
    fi
else
    warning "Unknown operating system: $OSTYPE"
fi

info "Detected OS: $OS_TYPE"
echo ""

# Show setup overview
echo "📋 Available components:"
echo "  🔧 Git configuration (aliases, user settings, workflow)"
echo "  🐚 Shell configuration (Oh My Zsh, custom themes, aliases)"
echo "  📝 Vim configuration (basic setup with sensible defaults)"
echo "  👻 Ghostty terminal configuration (fast modern terminal emulator)"
if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "  🍎 macOS configuration (Homebrew, system preferences, apps)"
elif [[ "$OS_TYPE" == "WSL2" ]]; then
    echo "  🐧 Linux base setup (development tools, modern CLI utilities)"
    echo "  🪟 WSL2 configuration (Docker, Windows integration, X11)"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo "  🐧 Linux configuration (development tools, modern CLI utilities)"
fi
echo ""

if [[ "$INTERACTIVE" == "true" ]]; then
    if ! prompt_yes_no "Continue with dotfiles setup?"; then
        echo "Setup cancelled by user."
        exit 0
    fi
    echo ""
fi

# Setup git configuration
if prompt_yes_no "Set up git configuration? (aliases, user settings, workflow)"; then
    echo "🔧 Setting up git configuration..."
    if [ -f "$DOTFILES_DIR/git/setup.sh" ]; then
        chmod +x "$DOTFILES_DIR/git/setup.sh"
        export INTERACTIVE
        source "$DOTFILES_DIR/git/setup.sh" || error_exit "Git setup failed"
        success "Git configuration complete"
    else
        error_exit "Git setup script not found"
    fi
    echo ""
else
    info "Skipping git configuration"
    echo ""
fi

# Setup shell configuration
if prompt_yes_no "Set up shell configuration? (Oh My Zsh, custom themes, aliases)"; then
    echo "🐚 Setting up shell configuration..."
    if [ -f "$DOTFILES_DIR/shell/setup.sh" ]; then
        chmod +x "$DOTFILES_DIR/shell/setup.sh"
        export INTERACTIVE
        source "$DOTFILES_DIR/shell/setup.sh" || error_exit "Shell setup failed"
        success "Shell configuration complete"
    else
        error_exit "Shell setup script not found"
    fi
    echo ""
else
    info "Skipping shell configuration"
    echo ""
fi

# Setup vim configuration
if prompt_yes_no "Set up vim configuration? (basic setup with sensible defaults)"; then
    echo "📝 Setting up vim configuration..."
    if [ -f "$DOTFILES_DIR/vim/setup.sh" ]; then
        chmod +x "$DOTFILES_DIR/vim/setup.sh"
        export INTERACTIVE
        source "$DOTFILES_DIR/vim/setup.sh" || error_exit "Vim setup failed"
        success "Vim configuration complete"
    else
        warning "Vim setup script not found, skipping"
    fi
    echo ""
else
    info "Skipping vim configuration"
    echo ""
fi

# Setup Ghostty terminal configuration
if prompt_yes_no "Set up Ghostty terminal configuration? (fast modern terminal emulator)"; then
    echo "👻 Setting up Ghostty terminal configuration..."
    if [ -f "$DOTFILES_DIR/ghostty/setup.sh" ]; then
        chmod +x "$DOTFILES_DIR/ghostty/setup.sh"
        export INTERACTIVE
        source "$DOTFILES_DIR/ghostty/setup.sh" || error_exit "Ghostty setup failed"
        success "Ghostty configuration complete"
    else
        warning "Ghostty setup script not found, skipping"
    fi
    echo ""
else
    info "Skipping Ghostty configuration"
    echo ""
fi

# Run OS-specific setup
if [[ "$OS_TYPE" == "macOS" ]]; then
    if prompt_yes_no "Set up macOS configuration? (Homebrew, system preferences, apps)"; then
        echo "🍎 Setting up macOS configuration..."
        if [ -f "$DOTFILES_DIR/mac/setup.sh" ]; then
            chmod +x "$DOTFILES_DIR/mac/setup.sh"
            export INTERACTIVE
            source "$DOTFILES_DIR/mac/setup.sh" || error_exit "macOS setup failed"
            success "macOS configuration complete"
        else
            warning "macOS setup script not found, skipping"
        fi
    else
        info "Skipping macOS configuration"
    fi
elif [[ "$OS_TYPE" == "WSL2" ]]; then
    if prompt_yes_no "Set up WSL2 Ubuntu configuration? (Linux base + Docker + Windows integration)"; then
        echo "🐧 Setting up WSL2 Ubuntu configuration..."
        if [ -f "$DOTFILES_DIR/wsl2/setup.sh" ]; then
            chmod +x "$DOTFILES_DIR/wsl2/setup.sh"
            export INTERACTIVE
            source "$DOTFILES_DIR/wsl2/setup.sh" || error_exit "WSL2 setup failed"
            success "WSL2 configuration complete"
        else
            warning "WSL2 setup script not found, skipping"
        fi
    else
        info "Skipping WSL2 configuration"
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    if prompt_yes_no "Set up Linux configuration? (development tools, modern CLI utilities)"; then
        echo "🐧 Setting up Linux configuration..."
        if [ -f "$DOTFILES_DIR/linux/setup.sh" ]; then
            chmod +x "$DOTFILES_DIR/linux/setup.sh"
            export INTERACTIVE
            source "$DOTFILES_DIR/linux/setup.sh" || error_exit "Linux setup failed"
            success "Linux configuration complete"
        else
            warning "Linux setup script not found, skipping"
        fi
    else
        info "Skipping Linux configuration"
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
echo "  • Ghostty terminal configuration"
if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "  • macOS system preferences"
    echo "  • Homebrew packages"
elif [[ "$OS_TYPE" == "WSL2" ]]; then
    echo "  • WSL2 Ubuntu packages and tools"
    echo "  • Docker and modern CLI tools"
    echo "  • Windows interoperability"
    echo "  • X11 forwarding for GUI apps"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo "  • Linux development packages"
    echo "  • Modern CLI tools"
    echo "  • Node.js and Python environments"
fi
echo ""
echo "🔄 Next steps:"
echo "  1. Restart your terminal or run 'source ~/.zshrc'"
echo "  2. Review git configuration with 'git config --global --list'"
if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "  3. Import iTerm2 color scheme from mac/iterm2-profiles/Default.json"
elif [[ "$OS_TYPE" == "WSL2" ]]; then
    echo "  3. Install Windows Terminal for better terminal experience"
    echo "  4. Install VcXsrv or X410 for GUI apps (or use WSLg on Windows 11)"
    echo "  5. Test Docker: 'docker run hello-world'"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo "  3. Install additional development tools as needed"
    echo "  4. Set up Docker if containerized development is required"
fi
echo ""
echo "📖 For individual component setup, run:"
echo "  • ./git/setup.sh     - Git configuration only"
echo "  • ./shell/setup.sh   - Shell configuration only"
echo "  • ./vim/setup.sh     - Vim configuration only"
echo "  • ./ghostty/setup.sh - Ghostty terminal configuration only"
if [[ "$OS_TYPE" == "macOS" ]]; then
    echo "  • ./mac/setup.sh    - macOS full setup"
elif [[ "$OS_TYPE" == "WSL2" ]]; then
    echo "  • ./wsl2/setup.sh   - WSL2 full setup"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo "  • ./linux/setup.sh  - Linux full setup"
fi