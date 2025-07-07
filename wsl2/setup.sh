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

# Check if we're in WSL2
if [ ! -f /proc/version ] || ! grep -q Microsoft /proc/version; then
    error_exit "This script is designed for WSL2 Ubuntu environment"
fi

# Run base Linux setup first
info "Running base Linux setup..."
LINUX_SETUP="$SCRIPT_DIR/../linux/setup.sh"
if [ -f "$LINUX_SETUP" ]; then
    chmod +x "$LINUX_SETUP"
    source "$LINUX_SETUP" || error_exit "Base Linux setup failed"
    success "Base Linux setup complete"
else
    error_exit "Linux setup script not found at $LINUX_SETUP"
fi

# Install git-delta for better diffs
info "Installing git-delta..."
DELTA_VERSION="0.16.5"
if ! command -v delta >/dev/null 2>&1; then
    wget -q "https://github.com/dandavison/delta/releases/download/${DELTA_VERSION}/git-delta_${DELTA_VERSION}_amd64.deb" -O /tmp/git-delta.deb
    sudo dpkg -i /tmp/git-delta.deb || sudo apt-get install -f -y
    rm /tmp/git-delta.deb
    success "git-delta installed"
else
    info "git-delta already installed: $(delta --version)"
fi

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

# Add WSL2-specific aliases to shell configuration
if [ -f "$SCRIPT_DIR/wsl2-aliases.sh" ] && [ -f ~/.zshrc ] && ! grep -q "wsl2-aliases.sh" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# WSL2-specific aliases" >> ~/.zshrc
    echo "[ -f \"$SCRIPT_DIR/wsl2-aliases.sh\" ] && source \"$SCRIPT_DIR/wsl2-aliases.sh\"" >> ~/.zshrc
    success "WSL2 aliases added to ~/.zshrc"
fi

echo ""
echo "🎉 WSL2 Ubuntu setup complete!"
echo ""
echo "📋 What was configured:"
echo "  • Base Linux development environment (via shared setup)"
echo "  • git-delta for enhanced git diffs"
echo "  • Docker and Docker Compose"
echo "  • Windows interoperability features"
echo "  • X11 forwarding for GUI applications"
echo "  • WSL2-specific aliases and functions"
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