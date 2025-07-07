#!/bin/bash
# Vim configuration setup

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy vim configuration
cp "$SCRIPT_DIR/.vimrc" ~/.vimrc

echo "✅ Vim configuration installed"

