#!/bin/bash
# Common utilities for dotfiles setup scripts

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Error handling function
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Success message function
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Warning message function
warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

# Info message function
info() {
    echo -e "${BLUE}ℹ️ $1${NC}"
}

# Interactive prompt function
prompt_yes_no() {
    local question="$1"
    local default="${2:-y}"
    
    if [[ "$INTERACTIVE" == "false" ]]; then
        info "Auto-answering yes to: $question"
        return 0
    fi
    
    local prompt
    if [[ "$default" == "y" ]]; then
        prompt="$question [Y/n]: "
    else
        prompt="$question [y/N]: "
    fi
    
    while true; do
        read -p "$prompt" response
        case "$response" in
            [Yy]|[Yy][Ee][Ss]|"")
                [[ "$default" == "y" ]] && return 0
                [[ "$response" != "" ]] && return 0
                ;;
            [Nn]|[Nn][Oo])
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

# Multi-choice prompt function
prompt_choice() {
    local question="$1"
    shift
    local choices=("$@")
    local default=1
    
    if [[ "$INTERACTIVE" == "false" ]]; then
        info "Auto-selecting option 1 for: $question"
        echo "${choices[0]}"
        return 0
    fi
    
    echo "$question"
    for i in "${!choices[@]}"; do
        echo "  $((i+1)). ${choices[i]}"
    done
    
    while true; do
        read -p "Select option [1-${#choices[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ "$choice" -ge 1 ]] && [[ "$choice" -le "${#choices[@]}" ]]; then
            echo "${choices[$((choice-1))]}"
            return $((choice-1))
        else
            echo "Please enter a valid option (1-${#choices[@]})"
        fi
    done
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if running as root
is_root() {
    [[ $EUID -eq 0 ]]
}

# Get script directory (useful for relative paths)
get_script_dir() {
    cd "$(dirname "${BASH_SOURCE[1]}")" && pwd
}

# Export functions for use in sourced scripts
export -f error_exit success warning info prompt_yes_no prompt_choice command_exists is_root get_script_dir