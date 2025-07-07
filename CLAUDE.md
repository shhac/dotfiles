# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal dotfiles repository containing shell configurations, git aliases, and cross-platform system setup scripts for development environments. The repository supports macOS, Linux, and WSL2 with interactive setup scripts that allow users to choose which components to install. The repository is organized into platform-specific directories with setup scripts that configure development tools and shell environments.

## Key Components

### Core Utilities (`lib/`)
- **Shared functions** - Common utilities in `lib/utils.sh` for consistent experience across all scripts
- **Interactive prompts** - `prompt_yes_no()`, `prompt_choice()` for user-friendly setup
- **Consistent messaging** - `success()`, `info()`, `warning()`, `error_exit()` functions
- **Utility helpers** - `command_exists()`, `is_root()`, `get_script_dir()`

### Git Configuration (`git/`)
- **Git aliases** - Extensive set of git aliases configured via `git/aliases.sh`
- **Branch cleanup** - `git merged-remote-view/clean`, `git deleted-remote-view/clean`
- **Custom commit function** - `gm` function for conventional commits with format `type[scope]: message`
- **Interactive setup** - Prompts for aliases, push/pull settings, user config, diff tools

### Shell Configuration (`shell/`)
- **Zsh extensions** - Custom functions and aliases in `shell/conf.d/`
- **Theme** - Custom zsh theme at `shell/themes/ataganoster.zsh-theme`
- **Oh My Zsh integration** - Automated installation with plugin configuration
- **Font installation** - Programming fonts with Nerd Font support
- **Interactive setup** - Choose which shell components to install

### Platform-Specific Setup
#### macOS (`mac/`)
- **System configuration** - macOS settings and Homebrew package installation
- **Development tools** - Node.js (via NVM), Python, Visual Studio Code setup
- **Package management** - Homebrew with modern CLI tools (exa, bat, fd, ripgrep, tealdeer)
- **iTerm2 profiles** - Terminal configuration with color schemes

#### Linux (`linux/`)
- **Multi-distro support** - Works with apt, yum, dnf, pacman package managers
- **Development environment** - Essential build tools, git, vim, zsh
- **Modern CLI tools** - exa, bat, fd, ripgrep installation where available
- **Runtime environments** - Node.js LTS, Python 3, development packages

#### WSL2 (`wsl2/`)
- **Shared Linux base** - Builds on Linux setup for consistency
- **Docker integration** - Docker and Docker Compose with user permissions
- **Windows interoperability** - Selective PATH integration, Windows tool aliases
- **X11 forwarding** - GUI application support with VcXsrv/X410/WSLg
- **git-delta** - Enhanced git diff with syntax highlighting

### Vim Configuration (`vim/`)
- **Basic setup** - Sensible defaults with syntax highlighting
- **Cross-platform** - Works consistently across all supported platforms

## Setup Commands

### Initial Setup
```bash
# Clone repository first
git clone https://github.com/shhac/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Make scripts executable  
chmod +x setup.sh */setup.sh

# Interactive setup (recommended - prompts for each component)
./setup.sh

# Non-interactive setup (auto-yes to all prompts)
./setup.sh --yes

# Individual components (also interactive)
./mac/setup.sh      # macOS setup
./shell/setup.sh    # Shell configuration  
./git/setup.sh      # Git configuration
./linux/setup.sh    # Linux setup
./wsl2/setup.sh     # WSL2 setup
```

### Git Commit Function
The `gm` function provides structured commits:
```bash
gm feat api "add user authentication"    # feat[api]: add user authentication
gm fix - "resolve login issue"           # fix: resolve login issue
gm chore deps "update package versions"  # chore[deps]: update package versions
```

### Useful Git Aliases
- `git sw` - switch branches
- `git swc` - switch and create branch  
- `git st` - status with short format
- `git lg` - pretty log with graph
- `git please` - force push with lease
- `git commend` - amend without editing message
- `git merged-remote-view` - view merged remote branches
- `git merged-remote-clean` - delete merged remote branches
- `git deleted-remote-view` - view deleted remote branches (dry-run)
- `git deleted-remote-clean` - clean up deleted remote branch refs

### Interactive Setup Features
- **Component selection** - Choose which parts to install (git, shell, vim, platform-specific)
- **Graceful skipping** - Skip any component without breaking the setup
- **Non-interactive mode** - Use `--yes` flag for automation and CI/CD
- **Platform detection** - Automatically detects macOS, Linux, or WSL2
- **Consistent experience** - Same interactive prompts across all scripts
- **Fallback mechanisms** - Scripts work even if shared utilities aren't available

## Architecture Notes

- **Modular design** - Each platform/tool has its own directory with setup scripts
- **Interactive prompts** - All scripts support user-friendly prompts with graceful skipping
- **Shared utilities** - Common functions in `lib/utils.sh` for consistent experience across all scripts
- **Cross-platform support** - Native support for macOS, Linux (apt/yum/dnf/pacman), and WSL2
- **Local installation** - Setup scripts use local configuration files for reliable, offline-capable setup
- **Shell integration** - All custom functions/aliases loaded via `shell/conf.d/` directory
- **Git-centric workflow** - Extensive git aliases and utilities for branch/commit management
- **Package manager detection** - Automatically detects and uses appropriate package manager
- **Runtime environment setup** - Node.js via NVM on macOS, NodeSource on Linux, Python 3 across platforms

## Development Notes

- No build process - pure shell scripts and configuration files
- Changes tested by running setup scripts in isolated environments
- Git configuration applied globally via `git config --global`
- Shell functions sourced automatically through zsh configuration