# AGENTS.md

This file provides guidance to LLMs when working with this repository.

## Project Overview

Personal dotfiles repository managed with **GNU Stow**. Packages are listed in `stow-packages.txt` and mirror `$HOME` — stow creates symlinks from the package contents into the home directory. Supports macOS, Linux, and WSL2.

## Repository Structure

```
dotfiles/
├── setup.sh              # Entry point: detects OS, delegates to os-*/setup.sh
├── Brewfile              # Declarative Homebrew packages, casks, and apps
├── stow-packages.txt     # Explicit package manifest
├── .gitignore            # Ignores secrets, .local files, OS artifacts
├── .stow-local-ignore    # Prevents stow from linking repo management files
├── .captureignore        # Known-untracked configs `--capture` should not report
│
├── # Stow packages (each mirrors $HOME)
├── shell/                # .zshrc.shared, .zprofile, .zsh/conf.d/*, .zsh/themes/*
├── git/                  # .gitconfig, .gitignore_global
├── vim/                  # .vimrc
├── nvim/                 # .config/nvim/init.vim
├── ghostty/              # .config/ghostty/config
├── cmux/                 # .config/cmux/cmux.json
├── codex/                # .codex/pets/* (custom pets only)
├── graphite/             # .config/graphite/aliases
├── agents/               # .agents/.skill-lock.json
├── linux/                # .zsh/conf.d/linux.sh (Linux/WSL2 only)
├── wsl2/                 # .zsh/conf.d/wsl2.sh (WSL2 only)
├── tmux/                 # .tmux.conf
├── ssh/                  # .ssh/config (includes .ssh/config.local)
├── gpg/                  # .gnupg/gpg-agent.conf
│
├── # OS-specific (NOT stow packages)
├── os-macos/             # setup.sh, defaults.sh, iterm2-profiles/
├── os-linux/             # setup.sh
├── os-wsl2/              # setup.sh, wsl-interop.sh, wsl2-aliases.sh, x11-setup.sh
│
├── lib/                  # Shared utilities (utils.sh, stow.sh, doctor.sh, capture.sh)
├── scripts/              # Helper scripts used by setup
└── templates/            # Bootstrap templates copied into local files
```

## Key Patterns

### Stow Symlinks
- `stow --no-folding -t $HOME <package>` creates file-level symlinks (never directory-level)
- Changes to symlinked files are changes to the repo — no copy/sync step needed
- OS-specific overrides: if `os-macos/<package>/` exists, it's stowed instead of the common package
- Use `./setup.sh --stow-only [package]` for normal stow operations; it reads `stow-packages.txt` and uses shared backup logic from `lib/stow.sh`

### Drift Capture
- **When starting a session in this repo, run `./setup.sh --capture`** and act on what it reports — it's a read-only drift report (uncommitted tracked-file changes, Brewfile vs installed packages in both directions, new unmanaged configs, doctor)
- Acting on findings: commit tracked-file drift with `git hunk`; add missing Brewfile entries by hand into the right curated section (**never** `brew bundle dump --force` — it flattens the curation); for new unmanaged configs, either track as a stow package or add to `.captureignore`
- If a tracked file gained machine-specific content (absolute `/opt/homebrew` paths, credential blocks — usually a tool like `gh auth setup-git` wrote it), move it to the `.local` override instead of committing
- If you `brew install` something during a session, add it to the Brewfile

### .local File Pattern
All tracked configs source/include a gitignored `.local` counterpart for machine-specific overrides:
- `.zshrc.shared` → sourced by local `~/.zshrc` bootstrap, then sources `~/.zshrc.local`
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

### Codex Configuration
- Track only portable custom pets in `codex/.codex/pets/`
- Do not track the rest of `~/.codex`; it contains auth state, caches, sessions, logs, local runtime paths, and trusted workspace settings
- The selected pet in `~/.codex/config.toml` is local app state; reselect it in Codex after setting up a new machine

### Agent Skills
- Track `npx skills` global lock metadata in `agents/.agents/.skill-lock.json`
- Do not vendor installed skill directories; personal skill source lives in the sibling `../skills` repo
- Setup reinstalls global skills via `scripts/install-skills-from-lock.sh`

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
./setup.sh --stow-only  # Stow all packages for this OS
./setup.sh --doctor     # Check stow, symlinks, secrets, and permissions
./setup.sh --capture    # Report drift: machine changes the repo hasn't captured

# Manual stow operations
./setup.sh --stow-only shell        # Stow a single package
stow -D -t $HOME shell              # Unstow a package

# Brewfile drift shows up in --capture; add entries by hand (sections are curated)
```

## Development Notes

- No build process — pure shell scripts and config files
- `lib/utils.sh` provides `success()`, `info()`, `warning()`, `error_exit()`, `prompt_yes_no()`
- `lib/stow.sh` owns package manifest parsing, conflict backups, and stow application
- `lib/doctor.sh` owns `./setup.sh --doctor`
- `lib/capture.sh` owns `./setup.sh --capture` (read-only drift report; `.captureignore` silences known-untracked configs)
- All setup scripts are idempotent (safe to re-run)
- Secrets are never tracked — `.gitignore` covers keys, tokens, and `.local` files
