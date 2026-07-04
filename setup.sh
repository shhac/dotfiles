#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export DOTFILES_DIR

# Parse arguments
export INTERACTIVE="true"
DOTFILES_MODE="full"
STOW_ONLY_PACKAGES=()

while [ "$#" -gt 0 ]; do
  case "$1" in
    -y|--yes|--non-interactive)
      INTERACTIVE="false"
      shift
      ;;
    --doctor)
      DOTFILES_MODE="doctor"
      shift
      ;;
    --capture)
      DOTFILES_MODE="capture"
      shift
      ;;
    --stow-only)
      DOTFILES_MODE="stow-only"
      shift
      while [ "$#" -gt 0 ] && [[ "$1" != -* ]]; do
        STOW_ONLY_PACKAGES+=("$1")
        shift
      done
      ;;
    -h|--help)
      echo "Usage: ./setup.sh [options]"
      echo ""
      echo "Options:"
      echo "  -y, --yes       Non-interactive mode (auto-yes to all prompts)"
      echo "  --stow-only     Only stow configuration packages (optionally name packages)"
      echo "  --doctor        Run repository and machine health checks"
      echo "  --capture       Report drift: machine changes the repo hasn't captured"
      echo "  -h, --help      Show this help message"
      echo ""
      echo "Detects your OS and runs the appropriate setup."
      exit 0
      ;;
    *) echo "Unknown argument: $1"; exit 1 ;;
  esac
done

export INTERACTIVE
export DOTFILES_MODE

# Source shared utilities
source "$DOTFILES_DIR/lib/utils.sh"
source "$DOTFILES_DIR/lib/stow.sh"
source "$DOTFILES_DIR/lib/doctor.sh"
source "$DOTFILES_DIR/lib/capture.sh"

# Detect OS and delegate
case "$(uname -s)" in
  Darwin)
    export DOTFILES_OS="macos"
    ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then
      export DOTFILES_OS="wsl2"
    else
      export DOTFILES_OS="linux"
    fi
    ;;
  *)
    echo "Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

case "$DOTFILES_MODE" in
  doctor)
    dotfiles_doctor "$DOTFILES_OS"
    exit $?
    ;;
  capture)
    dotfiles_capture "$DOTFILES_OS"
    exit $?
    ;;
  stow-only)
    dotfiles_stow_packages "$DOTFILES_OS" "${STOW_ONLY_PACKAGES[@]}"
    exit $?
    ;;
esac

case "$DOTFILES_OS" in
  macos) source "$DOTFILES_DIR/os-macos/setup.sh" ;;
  linux) source "$DOTFILES_DIR/os-linux/setup.sh" ;;
  wsl2) source "$DOTFILES_DIR/os-wsl2/setup.sh" ;;
esac
