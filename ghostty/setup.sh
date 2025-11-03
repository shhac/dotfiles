#!/bin/bash
# Ghostty terminal configuration setup
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

echo "👻 Setting up Ghostty terminal configuration..."

# Create Ghostty config directory if it doesn't exist
GHOSTTY_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/ghostty"
if [ ! -d "$GHOSTTY_CONFIG_DIR" ]; then
    mkdir -p "$GHOSTTY_CONFIG_DIR"
    info "Created Ghostty config directory: $GHOSTTY_CONFIG_DIR"
fi

# Copy Ghostty configuration
if [ -f "$SCRIPT_DIR/config" ]; then
    cp "$SCRIPT_DIR/config" "$GHOSTTY_CONFIG_DIR/config"
    success "Ghostty configuration installed to $GHOSTTY_CONFIG_DIR/config"
else
    error_exit "Ghostty configuration file (config) not found"
fi

# Check if Ghostty is installed
if command -v ghostty >/dev/null 2>&1; then
    success "Ghostty is installed and configured"
else
    warning "Ghostty is not installed. Install it from: https://ghostty.org"
    info "On macOS: brew install ghostty"
fi
