# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a personal dotfiles repository containing shell configurations, git aliases, and system setup scripts for Mac development environments. The repository is organized into platform-specific directories with setup scripts that configure development tools and shell environments.

## Key Components

### Git Configuration (`git/`)
- **Git aliases** - Extensive set of git aliases configured via `git/aliases.sh`
- **Custom commit function** - `gm` function for conventional commits with format `type[scope]: message`
- **Branch utilities** - Functions for ticket extraction from branch names

### Shell Configuration (`shell/`)
- **Zsh extensions** - Custom functions and aliases in `shell/conf.d/`
- **Theme** - Custom zsh theme at `shell/themes/ataganoster.zsh-theme`
- **Utility functions** - Helper functions in `shell/conf.d/fns.sh`

### Mac Setup (`mac/`)
- **System configuration** - OSX settings and Homebrew package installation
- **Development tools** - Node.js, Python, Visual Studio Code setup
- **iTerm2 profiles** - Terminal configuration

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

## Architecture Notes

- **Modular design** - Each platform/tool has its own directory with setup scripts
- **Interactive prompts** - All scripts support user-friendly prompts with graceful skipping
- **Shared utilities** - Common functions in `lib/utils.sh` for consistent experience
- **Local installation** - Setup scripts use local configuration files for reliable, offline-capable setup
- **Shell integration** - All custom functions/aliases loaded via `shell/conf.d/` directory
- **Git-centric workflow** - Extensive git aliases and utilities for branch/commit management

## Development Notes

- No build process - pure shell scripts and configuration files
- Changes tested by running setup scripts in isolated environments
- Git configuration applied globally via `git config --global`
- Shell functions sourced automatically through zsh configuration