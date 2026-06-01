#!/usr/bin/env bash

# Shared GNU Stow helpers. Scripts sourcing this file must set DOTFILES_DIR.

STOW_PACKAGES_FILE="${DOTFILES_DIR}/stow-packages.txt"
DOTFILES_OS="${DOTFILES_OS:-}"
BACKUP_DIR="${BACKUP_DIR:-$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)}"

dotfiles_normalize_os() {
  case "$1" in
    Darwin|macos) echo "macos" ;;
    Linux|linux) echo "linux" ;;
    wsl2) echo "wsl2" ;;
    *) echo "$1" ;;
  esac
}

dotfiles_detect_os() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux)
      if grep -qi microsoft /proc/version 2>/dev/null; then
        echo "wsl2"
      else
        echo "linux"
      fi
      ;;
    *) echo "unsupported" ;;
  esac
}

dotfiles_scope_matches() {
  local scope="$1"
  local os="$2"

  if [ -z "$scope" ]; then
    return 0
  fi

  case ",$scope," in
    *,"$os",*) return 0 ;;
    *) return 1 ;;
  esac
}

dotfiles_manifest_packages() {
  local os="${1:-${DOTFILES_OS:-$(dotfiles_detect_os)}}"
  local line pkg scope

  if [ ! -f "$STOW_PACKAGES_FILE" ]; then
    error_exit "Missing stow package manifest: $STOW_PACKAGES_FILE"
  fi

  while IFS= read -r line; do
    line="${line%%#*}"
    # shellcheck disable=SC2086
    set -- $line
    pkg="${1:-}"
    scope="${2:-}"

    [ -n "$pkg" ] || continue
    if dotfiles_scope_matches "$scope" "$os"; then
      printf '%s\n' "$pkg"
    fi
  done < "$STOW_PACKAGES_FILE"
}

dotfiles_package_dir() {
  local os="$1"
  local pkg="$2"

  if [ -d "$DOTFILES_DIR/os-$os/$pkg" ]; then
    printf '%s\n' "$DOTFILES_DIR/os-$os/$pkg"
  elif [ -d "$DOTFILES_DIR/$pkg" ]; then
    printf '%s\n' "$DOTFILES_DIR/$pkg"
  else
    return 1
  fi
}

dotfiles_package_stow_dir() {
  local os="$1"
  local pkg="$2"

  if [ -d "$DOTFILES_DIR/os-$os/$pkg" ]; then
    printf '%s\n' "$DOTFILES_DIR/os-$os"
  else
    printf '%s\n' "$DOTFILES_DIR"
  fi
}

dotfiles_abs_path() {
  local path="$1"
  local dir base

  dir="$(cd "$(dirname "$path")" && pwd -P)" || return 1
  base="$(basename "$path")"
  printf '%s/%s\n' "$dir" "$base"
}

dotfiles_symlink_points_to() {
  local target="$1"
  local expected="$2"
  local link actual expected_abs

  [ -L "$target" ] || return 1

  link="$(readlink "$target")"
  case "$link" in
    /*) actual="$link" ;;
    *)
      actual="$(cd "$(dirname "$target")" && cd "$(dirname "$link")" && pwd -P)/$(basename "$link")" || return 1
      ;;
  esac

  expected_abs="$(dotfiles_abs_path "$expected")" || return 1
  [ "$actual" = "$expected_abs" ]
}

dotfiles_backup_if_needed() {
  local target="$1"
  local source="$2"
  local rel_path backup_path

  if [ -L "$target" ]; then
    if dotfiles_symlink_points_to "$target" "$source"; then
      return 0
    fi
    rel_path="${target#$HOME/}"
    backup_path="$BACKUP_DIR/$rel_path"
    mkdir -p "$(dirname "$backup_path")"
    mv "$target" "$backup_path"
    info "Backed up symlink: $target -> $backup_path"
  elif [ -e "$target" ]; then
    rel_path="${target#$HOME/}"
    backup_path="$BACKUP_DIR/$rel_path"
    mkdir -p "$(dirname "$backup_path")"
    mv "$target" "$backup_path"
    info "Backed up: $target -> $backup_path"
  fi
}

dotfiles_prepare_stow_dirs() {
  mkdir -p "$HOME/.ssh" && chmod 700 "$HOME/.ssh"
  mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.zsh"
}

dotfiles_package_files() {
  local pkg_dir="$1"
  find "$pkg_dir" -type f -print0
}

dotfiles_backup_package_conflicts() {
  local os="$1"
  local pkg="$2"
  local pkg_dir rel file target

  pkg_dir="$(dotfiles_package_dir "$os" "$pkg")" || {
    warning "Package listed but missing: $pkg"
    return 1
  }

  while IFS= read -r -d '' file; do
    rel="${file#$pkg_dir/}"

    # ~/.zshrc is intentionally a local bootstrap file (not stowed).
    if [ "$pkg" = "shell" ] && [ "$rel" = ".zshrc" ]; then
      continue
    fi

    target="$HOME/$rel"
    dotfiles_backup_if_needed "$target" "$file"
  done < <(dotfiles_package_files "$pkg_dir")
}

dotfiles_stow_package() {
  local os="$1"
  local pkg="$2"
  local stow_dir

  stow_dir="$(dotfiles_package_stow_dir "$os" "$pkg")"
  if stow --no-folding -d "$stow_dir" -t "$HOME" "$pkg"; then
    success "Stowed: $pkg"
  else
    warning "Stow failed for $pkg"
    return 1
  fi
}

dotfiles_stow_packages() {
  local os="${1:-${DOTFILES_OS:-$(dotfiles_detect_os)}}"
  shift || true
  local packages=("$@")
  local pkg

  if ! command -v stow >/dev/null 2>&1; then
    error_exit "GNU Stow is required but not installed."
  fi

  if [ "${#packages[@]}" -eq 0 ]; then
    while IFS= read -r pkg; do
      packages+=("$pkg")
    done < <(dotfiles_manifest_packages "$os")
  fi

  dotfiles_prepare_stow_dirs

  for pkg in "${packages[@]}"; do
    dotfiles_backup_package_conflicts "$os" "$pkg"
  done

  for pkg in "${packages[@]}"; do
    dotfiles_stow_package "$os" "$pkg"
  done
}

dotfiles_stow_dry_run() {
  local os="${1:-${DOTFILES_OS:-$(dotfiles_detect_os)}}"
  shift || true
  local packages=("$@")
  local pkg stow_dir status=0

  if [ "${#packages[@]}" -eq 0 ]; then
    while IFS= read -r pkg; do
      packages+=("$pkg")
    done < <(dotfiles_manifest_packages "$os")
  fi

  for pkg in "${packages[@]}"; do
    stow_dir="$(dotfiles_package_stow_dir "$os" "$pkg")"
    if ! stow --no-folding -n -v -d "$stow_dir" -t "$HOME" "$pkg"; then
      status=1
    fi
  done

  return "$status"
}
