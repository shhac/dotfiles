#!/bin/bash
# Cygwin configuration setup
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Error handling function
error_exit() {
    echo "Error: $1" >&2
    exit 1
}

echo "🖥️ Setting up Cygwin configuration..."

# Copy mintty configuration
if [ -f "$SCRIPT_DIR/.minttyrc" ]; then
    cp "$SCRIPT_DIR/.minttyrc" ~/.minttyrc
    echo "✅ Mintty configuration installed"
else
    error_exit "Mintty configuration file not found"
fi

echo "✅ Cygwin configuration complete!"