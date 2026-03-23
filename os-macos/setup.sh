#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
INTERACTIVE="${INTERACTIVE:-true}"

source "$DOTFILES_DIR/lib/utils.sh"

# ─── Phase 1: Foundation ───────────────────────────────────────────────────────

info "Phase 1: Foundation"

# Xcode Command Line Tools
if ! xcode-select -p &>/dev/null; then
  info "Installing Xcode Command Line Tools..."
  xcode-select --install
  echo "Press any key when the installation has completed."
  read -n 1 -s
fi
success "Xcode CLT ready"

# Homebrew
if ! command -v brew &>/dev/null; then
  info "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is on PATH for this session
if [ -f /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -f /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi
success "Homebrew ready"

# ─── Phase 2: Packages ────────────────────────────────────────────────────────

info "Phase 2: Packages"

if [ -f "$DOTFILES_DIR/Brewfile" ]; then
  brew bundle install --file="$DOTFILES_DIR/Brewfile" || warning "Some brew packages failed (continuing)"
  success "Brew packages installed"
else
  warning "No Brewfile found, skipping package installation"
fi

# ─── Phase 3: Frameworks ──────────────────────────────────────────────────────

info "Phase 3: Frameworks"

# Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  info "Installing Oh My Zsh..."
  CHSH=no RUNZSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  success "Oh My Zsh installed"
else
  success "Oh My Zsh already installed"
fi

# git-open plugin for Oh My Zsh
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.zsh}"
if [ ! -d "$ZSH_CUSTOM/plugins/git-open" ]; then
  info "Installing git-open plugin..."
  git clone https://github.com/paulirish/git-open.git "$ZSH_CUSTOM/plugins/git-open"
  success "git-open plugin installed"
fi

# NVM
if [ ! -d "$HOME/.nvm" ]; then
  info "Installing NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  success "NVM + Node.js LTS installed"
else
  success "NVM already installed"
fi

# TPM (Tmux Plugin Manager)
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
  info "Installing Tmux Plugin Manager..."
  git clone https://github.com/tmux-plugins/tpm "$HOME/.tmux/plugins/tpm"
  success "TPM installed"
else
  success "TPM already installed"
fi

# ─── Phase 4: Configuration (Stow) ────────────────────────────────────────────

info "Phase 4: Stow configuration"

# Ensure stow is available
if ! command -v stow &>/dev/null; then
  error_exit "GNU Stow is required but not installed. Run: brew install stow"
fi

# Backup conflicting files before stowing
backup_if_needed() {
  local target="$1"
  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    local rel_path="${target#$HOME/}"
    local backup_path="$BACKUP_DIR/$rel_path"
    mkdir -p "$(dirname "$backup_path")"
    mv "$target" "$backup_path"
    info "Backed up: $target → $backup_path"
  fi
}

# Directories that need to exist with correct permissions before stowing
mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"
mkdir -p "$HOME/.config"
mkdir -p "$HOME/.zsh"

# Collect stow packages (exclude os-*, .git, lib, and non-package files)
stow_packages=()
for dir in "$DOTFILES_DIR"/*/; do
  pkg="$(basename "$dir")"
  case "$pkg" in
    os-*|lib|.git|.github|.claude|.ai-cache) continue ;;
    *) stow_packages+=("$pkg") ;;
  esac
done

# Add OS-only packages (dirs in os-macos/ that have no common counterpart)
for dir in "$DOTFILES_DIR"/os-macos/*/; do
  [ -d "$dir" ] || continue
  pkg="$(basename "$dir")"
  # Skip non-stow dirs (iterm2-profiles, etc.)
  [[ "$pkg" == iterm2-profiles ]] && continue
  # Only add if not already in the list
  if [ ! -d "$DOTFILES_DIR/$pkg" ]; then
    stow_packages+=("$pkg")
  fi
done

# For each package, check for files that would conflict and back them up
for pkg in "${stow_packages[@]}"; do
  pkg_dir="$DOTFILES_DIR/$pkg"

  # Check for OS-specific override
  if [ -d "$DOTFILES_DIR/os-macos/$pkg" ]; then
    info "Using os-macos override for $pkg"
    pkg_dir="$DOTFILES_DIR/os-macos/$pkg"
  fi

  # Find all files in the package and check for conflicts
  while IFS= read -r -d '' file; do
    rel="${file#$pkg_dir/}"
    target="$HOME/$rel"
    backup_if_needed "$target"
  done < <(find "$pkg_dir" -type f -print0)
done

# Stow each package
for pkg in "${stow_packages[@]}"; do
  if [ -d "$DOTFILES_DIR/os-macos/$pkg" ]; then
    stow --no-folding -d "$DOTFILES_DIR/os-macos" -t "$HOME" "$pkg" || warning "Stow failed for os-macos/$pkg"
  else
    stow --no-folding -d "$DOTFILES_DIR" -t "$HOME" "$pkg" || warning "Stow failed for $pkg"
  fi
  success "Stowed: $pkg"
done

# ─── Phase 5: Machine-specific config ─────────────────────────────────────────

info "Phase 5: Machine-specific configuration"

# Helper: if a backup exists for a file that now has a .local counterpart,
# compare the backup against the stowed version. If they differ, promote
# the backup as the .local file. If identical, skip (no .local needed).
# For configs where the stowed version is structurally different (gitconfig,
# ssh), always promote since the backup IS the machine-specific content.
promote_backup_to_local() {
  local local_file="$1"
  local backup_file="$2"
  local stowed_file="${3:-}"

  if [ -f "$local_file" ]; then
    return 0
  fi

  if [ ! -f "$backup_file" ]; then
    return 1
  fi

  # If a stowed file was provided, diff against it — skip if identical
  if [ -n "$stowed_file" ] && [ -f "$stowed_file" ]; then
    if diff -q "$backup_file" "$stowed_file" &>/dev/null; then
      info "$(basename "$backup_file") matches stowed version, no .local needed"
      return 0
    fi
  fi

  cp "$backup_file" "$local_file"
  success "Migrated $(basename "$backup_file") → $(basename "$local_file")"
  return 0
}

# .gitconfig.local — try backup first, then prompt
if ! promote_backup_to_local "$HOME/.gitconfig.local" "$BACKUP_DIR/.gitconfig"; then
  if [ "$INTERACTIVE" = "true" ]; then
    info "Setting up git user identity..."
    echo -n "Git name: " && read -r git_name
    echo -n "Git email: " && read -r git_email
    echo -n "GPG signing key (leave blank to skip): " && read -r git_signingkey

    cat > "$HOME/.gitconfig.local" << GITLOCAL
[user]
	name = $git_name
	email = $git_email
GITLOCAL

    if [ -n "$git_signingkey" ]; then
      cat >> "$HOME/.gitconfig.local" << GITLOCAL
	signingkey = $git_signingkey
GITLOCAL
    fi

    success "Created ~/.gitconfig.local"
  else
    warning "Skipping .gitconfig.local (non-interactive mode). Create it manually."
  fi
fi

# .ssh/config.local — try backup first, then template
if ! promote_backup_to_local "$HOME/.ssh/config.local" "$BACKUP_DIR/.ssh/config"; then
  cat > "$HOME/.ssh/config.local" << 'SSHLOCAL'
# Machine-specific SSH hosts
# Add your hosts here, e.g.:
#
# Host github.com
#   AddKeysToAgent yes
#   UseKeychain yes
#   IdentityFile ~/.ssh/id_ed25519
SSHLOCAL
  chmod 644 "$HOME/.ssh/config.local"
  success "Created ~/.ssh/config.local (template)"
fi

# .zshrc.local — try backup first, compare with stowed version
if ! promote_backup_to_local "$HOME/.zshrc.local" "$BACKUP_DIR/.zshrc" "$DOTFILES_DIR/shell/.zshrc"; then
  cat > "$HOME/.zshrc.local" << 'ZSHLOCAL'
# Machine-specific shell configuration
# This file is sourced at the end of ~/.zshrc

# Example: Add machine-specific PATH entries
# export PATH="/opt/homebrew/opt/protobuf@3/bin:$PATH"

# Example: Source additional tools
# . "$HOME/.local/bin/env"
ZSHLOCAL
  success "Created ~/.zshrc.local (template)"
fi

# .zprofile.local — compare with stowed version
promote_backup_to_local "$HOME/.zprofile.local" "$BACKUP_DIR/.zprofile" "$DOTFILES_DIR/shell/.zprofile" || true

# .tmux.conf.local — compare with stowed version
promote_backup_to_local "$HOME/.tmux.conf.local" "$BACKUP_DIR/.tmux.conf" "$DOTFILES_DIR/tmux/.tmux.conf" || true

# .vimrc.local — compare with stowed version
promote_backup_to_local "$HOME/.vimrc.local" "$BACKUP_DIR/.vimrc" "$DOTFILES_DIR/vim/.vimrc" || true

# nvim init.local.vim — compare with stowed version
promote_backup_to_local "$HOME/.config/nvim/init.local.vim" "$BACKUP_DIR/.config/nvim/init.vim" "$DOTFILES_DIR/nvim/.config/nvim/init.vim" || true

# ─── Phase 6: System Preferences (opt-in) ─────────────────────────────────────

if [ "$INTERACTIVE" = "true" ]; then
  if prompt_yes_no "Apply macOS system preferences (Finder, keyboard, screenshots, etc.)?"; then
    info "Applying macOS defaults..."
    source "$DOTFILES_DIR/os-macos/defaults.sh"
    killall Dock Finder SystemUIServer 2>/dev/null || true
    success "macOS defaults applied"
  fi
else
  info "Skipping macOS defaults (use './setup.sh macos' to apply later)"
fi

# ─── Phase 7: Post-install ────────────────────────────────────────────────────

info "Phase 7: Post-install"

# Change default shell to brew's zsh
BREW_ZSH="$(brew --prefix)/bin/zsh"
if [ -x "$BREW_ZSH" ]; then
  if ! grep -q "$BREW_ZSH" /etc/shells 2>/dev/null; then
    info "Adding $BREW_ZSH to /etc/shells..."
    echo "$BREW_ZSH" | sudo tee -a /etc/shells >/dev/null
  fi
  if [ "$SHELL" != "$BREW_ZSH" ]; then
    chsh -s "$BREW_ZSH"
    success "Default shell changed to $BREW_ZSH"
  fi
fi

# Install tmux plugins
if [ -f "$HOME/.tmux/plugins/tpm/bin/install_plugins" ]; then
  "$HOME/.tmux/plugins/tpm/bin/install_plugins" || true
  success "Tmux plugins installed"
fi

# Install Claude Code skills (bun is available via Homebrew; npx requires nvm which isn't sourced yet)
if command -v bunx &>/dev/null; then
  info "Installing Claude Code skills..."
  bunx skills add shhac/git-hunk -g -a claude-code -y || warning "Failed to install git-hunk skill"
  bunx skills add shhac/lin -g -a claude-code -y || warning "Failed to install lin skill"
  bunx skills add shhac/agent-mongo -g -a claude-code -y || warning "Failed to install agent-mongo skill"
  bunx skills add shhac/agent-notion -g -a claude-code -y || warning "Failed to install agent-notion skill"
  success "Claude Code skills installed"
else
  warning "bunx not found — skipping Claude Code skill installation"
fi

# ─── Done ──────────────────────────────────────────────────────────────────────

echo ""
success "=== Setup complete! ==="
echo ""
info "Next steps (manual):"
echo "  - Import GPG secret keys: gpg --import /path/to/private-key.asc"
echo "  - Copy SSH keys to ~/.ssh/ and chmod 600 ~/.ssh/id_*"
echo "  - Sign into Mac App Store (for mas packages in Brewfile)"
echo "  - Install dev tools (auto-update, not in Brewfile):"
echo "      Cursor:      https://cursor.com/downloads"
echo "      Claude Code:  curl -fsSL https://claude.ai/install.sh | bash"
echo "  - Authenticate services:"
echo "      gh auth login"
echo "      npm login"
echo "      gt auth"
echo "      claude login"
echo "  - Edit machine-specific overrides:"
echo "      ~/.zshrc.local      (PATH, env vars)"
echo "      ~/.gitconfig.local  (user identity)"
echo "      ~/.ssh/config.local (SSH hosts)"
echo "  - Review macOS defaults: ./setup.sh macos"
echo ""
info "Restart your terminal to pick up all changes."
