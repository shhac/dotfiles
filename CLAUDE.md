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
# Mac setup (installs Homebrew, git, shell config, development tools)
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/mac/setup.sh)"

# Individual components
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/shell/setup.sh)"
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/git/setup.sh)"
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
- **Remote installation** - Setup scripts download configuration from raw GitHub URLs
- **Shell integration** - All custom functions/aliases loaded via `~/.zsh/conf.d/`
- **Git-centric workflow** - Extensive git aliases and utilities for branch/commit management

## Development Notes

- No build process - pure shell scripts and configuration files
- Changes tested by running setup scripts in isolated environments
- Git configuration applied globally via `git config --global`
- Shell functions sourced automatically through zsh configuration