#!/bin/bash
# WSL2 Ubuntu setup script
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

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

echo "🐧 Setting up WSL2 Ubuntu development environment..."
echo ""

# Check if we're in WSL2
if [ ! -f /proc/version ] || ! grep -q Microsoft /proc/version; then
    error_exit "This script is designed for WSL2 Ubuntu environment"
fi

info "Detected WSL2 environment"
echo ""

# Update system packages
echo "📦 Updating system packages..."
sudo apt update && sudo apt upgrade -y || error_exit "Failed to update packages"
success "System packages updated"
echo ""

# Install essential packages
echo "🔧 Installing essential development tools..."
sudo apt install -y \
    git \
    vim \
    curl \
    wget \
    unzip \
    build-essential \
    software-properties-common \
    apt-transport-https \
    ca-certificates \
    gnupg \
    lsb-release \
    zsh \
    tree \
    htop \
    jq \
    gpg || error_exit "Failed to install essential packages"

success "Essential tools installed"
echo ""

# Install Oh My Zsh if not present
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh My Zsh..."
    CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || error_exit "Oh My Zsh installation failed"
    success "Oh My Zsh installed"
else
    info "Oh My Zsh already installed"
fi
echo ""

# Install modern command-line tools
echo "🚀 Installing modern CLI tools..."

# Install exa (better ls)
if ! command -v exa >/dev/null 2>&1; then
    wget -qO- https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-x86_64-v0.10.1.zip | sudo unzip -d /usr/local/bin - exa-linux-x86_64
    sudo mv /usr/local/bin/exa-linux-x86_64 /usr/local/bin/exa
    sudo chmod +x /usr/local/bin/exa
fi

# Install bat (better cat)
if ! command -v bat >/dev/null 2>&1; then
    sudo apt install -y bat
    # Create symlink since Ubuntu packages it as batcat
    if [ ! -f /usr/local/bin/bat ] && [ -f /usr/bin/batcat ]; then
        sudo ln -sf /usr/bin/batcat /usr/local/bin/bat
    fi
fi

# Install fd (better find)
if ! command -v fd >/dev/null 2>&1; then
    sudo apt install -y fd-find
    # Create symlink since Ubuntu packages it as fdfind
    if [ ! -f /usr/local/bin/fd ] && [ -f /usr/bin/fdfind ]; then
        sudo ln -sf /usr/bin/fdfind /usr/local/bin/fd
    fi
fi

# Install ripgrep (better grep)
if ! command -v rg >/dev/null 2>&1; then
    sudo apt install -y ripgrep
fi

# Install delta (better git diff)
if ! command -v delta >/dev/null 2>&1; then
    wget -qO /tmp/delta.deb "https://github.com/dandavison/delta/releases/download/0.16.5/git-delta_0.16.5_amd64.deb"
    sudo dpkg -i /tmp/delta.deb || sudo apt-get install -f -y
    rm /tmp/delta.deb
fi

success "Modern CLI tools installed"
echo ""

# Install Node.js via NodeSource
echo "📦 Installing Node.js..."
if ! command -v node >/dev/null 2>&1; then
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    success "Node.js installed"
else
    info "Node.js already installed: $(node --version)"
fi
echo ""

# Install Python and pip
echo "🐍 Setting up Python..."
sudo apt install -y python3 python3-pip python3-venv
success "Python setup complete"
echo ""

# Install Docker if not present
echo "🐳 Installing Docker..."
if ! command -v docker >/dev/null 2>&1; then
    # Add Docker's official GPG key
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Add Docker repository
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Install Docker
    sudo apt update
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
    
    # Add user to docker group
    sudo usermod -aG docker $USER
    success "Docker installed (restart shell to use without sudo)"
else
    info "Docker already installed"
fi
echo ""

# Setup git configuration
echo "🔧 Setting up git..."
if [ -f "$SCRIPT_DIR/../git/setup.sh" ]; then
    source "$SCRIPT_DIR/../git/setup.sh" || error_exit "Git setup failed"
    success "Git configuration complete"
else
    warning "Git setup script not found, configuring basic git settings"
    git config --global init.defaultBranch main
    git config --global push.default simple
    git config --global pull.ff only
fi
echo ""

# Setup shell configuration
echo "🐚 Setting up shell configuration..."
if [ -f "$SCRIPT_DIR/../shell/setup.sh" ]; then
    source "$SCRIPT_DIR/../shell/setup.sh" || error_exit "Shell setup failed"
    success "Shell configuration complete"
else
    warning "Shell setup script not found, setting up basic zsh configuration"
    # Basic zsh setup
    if [ ! -f ~/.zshrc ] || ! grep -q "oh-my-zsh" ~/.zshrc; then
        cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc
    fi
fi
echo ""

# Setup vim configuration
echo "📝 Setting up vim..."
if [ -f "$SCRIPT_DIR/../vim/setup.sh" ]; then
    source "$SCRIPT_DIR/../vim/setup.sh" || error_exit "Vim setup failed"
    success "Vim configuration complete"
else
    warning "Vim setup script not found, skipping vim configuration"
fi
echo ""

# Create WSL2-specific configurations
echo "🪟 Setting up WSL2-specific configurations..."

# Set up Windows interop
if [ -f "$SCRIPT_DIR/wsl-interop.sh" ]; then
    source "$SCRIPT_DIR/wsl-interop.sh"
    success "WSL2 interop configured"
fi

# Set up X11 forwarding for GUI apps
if [ -f "$SCRIPT_DIR/x11-setup.sh" ]; then
    source "$SCRIPT_DIR/x11-setup.sh"
    success "X11 forwarding configured"
fi

echo ""
echo "🎉 WSL2 Ubuntu setup complete!"
echo ""
echo "📋 What was configured:"
echo "  • Essential development tools (git, vim, curl, build tools)"
echo "  • Oh My Zsh shell with custom configuration"
echo "  • Modern CLI tools (exa, bat, fd, ripgrep, delta)"
echo "  • Node.js LTS and npm"
echo "  • Python 3 and pip"
echo "  • Docker and Docker Compose"
echo "  • Git configuration and aliases"
echo "  • Custom shell functions and aliases"
echo ""
echo "🔄 Next steps:"
echo "  1. Restart your shell or run 'source ~/.zshrc'"
echo "  2. Restart WSL2 to apply Docker group changes: 'wsl --shutdown' from Windows"
echo "  3. Install Windows Terminal for a better terminal experience"
echo "  4. Consider installing VS Code with WSL extension"
echo ""
echo "💡 Recommended Windows tools:"
echo "  • Windows Terminal (from Microsoft Store)"
echo "  • VS Code with Remote-WSL extension"
echo "  • Git for Windows (for Windows-side git operations)"