#!/usr/bin/env bash

# Repository health checks. Scripts sourcing this file must set DOTFILES_DIR and
# source lib/utils.sh + lib/stow.sh first.

doctor_status=0

doctor_fail() {
  warning "$1"
  doctor_status=1
}

doctor_check_manifest() {
  local os="$1"
  local pkg

  info "Checking stow package manifest"
  while IFS= read -r pkg; do
    if ! dotfiles_package_dir "$os" "$pkg" >/dev/null; then
      doctor_fail "Manifest package is missing: $pkg"
    fi
  done < <(dotfiles_manifest_packages "$os")
}

doctor_check_stow() {
  local os="$1"
  local output="/tmp/dotfiles-doctor-stow.$$"

  info "Checking stow dry-run"
  if dotfiles_stow_dry_run "$os" >"$output" 2>&1; then
    success "Stow dry-run clean"
  else
    cat "$output"
    doctor_fail "Stow dry-run reported conflicts; run: ./setup.sh --stow-only"
  fi
  rm -f "$output"
}

doctor_check_broken_symlinks() {
  local os="$1"
  local pkg pkg_dir file rel target

  info "Checking managed targets for broken symlinks"
  while IFS= read -r pkg; do
    pkg_dir="$(dotfiles_package_dir "$os" "$pkg")" || continue
    while IFS= read -r -d '' file; do
      rel="${file#$pkg_dir/}"
      [ "$pkg" = "shell" ] && [ "$rel" = ".zshrc" ] && continue
      target="$HOME/$rel"
      if [ -L "$target" ] && [ ! -e "$target" ]; then
        doctor_fail "Broken symlink: $target"
      fi
    done < <(find "$pkg_dir" -type f -print0)
  done < <(dotfiles_manifest_packages "$os")
}

doctor_check_local_files() {
  info "Checking tracked local override files"
  if git -C "$DOTFILES_DIR" ls-files | grep -E '(^|/)[^.]*\.local($|[.])|settings\.local\.json$' >/dev/null; then
    doctor_fail "Tracked local override files found"
    git -C "$DOTFILES_DIR" ls-files | grep -E '(^|/)[^.]*\.local($|[.])|settings\.local\.json$' || true
  else
    success "No tracked local override files"
  fi
}

doctor_check_secret_patterns() {
  local paths=(
    "$DOTFILES_DIR"
    "$HOME/.npmrc"
    "$HOME/.yarnrc.yml"
  )
  local existing=()
  local path

  info "Checking for obvious secret patterns"
  for path in "${paths[@]}"; do
    [ -e "$path" ] && existing+=("$path")
  done

  if [ "${#existing[@]}" -eq 0 ]; then
    success "No paths to scan"
    return 0
  fi

  if rg -l -i --hidden --glob '!.git/**' --glob '!lib/doctor.sh' '(npm_[A-Za-z0-9]{20,}|-----BEGIN .*PRIVATE KEY-----|(api[_-]?key|auth[_-]?token|npmAuthToken|password|secret|credential)\s*[:=]\s*["'\'']?[^"'\'']{8,})' "${existing[@]}" >/tmp/dotfiles-doctor-secret-matches.$$ 2>/dev/null; then
    doctor_fail "Potential secret-bearing files found:"
    sed "s#^$HOME#~#" /tmp/dotfiles-doctor-secret-matches.$$
  else
    success "No obvious secret patterns found"
  fi

  rm -f /tmp/dotfiles-doctor-secret-matches.$$
}

doctor_check_permissions() {
  info "Checking sensitive directory permissions"
  [ ! -d "$HOME/.ssh" ] || [ "$(stat -f '%Lp' "$HOME/.ssh" 2>/dev/null || stat -c '%a' "$HOME/.ssh" 2>/dev/null)" = "700" ] || doctor_fail "~/.ssh should be chmod 700"
  [ ! -d "$HOME/.gnupg" ] || [ "$(stat -f '%Lp' "$HOME/.gnupg" 2>/dev/null || stat -c '%a' "$HOME/.gnupg" 2>/dev/null)" = "700" ] || doctor_fail "~/.gnupg should be chmod 700"
}

doctor_check_skills_lock() {
  info "Checking skills lock metadata"
  if [ -f "$DOTFILES_DIR/agents/.agents/.skill-lock.json" ]; then
    if command -v npx >/dev/null 2>&1 || command -v bunx >/dev/null 2>&1; then
      success "Skills lock present and a skills runner is available"
    else
      doctor_fail "Skills lock present but neither npx nor bunx is available"
    fi
  else
    info "No tracked global skills lock"
  fi
}

dotfiles_doctor() {
  local os="${1:-${DOTFILES_OS:-$(dotfiles_detect_os)}}"

  doctor_status=0
  info "Running dotfiles doctor for $os"

  doctor_check_manifest "$os"
  doctor_check_stow "$os"
  doctor_check_broken_symlinks "$os"
  doctor_check_local_files
  doctor_check_secret_patterns
  doctor_check_permissions
  doctor_check_skills_lock

  if [ "$doctor_status" -eq 0 ]; then
    success "Doctor checks passed"
  else
    warning "Doctor checks found issues"
  fi

  return "$doctor_status"
}
