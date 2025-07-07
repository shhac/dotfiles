#!/bin/bash
# WSL2 Windows interoperability configuration

echo "Setting up WSL2-Windows interoperability..."

# Add Windows PATH integration (selective)
if ! grep -q "# WSL2 Windows PATH" ~/.zshrc; then
    cat >> ~/.zshrc << 'EOF'

# WSL2 Windows PATH integration
export WINDOWS_HOST=$(cat /etc/resolv.conf | grep nameserver | awk '{print $2}')

# Add useful Windows tools to PATH (selective)
export PATH="$PATH:/mnt/c/Windows/System32"
export PATH="$PATH:/mnt/c/Windows/System32/WindowsPowerShell/v1.0"

# Aliases for common Windows tools
alias cmd='/mnt/c/Windows/System32/cmd.exe'
alias powershell='/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
alias pwsh='/mnt/c/Program Files/PowerShell/7/pwsh.exe'
alias notepad='/mnt/c/Windows/System32/notepad.exe'
alias explorer='/mnt/c/Windows/explorer.exe'

# Function to open current directory in Windows Explorer
open() {
    if [ $# -eq 0 ]; then
        explorer.exe .
    else
        explorer.exe "$@"
    fi
}

# Function to convert WSL path to Windows path
wslpath-win() {
    wslpath -w "$1"
}

# Function to convert Windows path to WSL path
wslpath-wsl() {
    wslpath -u "$1"
}

EOF
fi

# Set up Git credential manager integration with Windows
if command -v git >/dev/null 2>&1; then
    # Use Windows Git Credential Manager if available
    if [ -f "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager.exe" ]; then
        git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"
    elif [ -f "/mnt/c/Program Files/Git/mingw64/bin/git-credential-manager-core.exe" ]; then
        git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager-core.exe"
    fi
fi

echo "✅ WSL2-Windows interoperability configured"