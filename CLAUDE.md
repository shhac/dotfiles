# CLAUDE.md

This file provides guidance to Claude Code when working with this repository.

## Project Overview

Personal dotfiles repository managed with **GNU Stow**. Each top-level directory is a stow package that mirrors `$HOME` — stow creates symlinks from the package contents into the home directory. Supports macOS, Linux, and WSL2.

## Repository Structure

```
dotfiles/
├── setup.sh              # Entry point: detects OS, delegates to os-*/setup.sh
├── Brewfile              # Declarative Homebrew packages, casks, and apps
├── .gitignore            # Ignores secrets, .local files, OS artifacts
├── .stow-local-ignore    # Prevents stow from linking repo management files
│
├── # Stow packages (each mirrors $HOME)
├── shell/                # .zshrc, .zprofile, .zsh/conf.d/*, .zsh/themes/*
├── git/                  # .gitconfig, .gitignore_global
├── vim/                  # .vimrc
├── nvim/                 # .config/nvim/init.vim
├── ghostty/              # .config/ghostty/config
├── cmux/                 # .config/cmux/settings.json
├── tmux/                 # .tmux.conf
├── ssh/                  # .ssh/config (includes .ssh/config.local)
├── gpg/                  # .gnupg/gpg-agent.conf
│
├── # OS-specific (NOT stow packages)
├── os-macos/             # setup.sh, defaults.sh, iterm2-profiles/
├── os-linux/             # setup.sh
├── os-wsl2/              # setup.sh, wsl-interop.sh, wsl2-aliases.sh, x11-setup.sh
│
└── lib/                  # Shared utilities (utils.sh)
```

## Key Patterns

### Stow Symlinks
- `stow --no-folding -t $HOME <package>` creates file-level symlinks (never directory-level)
- Changes to symlinked files are changes to the repo — no copy/sync step needed
- OS-specific overrides: if `os-macos/<package>/` exists, it's stowed instead of the common package

### .local File Pattern
All tracked configs source/include a gitignored `.local` counterpart for machine-specific overrides:
- `.zshrc` → sources `~/.zshrc.local`
- `.gitconfig` → `[include] path = ~/.gitconfig.local`
- `.ssh/config` → `Include ~/.ssh/config.local`

### Shell Configuration
- **Oh My Zsh** with `ZSH_CUSTOM=~/.zsh` (stow links `shell/.zsh/` → `~/.zsh/`)
- **conf.d pattern**: All shell extensions in `shell/.zsh/conf.d/*.sh`, auto-sourced by `.zshrc`
- **Themes** in `shell/.zsh/themes/`, default: `shhac-starship-rounded-bubble`
- **Plugins**: `git`, `git-open`

### Git Configuration
- All aliases defined directly in `git/.gitconfig` (not via `git config --global` commands)
- User identity, signing key, and `[includeIf]` blocks go in `~/.gitconfig.local`
- `gm` function in `shell/.zsh/conf.d/git.sh` for conventional commits: `gm feat api "message"`

## Setup Flow (macOS)

`setup.sh` → `os-macos/setup.sh`:
1. Xcode CLT + Homebrew
2. `brew bundle install` from Brewfile
3. Oh My Zsh, NVM, TPM (tmux plugin manager)
4. Stow all packages (with backup of conflicting files)
5. Create machine-specific `.local` files interactively
6. Optional macOS defaults
7. Set default shell to brew's zsh

## Useful Commands

```bash
# Setup
./setup.sh              # Full setup
./setup.sh --yes        # Non-interactive

# Manual stow operations
stow --no-folding -t $HOME shell    # Stow a single package
stow -D -t $HOME shell              # Unstow a package

# Update Brewfile
brew bundle dump --force --describe --file=Brewfile
```

## Development Notes

- No build process — pure shell scripts and config files
- `lib/utils.sh` provides `success()`, `info()`, `warning()`, `error_exit()`, `prompt_yes_no()`
- All setup scripts are idempotent (safe to re-run)
- Secrets are never tracked — `.gitignore` covers keys, tokens, and `.local` files
