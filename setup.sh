#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# Parse arguments
export INTERACTIVE="true"

for arg in "$@"; do
  case "$arg" in
    -y|--yes|--non-interactive) INTERACTIVE="false" ;;
    -h|--help)
      echo "Usage: ./setup.sh [options]"
      echo ""
      echo "Options:"
      echo "  -y, --yes    Non-interactive mode (auto-yes to all prompts)"
      echo "  -h, --help   Show this help message"
      echo ""
      echo "Detects your OS and runs the appropriate setup."
      exit 0
      ;;
    *) echo "Unknown argument: $arg"; exit 1 ;;
  esac
done

export INTERACTIVE

# Source shared utilities
source "$DOTFILES_DIR/lib/utils.sh"

# Detect OS and delegate
case "$(uname -s)" in
  Darwin)
    source "$DOTFILES_DIR/os-macos/setup.sh"
    ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      source "$DOTFILES_DIR/os-wsl2/setup.sh"
    else
      source "$DOTFILES_DIR/os-linux/setup.sh"
    fi
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac
