#!/bin/bash
# Git configuration setup
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Error handling function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

echo "🔧 Setting up git configuration..."

# Check if git is installed
if ! command -v git >/dev/null 2>&1; then
    error_exit "Git is not installed. Please install git first."
fi

# Run git configuration scripts locally
echo "⚙️ Configuring git aliases..."
if [ -f "$SCRIPT_DIR/aliases.sh" ]; then
    source "$SCRIPT_DIR/aliases.sh" || error_exit "Failed to configure git aliases"
else
    error_exit "Git aliases script not found"
fi

echo "🔄 Configuring git push/pull settings..."
if [ -f "$SCRIPT_DIR/push-pull.sh" ]; then
    source "$SCRIPT_DIR/push-pull.sh" || error_exit "Failed to configure git push/pull settings"
else
    error_exit "Git push-pull script not found"
fi

echo "👤 Configuring git user settings..."
if [ -f "$SCRIPT_DIR/user.sh" ]; then
    source "$SCRIPT_DIR/user.sh" || error_exit "Failed to configure git user settings"
else
    error_exit "Git user script not found"
fi

echo "🎨 Configuring git diff settings..."
if [ -f "$SCRIPT_DIR/diff.sh" ]; then
    source "$SCRIPT_DIR/diff.sh" || error_exit "Failed to configure git diff settings"
else
    error_exit "Git diff script not found"
fi

echo "✅ Git configuration complete!"

# Show current git configuration
echo ""
echo "📋 Current git configuration:"
echo "User: $(git config --global user.name) <$(git config --global user.email)>"
echo "Default branch: $(git config --global init.defaultBranch)"
echo "Push default: $(git config --global push.default)"