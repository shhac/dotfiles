#!/bin/bash
# Linux development environment setup
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

echo "🐧 Setting up Linux development environment..."

# Detect package manager
if command -v apt >/dev/null 2>&1; then
    PKG_MANAGER="apt"
    PKG_UPDATE="sudo apt update"
    PKG_INSTALL="sudo apt install -y"
elif command -v yum >/dev/null 2>&1; then
    PKG_MANAGER="yum"
    PKG_UPDATE="sudo yum update -y"
    PKG_INSTALL="sudo yum install -y"
elif command -v dnf >/dev/null 2>&1; then
    PKG_MANAGER="dnf"
    PKG_UPDATE="sudo dnf update -y"
    PKG_INSTALL="sudo dnf install -y"
elif command -v pacman >/dev/null 2>&1; then
    PKG_MANAGER="pacman"
    PKG_UPDATE="sudo pacman -Sy"
    PKG_INSTALL="sudo pacman -S --noconfirm"
else
    error_exit "No supported package manager found (apt, yum, dnf, pacman)"
fi

info "Detected package manager: $PKG_MANAGER"

# Update package lists
info "Updating package lists..."
$PKG_UPDATE

# Install essential packages
info "Installing essential development packages..."
if [[ "$PKG_MANAGER" == "apt" ]]; then
    $PKG_INSTALL \
        build-essential \
        curl \
        wget \
        git \
        vim \
        zsh \
        unzip \
        software-properties-common \
        apt-transport-https \
        ca-certificates \
        gnupg \
        lsb-release
elif [[ "$PKG_MANAGER" == "yum" ]] || [[ "$PKG_MANAGER" == "dnf" ]]; then
    $PKG_INSTALL \
        gcc \
        gcc-c++ \
        make \
        curl \
        wget \
        git \
        vim \
        zsh \
        unzip
elif [[ "$PKG_MANAGER" == "pacman" ]]; then
    $PKG_INSTALL \
        base-devel \
        curl \
        wget \
        git \
        vim \
        zsh \
        unzip
fi

success "Essential packages installed"

# Install modern CLI tools
info "Installing modern CLI tools..."
install_modern_tools() {
    # Try to install via package manager first, fall back to manual installation
    
    # exa (better ls)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        if ! $PKG_INSTALL exa 2>/dev/null; then
            # Install via cargo if available, or download binary
            if command -v cargo >/dev/null 2>&1; then
                cargo install exa
            else
                warning "Could not install exa automatically"
            fi
        fi
    else
        if command -v cargo >/dev/null 2>&1; then
            cargo install exa
        else
            warning "exa not available for $PKG_MANAGER, consider installing Rust/Cargo"
        fi
    fi
    
    # bat (better cat)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        $PKG_INSTALL bat || warning "Could not install bat"
    elif [[ "$PKG_MANAGER" == "pacman" ]]; then
        $PKG_INSTALL bat || warning "Could not install bat"
    else
        warning "bat not available for $PKG_MANAGER"
    fi
    
    # fd (better find)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        $PKG_INSTALL fd-find || warning "Could not install fd-find"
    elif [[ "$PKG_MANAGER" == "pacman" ]]; then
        $PKG_INSTALL fd || warning "Could not install fd"
    else
        warning "fd not available for $PKG_MANAGER"
    fi
    
    # ripgrep (better grep)
    if [[ "$PKG_MANAGER" == "apt" ]]; then
        $PKG_INSTALL ripgrep || warning "Could not install ripgrep"
    elif [[ "$PKG_MANAGER" == "pacman" ]]; then
        $PKG_INSTALL ripgrep || warning "Could not install ripgrep"
    else
        warning "ripgrep not available for $PKG_MANAGER"
    fi
}

install_modern_tools
success "Modern CLI tools installation attempted"

# Install Node.js via NodeSource repository (for apt-based systems)
if [[ "$PKG_MANAGER" == "apt" ]]; then
    info "Installing Node.js LTS..."
    if ! command -v node >/dev/null 2>&1; then
        curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
        $PKG_INSTALL nodejs
        success "Node.js installed"
        
        # Set up npm global directory configuration
        export DOTFILES_SETUP=1
        if [ -f "$SCRIPT_DIR/../shell/conf.d/npm.sh" ]; then
            source "$SCRIPT_DIR/../shell/conf.d/npm.sh"
        fi
        unset DOTFILES_SETUP
    else
        info "Node.js already installed: $(node --version)"
    fi
fi

# Install Python 3 and pip
info "Installing Python 3 and pip..."
if [[ "$PKG_MANAGER" == "apt" ]]; then
    $PKG_INSTALL python3 python3-pip
elif [[ "$PKG_MANAGER" == "yum" ]] || [[ "$PKG_MANAGER" == "dnf" ]]; then
    $PKG_INSTALL python3 python3-pip
elif [[ "$PKG_MANAGER" == "pacman" ]]; then
    $PKG_INSTALL python python-pip
fi
success "Python 3 and pip installed"

# Create linux-specific aliases file
info "Creating Linux-specific aliases..."
cat > "$SCRIPT_DIR/linux-aliases.sh" << 'EOF'
# Linux-specific aliases and functions

# Modern command replacements
if command -v exa >/dev/null 2>&1; then
    alias ls='exa'
    alias ll='exa -l'
    alias la='exa -la'
    alias lt='exa --tree'
fi

if command -v bat >/dev/null 2>&1; then
    alias cat='bat'
    alias less='bat'
fi

if command -v fd >/dev/null 2>&1; then
    alias find='fd'
elif command -v fdfind >/dev/null 2>&1; then
    alias find='fdfind'
    alias fd='fdfind'
fi

if command -v rg >/dev/null 2>&1; then
    alias grep='rg'
fi

# System management aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Quick directory navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'

# System information
alias sysinfo='echo "Linux System Information:" && uname -a && echo && df -h && echo && free -h'

# Network utilities
alias myip='curl -s ifconfig.me'
alias ports='netstat -tulanp'

# Development server shortcuts
alias serve-here='python3 -m http.server 8000'
alias serve-node='npx http-server -p 8000'

# File operations
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -p'

# Process management
alias psg='ps aux | grep'
alias topcpu='ps aux --sort=-%cpu | head'
alias topmem='ps aux --sort=-%mem | head'

# Package management shortcuts
if command -v apt >/dev/null 2>&1; then
    alias update='sudo apt update && sudo apt upgrade'
    alias install='sudo apt install'
    alias search='apt search'
elif command -v yum >/dev/null 2>&1; then
    alias update='sudo yum update'
    alias install='sudo yum install'
    alias search='yum search'
elif command -v dnf >/dev/null 2>&1; then
    alias update='sudo dnf update'
    alias install='sudo dnf install'
    alias search='dnf search'
elif command -v pacman >/dev/null 2>&1; then
    alias update='sudo pacman -Syu'
    alias install='sudo pacman -S'
    alias search='pacman -Ss'
fi
EOF

success "Linux-specific aliases created"

# Add Linux aliases to shell configuration
if [ -f ~/.zshrc ] && ! grep -q "linux-aliases.sh" ~/.zshrc; then
    echo "" >> ~/.zshrc
    echo "# Linux-specific aliases" >> ~/.zshrc
    echo "[ -f \"$SCRIPT_DIR/linux-aliases.sh\" ] && source \"$SCRIPT_DIR/linux-aliases.sh\"" >> ~/.zshrc
    success "Linux aliases added to ~/.zshrc"
fi

echo ""
success "Linux development environment setup complete!"
echo ""
info "What was installed:"
echo "  • Essential development tools (gcc, make, curl, git, vim, zsh)"
echo "  • Modern CLI tools (exa, bat, fd, ripgrep - where available)"
echo "  • Node.js LTS (on Ubuntu/Debian)"
echo "  • Python 3 and pip"
echo "  • Linux-specific aliases and functions"
echo ""
info "Next steps:"
echo "  1. Restart your terminal or run 'source ~/.zshrc'"
echo "  2. Consider installing additional tools specific to your distribution"
echo "  3. Set up Docker if needed for containerized development"