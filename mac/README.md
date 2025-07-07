# macOS Configuration

Complete macOS development environment setup with Homebrew, system preferences, and development tools.

## Quick Setup

```bash
# From dotfiles root
./mac/setup.sh

# Or as part of full setup
./setup.sh
```

## What Gets Installed

### Package Manager
- **Homebrew** - Package manager for macOS

### Development Tools
- **Git**, **Node.js** (via NVM), **Python 3**
- **Modern CLI tools**: exa, bat, fd, ripgrep, tealdeer
- **Development utilities**: tig, diff-so-fancy, doppler, graphite
- **Productivity tools**: thefuck, pwgen

### GUI Applications
- **Visual Studio Code** - Code editor
- **iTerm2** - Terminal emulator  
- **Fira Code** font - Programming font with ligatures

### System Configuration
- macOS system preferences optimization
- Development-friendly settings
- iTerm2 color scheme configuration

## Manual Steps

1. **Import iTerm2 theme**: Import `iterm2-profiles/Default.json` in iTerm2 Preferences
2. **Configure git user**: Update git user information if needed
3. **Restart terminal**: To apply all shell configuration changes

