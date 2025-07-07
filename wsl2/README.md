# WSL2 Ubuntu Setup

Modern Windows development environment using Windows Subsystem for Linux 2 (WSL2) with Ubuntu. This setup builds on the shared Linux setup and adds WSL2-specific features.

## Prerequisites

### Windows Requirements
- Windows 10 version 2004+ or Windows 11
- WSL2 installed and enabled
- Ubuntu distribution installed from Microsoft Store

### Enable WSL2 (if not already done)

1. **Enable WSL and Virtual Machine Platform** (as Administrator):
   ```powershell
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
   ```

2. **Restart Windows**

3. **Set WSL2 as default**:
   ```powershell
   wsl --set-default-version 2
   ```

4. **Install Ubuntu from Microsoft Store**

5. **Verify WSL2**:
   ```powershell
   wsl --list --verbose
   ```

## Quick Setup

```bash
# Clone dotfiles in WSL2 Ubuntu
git clone https://github.com/shhac/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Make scripts executable
chmod +x setup.sh */setup.sh

# Run WSL2 setup
./wsl2/setup.sh
```

## What Gets Installed

### Base Linux Setup
- Essential build tools (gcc, make, etc.)
- Git, vim, curl, wget, unzip
- Zsh and Oh My Zsh
- Node.js LTS
- Python 3 and pip
- Modern CLI Tools (exa, bat, fd, ripgrep)

### WSL2-Specific Additions
- **Docker** and Docker Compose
- **git-delta** - Better `git diff` with syntax highlighting

### Development Environment
- Oh My Zsh with custom theme and plugins
- Git configuration with aliases
- Custom shell functions and aliases
- WSL2-Windows interoperability
- X11 forwarding for GUI apps

## WSL2-Specific Features

### Windows Integration
- Selective Windows PATH integration
- Aliases for Windows tools (cmd, powershell, explorer)
- Git credential manager integration
- Functions to convert between WSL and Windows paths

### GUI Applications
- X11 forwarding setup for Linux GUI apps
- Support for VcXsrv, X410, or WSLg
- Test function to verify X11 setup

### Docker Integration
- Docker installed and configured
- User added to docker group
- Docker Compose included
- Useful Docker aliases

## Recommended Windows Tools

### Terminal
- **Windows Terminal** (Microsoft Store) - Modern terminal with tabs and themes
- **Oh My Posh** - Prompt themes for Windows Terminal

### Code Editors
- **VS Code** with Remote-WSL extension
- **Windows Terminal** with integrated development features

### X Server (for GUI apps)
- **VcXsrv** - Free X server for Windows
- **X410** - Paid X server from Microsoft Store
- **WSLg** - Built-in GUI support (Windows 11)

## Usage Examples

### File Operations
```bash
# Open current directory in Windows Explorer
open

# Convert paths
wslpath-win /home/user/project    # → C:\Users\user\AppData\Local\...
wslpath-wsl "C:\Users\user"       # → /mnt/c/Users/user
```

### Development
```bash
# Start development server
serve-here                        # Python HTTP server on :8000
serve-node                        # Node.js HTTP server on :8000

# Docker operations
d run -it ubuntu bash            # Run Ubuntu container
dc up -d                         # Start docker-compose services
dstop                            # Stop all running containers
```

### System Information
```bash
sysinfo                          # Show system information
wsl-ip                           # Show WSL2 IP address
win-ip                           # Show Windows host IP
```

## Troubleshooting

### Common Issues

1. **Docker permission denied**
   - Restart WSL2: `wsl --shutdown` from Windows PowerShell
   - Or log out and back in to apply group changes

2. **GUI apps not working**
   - Install and configure an X server on Windows
   - Test with: `test-x11`

3. **Windows tools not accessible**
   - Check if Windows PATH is properly set
   - Verify Windows tools exist at expected paths

### Reset WSL2 Environment
```bash
# From Windows PowerShell (will delete all WSL2 data!)
wsl --unregister Ubuntu
# Then reinstall Ubuntu from Microsoft Store
```

## File Structure

```
wsl2/
├── setup.sh              # Main WSL2 setup script (calls ../linux/setup.sh)
├── wsl-interop.sh         # Windows interoperability
├── x11-setup.sh           # GUI application support
├── wsl2-aliases.sh        # WSL2-specific aliases
└── README.md             # This file

../linux/
├── setup.sh              # Shared Linux base setup
└── linux-aliases.sh      # Linux-specific aliases
```