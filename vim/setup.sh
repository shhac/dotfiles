#!/bin/bash
# Vim configuration setup
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

echo "📝 Setting up vim configuration..."

# Copy vim configuration
if [ -f "$SCRIPT_DIR/.vimrc" ]; then
    cp "$SCRIPT_DIR/.vimrc" ~/.vimrc
    success "Vim configuration installed"
else
    error_exit "Vim configuration file (.vimrc) not found"
fi

