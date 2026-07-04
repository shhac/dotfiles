#!/usr/bin/env bash

# Drift report: what changed on this machine that the repo hasn't captured.
# Read-only — prints findings and suggested actions; never modifies anything.
# Scripts sourcing this file must set DOTFILES_DIR and source lib/utils.sh +
# lib/stow.sh first.

CAPTURE_IGNORE_FILE="${DOTFILES_DIR}/.captureignore"

capture_status=0

capture_drift() {
  warning "$1"
  capture_status=1
}

capture_check_repo_drift() {
  local changes suspicious

  info "Checking tracked files for drift"
  changes="$(git -C "$DOTFILES_DIR" status --porcelain)"
  if [ -z "$changes" ]; then
    success "Working tree clean"
    return 0
  fi

  capture_drift "Uncommitted changes (review with: git hunk list):"
  printf '%s\n' "$changes"

  # Tools sometimes write machine-specific config into tracked files
  # (e.g. `gh auth setup-git` hardcoding /opt/homebrew paths into
  # .gitconfig). Those belong in the gitignored ~/.*.local overrides.
  # Docs legitimately mention these patterns, so only scan non-markdown diffs.
  suspicious="$(git -C "$DOTFILES_DIR" diff -- . ':(exclude)*.md' | grep -E '^\+[^+]' | grep -E '/opt/homebrew|/usr/local/|/Users/|\[credential' || true)"
  if [ -n "$suspicious" ]; then
    capture_drift "Added lines look machine-specific; consider a ~/.*.local override instead of committing:"
    printf '%s\n' "$suspicious"
  fi
}

capture_check_brewfile() {
  local check_output cleanup_output

  if ! command_exists brew; then
    info "Homebrew not installed; skipping Brewfile checks"
    return 0
  fi

  info "Checking Brewfile for missing installs"
  if check_output="$(brew bundle check --file="$DOTFILES_DIR/Brewfile" --verbose 2>&1)"; then
    success "Everything in the Brewfile is installed"
  else
    capture_drift "Brewfile entries not installed (install with: brew bundle --file=Brewfile):"
    printf '%s\n' "$check_output"
  fi

  info "Checking for installs missing from the Brewfile"
  # Trim brew's cache-cleanup suggestions and its `--force` hint — capture
  # reports drift, it must not recommend uninstalls.
  cleanup_output="$(brew bundle cleanup --file="$DOTFILES_DIR/Brewfile" 2>&1 | sed -e '/^Would `brew cleanup`:/,$d' || true)"
  if ! printf '%s\n' "$cleanup_output" | grep -q '^Would '; then
    success "No installs missing from the Brewfile"
  else
    capture_drift "Installed but not in the Brewfile (add entries by hand — the Brewfile sections are curated, do not 'brew bundle dump --force'):"
    printf '%s\n' "$cleanup_output"
  fi
}

capture_is_ignored() {
  local rel="$1"
  local pattern

  [ -f "$CAPTURE_IGNORE_FILE" ] || return 1

  while IFS= read -r pattern; do
    pattern="${pattern%%#*}"
    pattern="${pattern%"${pattern##*[![:space:]]}"}"
    [ -n "$pattern" ] || continue
    # shellcheck disable=SC2254
    case "$rel" in
      $pattern) return 0 ;;
    esac
  done < "$CAPTURE_IGNORE_FILE"

  return 1
}

capture_managed_paths() {
  local os="$1"
  local pkg pkg_dir file

  while IFS= read -r pkg; do
    pkg_dir="$(dotfiles_package_dir "$os" "$pkg")" || continue
    while IFS= read -r -d '' file; do
      printf '%s\n' "${file#"$pkg_dir"/}"
    done < <(dotfiles_package_files "$pkg_dir")
  done < <(dotfiles_manifest_packages "$os")
}

capture_is_managed() {
  local rel="$1"
  local managed

  while IFS= read -r managed; do
    [ "$managed" = "$rel" ] && return 0
    case "$managed" in
      "$rel"/*) return 0 ;;
    esac
  done <<< "$2"

  return 1
}

capture_check_untracked_configs() {
  local os="$1"
  local managed_paths entry rel found=""

  info "Checking for configs the repo does not manage"
  managed_paths="$(capture_managed_paths "$os")"

  for entry in "$HOME"/.*; do
    rel="$(basename "$entry")"
    case "$rel" in .|..|.config) continue ;; esac
    capture_is_managed "$rel" "$managed_paths" && continue
    capture_is_ignored "$rel" && continue
    found="${found}~/${rel}"$'\n'
  done

  for entry in "$HOME/.config"/*; do
    [ -e "$entry" ] || continue
    rel=".config/$(basename "$entry")"
    capture_is_managed "$rel" "$managed_paths" && continue
    capture_is_ignored "$rel" && continue
    found="${found}~/${rel}"$'\n'
  done

  if [ -z "$found" ]; then
    success "No new unmanaged configs"
  else
    capture_drift "New unmanaged configs — track each as a stow package, or silence it in .captureignore:"
    printf '%s' "$found"
  fi
}

dotfiles_capture() {
  local os="${1:-${DOTFILES_OS:-$(dotfiles_detect_os)}}"

  capture_status=0
  info "Running dotfiles capture for $os"

  capture_check_repo_drift
  capture_check_brewfile
  capture_check_untracked_configs "$os"

  dotfiles_doctor "$os" || capture_status=1

  if [ "$capture_status" -eq 0 ]; then
    success "No drift found — repo matches this machine"
  else
    warning "Drift found — see findings above"
  fi

  return "$capture_status"
}
