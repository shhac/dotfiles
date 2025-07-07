#!/bin/bash
# Git configuration setup
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Load common utilities if available
if [ -f "$SCRIPT_DIR/../lib/utils.sh" ]; then
    source "$SCRIPT_DIR/../lib/utils.sh"
else
    # Fallback functions if utils not available
    error_exit() { echo "Error: $1" >&2; exit 1; }
    success() { echo "✅ $1"; }
    info() { echo "ℹ️ $1"; }
    warning() { echo "⚠️ $1"; }
    prompt_yes_no() { 
        [[ "${INTERACTIVE:-true}" == "false" ]] && return 0
        read -p "$1 [Y/n]: " response
        [[ "$response" =~ ^[Nn] ]] && return 1 || return 0
    }
fi

echo "🔧 Setting up git configuration..."

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    error_exit "Git is not installed. Please install git first."
fi

# Configure git components interactively
if prompt_yes_no "Configure git aliases? (shortcuts for common commands)"; then
    echo "⚙️ Configuring git aliases..."
    if [ -f "$SCRIPT_DIR/aliases.sh" ]; then
        source "$SCRIPT_DIR/aliases.sh" || error_exit "Failed to configure git aliases"
        success "Git aliases configured"
    else
        error_exit "Git aliases script not found"
    fi
else
    info "Skipping git aliases"
fi

if prompt_yes_no "Configure git push/pull settings? (safe defaults for workflow)"; then
    echo "🔄 Configuring git push/pull settings..."
    if [ -f "$SCRIPT_DIR/push-pull.sh" ]; then
        source "$SCRIPT_DIR/push-pull.sh" || error_exit "Failed to configure git push/pull settings"
        success "Git push/pull settings configured"
    else
        error_exit "Git push-pull script not found"
    fi
else
    info "Skipping git push/pull settings"
fi

if prompt_yes_no "Configure git user settings? (name, email, signing key)"; then
    echo "👤 Configuring git user settings..."
    if [ -f "$SCRIPT_DIR/user.sh" ]; then
        source "$SCRIPT_DIR/user.sh" || error_exit "Failed to configure git user settings"
        success "Git user settings configured"
    else
        error_exit "Git user script not found"
    fi
else
    info "Skipping git user settings"
fi

if prompt_yes_no "Configure git diff settings? (better diff tools and formatting)"; then
    echo "🎨 Configuring git diff settings..."
    if [ -f "$SCRIPT_DIR/diff.sh" ]; then
        source "$SCRIPT_DIR/diff.sh" || error_exit "Failed to configure git diff settings"
        success "Git diff settings configured"
    else
        error_exit "Git diff script not found"
    fi
else
    info "Skipping git diff settings"
fi

success "Git configuration complete!"

# Show current git configuration
echo ""
info "Current git configuration:"
echo "User: $(git config --global user.name) <$(git config --global user.email)>"
echo "Default branch: $(git config --global init.defaultBranch)"
echo "Push default: $(git config --global push.default)"