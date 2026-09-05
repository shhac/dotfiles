#!/bin/bash
# Encrypted, profile-scoped agent-* config bundles.
#
# The agent-* CLI family keeps portable config (profiles, hosts, org IDs) in
# ~/.config/<tool>/{config,credentials}.json and its actual secrets in the OS
# keychain. Only the portable half is bundled here; secrets are never written
# to the repo. A new machine re-authenticates each tool (see --reauth).
#
# Sync is copy-based, NOT stow. The family writes config atomically
# (temp file + rename), which replaces a symlink rather than following it, so
# a stowed config would be silently unlinked on first write — and the next
# --stow-only would then back up the live file and relink to a stale repo copy.

SECRETS_DIR="${SECRETS_DIR:-$DOTFILES_DIR/secrets}"
SECRETS_OPEN_DIR="$SECRETS_DIR/.open"
SECRETS_IDENTITY="$SECRETS_DIR/identity.age"
SECRETS_RECIPIENTS="$SECRETS_DIR/recipients.txt"
SECRETS_PROFILES_CONF="$SECRETS_DIR/profiles.conf"

# Only these filenames are ever bundled. An allowlist rather than an exclude
# list: a tool that starts writing a new state file must be added here
# deliberately, instead of being swept into the repo by accident.
SECRETS_ALLOWED_FILES=("config.json" "credentials.json")

# Fixed timestamp for staged files so the archive is byte-stable across seals.
SECRETS_EPOCH="202001010000.00"

secrets_config_root() { printf '%s\n' "${XDG_CONFIG_HOME:-$HOME/.config}"; }

# Machine profiles, from ~/.dotfiles-profile.local (gitignored). Falls back to
# "common" so a machine that never opted in gets only the shared bundle.
secrets_machine_profiles() {
  local file="$HOME/.dotfiles-profile.local"
  local value=""

  if [ -n "${DOTFILES_PROFILE:-}" ]; then
    value="$DOTFILES_PROFILE"
  elif [ -f "$file" ]; then
    value="$(sed -n 's/^[[:space:]]*DOTFILES_PROFILE[[:space:]]*=[[:space:]]*//p' "$file" | tail -n1)"
    value="${value%\"}"; value="${value#\"}"
  fi

  [ -n "$value" ] || value="common"
  printf '%s\n' "$value" | tr ',' '\n' | sed 's/[[:space:]]//g' | grep -v '^$' | sort -u
}

# All profiles named in profiles.conf.
secrets_all_profiles() {
  [ -f "$SECRETS_PROFILES_CONF" ] || return 0
  awk '{sub(/#.*/,"")} NF>=2 {print $2}' "$SECRETS_PROFILES_CONF" | sort -u
}

# Config dirs assigned to a profile, one per line, that exist on this machine.
secrets_dirs_for_profile() {
  local profile="$1"
  local root; root="$(secrets_config_root)"
  local dir

  [ -f "$SECRETS_PROFILES_CONF" ] || return 0

  awk -v p="$profile" '{sub(/#.*/,"")} NF>=2 && $2==p {print $1}' "$SECRETS_PROFILES_CONF" \
    | sort -u | while IFS= read -r dir; do
      [ -d "$root/$dir" ] && printf '%s\n' "$dir"
    done
}

# Copy the allowlisted files for a profile into a staging dir, with mtimes
# pinned so identical content always produces an identical archive.
secrets_stage() {
  local profile="$1" stage="$2"
  local root; root="$(secrets_config_root)"
  local dir name staged=0

  while IFS= read -r dir; do
    for name in "${SECRETS_ALLOWED_FILES[@]}"; do
      [ -f "$root/$dir/$name" ] || continue
      mkdir -p "$stage/$dir"
      cp "$root/$dir/$name" "$stage/$dir/$name"
      staged=$((staged + 1))
    done
  done < <(secrets_dirs_for_profile "$profile")

  [ "$staged" -gt 0 ] || return 1

  find "$stage" -exec touch -t "$SECRETS_EPOCH" {} + 2>/dev/null || true
  printf '%s\n' "$staged"
}

# Content fingerprint of a staging dir: a hash over the sorted list of
# (content hash, relative path) pairs.
#
# Deliberately NOT a hash of the archive. A tar embeds mtimes, file modes,
# uid/gid and owner names, so an archive hash reports drift when no file
# content changed — restoring a bundle chmods files to 0600, which alone made
# every rebuild mismatch its own seal. It also differs between bsdtar (macOS)
# and GNU tar (Linux/WSL2), which this repo both support. Hashing content
# sidesteps all of it: identical files always produce an identical fingerprint.
secrets_content_hash() {
  local stage="$1"
  (
    cd "$stage" || return 1
    find . -type f | sed 's|^\./||' | LC_ALL=C sort | while IFS= read -r rel; do
      printf '%s  %s\n' "$(shasum -a 256 "$rel" | awk '{print $1}')" "$rel"
    done
  ) | shasum -a 256 | awk '{print $1}'
}

# Transport archive of a staging dir on stdout.
#
# Every layer here is nondeterministic by default: bsdtar embeds mtimes and (on
# macOS) AppleDouble xattr members, and `tar czf` stamps a gzip mtime. Hence
# pinned mtimes, sorted members, COPYFILE_DISABLE, and `gzip -n`. This keeps the
# blob from churning gratuitously; correctness rests on secrets_content_hash.
secrets_archive() {
  local stage="$1"
  local members
  members="$(cd "$stage" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)"
  [ -n "$members" ] || return 1
  # Member list on stdin rather than as arguments: an unquoted expansion would
  # not word-split under zsh at all, and would split on spaces in bash.
  (cd "$stage" && printf '%s\n' "$members" | COPYFILE_DISABLE=1 tar cf - -T -) | gzip -n
}

# Refuse to seal anything that looks like a live credential.
#
# The family stores secrets in the keychain and writes only a __KEYCHAIN__
# marker, which is why these bundles are safe to publish — but that is a
# property of the tools today, not a guarantee. A future version storing a
# token inline would otherwise sail into a public repo, where the exposure is
# permanent. This is the standing check that the one-off audit was.
#
# Prints key paths only, never values.
secrets_scan_for_plaintext_secrets() {
  local stage="$1"
  python3 - "$stage" <<'PYEOF'
import json, os, re, sys

stage = sys.argv[1]
SENTINEL = "__KEYCHAIN__"

# Well-known credential prefixes, plus JWTs and PEM private keys.
SHAPES = [
    (re.compile(r"^xox[abcdeprs]-"), "Slack token"),
    (re.compile(r"^(sk|rk|pk)_(live|test)_"), "Stripe key"),
    (re.compile(r"^(ghp|gho|ghu|ghs|ghr)_"), "GitHub token"),
    (re.compile(r"^github_pat_"), "GitHub fine-grained PAT"),
    (re.compile(r"^AKIA[0-9A-Z]{16}$"), "AWS access key id"),
    (re.compile(r"^eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\."), "JWT"),
    (re.compile(r"BEGIN [A-Z ]*PRIVATE KEY"), "private key"),
    (re.compile(r"^phc_[A-Za-z0-9]{20,}"), "PostHog key"),
    (re.compile(r"^dop_v1_"), "Doppler token"),
]

# Leaf names that hold a secret VALUE. Deliberately excludes "credential":
# in this family `connections.<name>.credential` names a credential alias to
# look up, not the credential itself, so including it flags every connection.
SECRET_KEYS = ("password", "token", "secret", "api_key", "apikey", "app_key",
               "console_key", "client_key", "cookie", "passphrase", "blob",
               "private_key")

findings = []

def inspect(value, trail, rel):
    if not isinstance(value, str) or value == SENTINEL or not value:
        return
    for pattern, what in SHAPES:
        if pattern.search(value):
            findings.append((rel, ".".join(trail), what))
            return
    leaf = trail[-1].lower() if trail else ""
    # A secret-named field holding a long opaque string, where the tools would
    # normally have left a sentinel.
    if any(t in leaf for t in SECRET_KEYS) and len(value) >= 20 \
            and re.fullmatch(r"[A-Za-z0-9_\-\.+/=]+", value):
        findings.append((rel, ".".join(trail), "unsentinelled secret-shaped field"))

def walk(node, trail, rel):
    if isinstance(node, dict):
        for k, v in node.items():
            walk(v, trail + [k], rel)
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk(v, trail + [str(i)], rel)
    else:
        inspect(node, trail, rel)

for root, _, files in os.walk(stage):
    for name in sorted(files):
        full = os.path.join(root, name)
        rel = os.path.relpath(full, stage)
        try:
            walk(json.load(open(full)), [], rel)
        except Exception:
            continue

for rel, path, what in findings:
    print(f"  {rel}: {path} ({what})")
sys.exit(1 if findings else 0)
PYEOF
}

secrets_require_age() {
  command_exists age || error_exit "age is not installed (brew install age)"
}

# Decrypt the passphrase-sealed identity once per run and reuse it, so a
# multi-bundle open prompts once rather than once per bundle. age reads
# passphrases from /dev/tty only — there is no env var or stdin path.
SECRETS_IDENTITY_TMP=""
secrets_identity_file() {
  if [ -n "$SECRETS_IDENTITY_TMP" ] && [ -f "$SECRETS_IDENTITY_TMP" ]; then
    printf '%s\n' "$SECRETS_IDENTITY_TMP"
    return 0
  fi

  local plain="${AGE_IDENTITY_FILE:-$HOME/.config/age/keys.txt}"
  if [ -f "$plain" ]; then
    printf '%s\n' "$plain"
    return 0
  fi

  [ -f "$SECRETS_IDENTITY" ] || return 1

  SECRETS_IDENTITY_TMP="$(mktemp "${TMPDIR:-/tmp}/dotfiles-age.XXXXXX")"
  chmod 600 "$SECRETS_IDENTITY_TMP"
  # shellcheck disable=SC2064
  trap "rm -f '$SECRETS_IDENTITY_TMP'" EXIT INT TERM

  info "Unlocking the sealed age identity (passphrase required)" >&2
  if ! age -d -o "$SECRETS_IDENTITY_TMP" "$SECRETS_IDENTITY" >/dev/null; then
    rm -f "$SECRETS_IDENTITY_TMP"
    SECRETS_IDENTITY_TMP=""
    return 1
  fi
  printf '%s\n' "$SECRETS_IDENTITY_TMP"
}

# --- commands ---------------------------------------------------------------

dotfiles_secrets_init() {
  secrets_require_age

  local plain="${AGE_IDENTITY_FILE:-$HOME/.config/age/keys.txt}"

  mkdir -p "$SECRETS_DIR"
  mkdir -p "$(dirname "$plain")" && chmod 700 "$(dirname "$plain")"

  if [ -f "$plain" ]; then
    info "Reusing existing age identity: $plain"
  else
    info "Generating age identity: $plain"
    age-keygen -o "$plain" 2>/dev/null || error_exit "age-keygen failed"
    chmod 600 "$plain"
  fi

  age-keygen -y "$plain" > "$SECRETS_RECIPIENTS" \
    || error_exit "could not derive public key from $plain"
  success "Wrote recipients: $SECRETS_RECIPIENTS"

  if [ -f "$SECRETS_IDENTITY" ]; then
    info "Sealed identity already exists, leaving it alone: $SECRETS_IDENTITY"
  else
    warning "The sealed identity is committed to a PUBLIC repo."
    warning "Its passphrase is the only thing protecting every bundle, now and"
    warning "in git history — a leak retroactively opens past blobs and cannot"
    warning "be rotated. Use a long generated passphrase."
    age -p -o "$SECRETS_IDENTITY" "$plain" || error_exit "sealing identity failed"
    success "Sealed identity: $SECRETS_IDENTITY"
  fi

  if [ ! -f "$SECRETS_PROFILES_CONF" ]; then
    secrets_write_default_profiles_conf
    success "Wrote $SECRETS_PROFILES_CONF — review the profile assignments"
  fi

  if [ ! -f "$HOME/.dotfiles-profile.local" ]; then
    info "Set this machine's profile in ~/.dotfiles-profile.local, e.g."
    info "  echo 'DOTFILES_PROFILE=work' > ~/.dotfiles-profile.local"
  fi
}

secrets_write_default_profiles_conf() {
  local root; root="$(secrets_config_root)"
  local dir base

  {
    echo "# Which profile each agent-* config dir belongs to."
    echo "# Format: <config-dir-name> <profile>"
    echo "#"
    echo "# A machine opts in via DOTFILES_PROFILE in ~/.dotfiles-profile.local"
    echo "# (comma-separated). Only listed dirs are ever bundled, and only the"
    echo "# files in SECRETS_ALLOWED_FILES within them."
    echo "#"
    echo "# Defaults below are 'work' because that is the more restrictive"
    echo "# choice — reassign anything personal and re-run --secrets-seal."
    echo ""
    for dir in "$root"/agent-* "$root"/app.paulie.agent-*; do
      [ -d "$dir" ] || continue
      base="$(basename "$dir")"
      # Superseded by app.paulie.agent-slack; the TypeScript CLI that owned it
      # is retired and it points at a different keychain service.
      [ "$base" = "agent-slack" ] && continue
      printf '%-32s work\n' "$base"
    done
  } > "$SECRETS_PROFILES_CONF"
}

dotfiles_secrets_seal() {
  secrets_require_age
  [ -f "$SECRETS_RECIPIENTS" ] || error_exit "no recipients file — run ./setup.sh --secrets-init"

  # This machine's profiles, NOT every profile in profiles.conf. Sealing another
  # machine's profile would rewrite its bundle from THIS machine's live config,
  # silently replacing its data rather than conflicting. Name profiles
  # explicitly (`--secrets-seal work personal`) to override.
  local profiles=("$@")
  if [ "${#profiles[@]}" -eq 0 ]; then
    mapfile -t profiles < <(secrets_machine_profiles)
  fi
  [ "${#profiles[@]}" -gt 0 ] || { warning "No profiles for this machine — set DOTFILES_PROFILE in ~/.dotfiles-profile.local"; return 0; }

  local profile stage tar_path hash prev count guard_output changed=0
  for profile in "${profiles[@]}"; do
    stage="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-seal.XXXXXX")"
    if ! count="$(secrets_stage "$profile" "$stage")"; then
      info "$profile: nothing on this machine to seal, skipping"
      rm -rf "$stage"
      continue
    fi

    if ! guard_output="$(secrets_scan_for_plaintext_secrets "$stage")"; then
      rm -rf "$stage"
      warning "Refusing to seal $profile — these look like live credentials:"
      printf '%s\n' "$guard_output"
      error_exit "bundles are published; move these into the keychain, then re-seal"
    fi

    tar_path="$(mktemp "${TMPDIR:-/tmp}/dotfiles-tar.XXXXXX")"
    secrets_archive "$stage" > "$tar_path"
    hash="$(secrets_content_hash "$stage")"
    prev=""
    [ -f "$SECRETS_DIR/$profile.sha256" ] && prev="$(cat "$SECRETS_DIR/$profile.sha256")"

    if [ "$hash" = "$prev" ] && [ -f "$SECRETS_DIR/$profile.tar.gz.age" ]; then
      info "$profile: unchanged ($count files), not re-sealing"
    else
      age -R "$SECRETS_RECIPIENTS" -o "$SECRETS_DIR/$profile.tar.gz.age" "$tar_path" \
        || error_exit "age encryption failed for $profile"
      printf '%s\n' "$hash" > "$SECRETS_DIR/$profile.sha256"
      success "$profile: sealed $count files -> $profile.tar.gz.age"
      changed=1
    fi

    rm -rf "$stage" "$tar_path"
  done

  [ "$changed" -eq 1 ] && info "Commit the updated secrets/ files"
  return 0
}

dotfiles_secrets_open() {
  secrets_require_age

  local profiles=("$@")
  if [ "${#profiles[@]}" -eq 0 ]; then
    mapfile -t profiles < <(secrets_machine_profiles)
  fi

  local identity
  identity="$(secrets_identity_file)" \
    || error_exit "no age identity available (run --secrets-init, or place one at ~/.config/age/keys.txt)"

  local root; root="$(secrets_config_root)"
  local profile blob dest rel target opened=0

  for profile in "${profiles[@]}"; do
    blob="$SECRETS_DIR/$profile.tar.gz.age"
    if [ ! -f "$blob" ]; then
      info "$profile: no bundle in the repo, skipping"
      continue
    fi

    dest="$SECRETS_OPEN_DIR/$profile"
    rm -rf "$dest"; mkdir -p "$dest"
    age -d -i "$identity" "$blob" | tar xf - -C "$dest" \
      || error_exit "could not open $profile (wrong passphrase or corrupt bundle)"

    while IFS= read -r rel; do
      target="$root/$rel"
      mkdir -p "$(dirname "$target")"
      if [ -e "$target" ] && ! cmp -s "$dest/$rel" "$target"; then
        dotfiles_backup_if_needed "$target" ""
      fi
      cp "$dest/$rel" "$target"
      chmod 600 "$target"
      opened=$((opened + 1))
    done < <(cd "$dest" && find . -type f | sed 's|^\./||' | LC_ALL=C sort)

    success "$profile: opened into $root"
  done

  if [ "$opened" -gt 0 ]; then
    info "Config restored. Secrets are NOT in the repo — run ./setup.sh --reauth"
  fi
  return 0
}

# Report unsealed config as ordinary drift. Comparing against the blob is
# impossible (age is nondeterministic per invocation), so this compares the
# rebuilt plaintext archive against the committed hash — the same artifact
# that stops --secrets-seal rewriting a blob when nothing changed.
capture_check_secrets_drift() {
  [ -f "$SECRETS_PROFILES_CONF" ] || return 0
  command_exists age || return 0

  info "Checking sealed agent config for drift"

  # Only this machine's profiles: another machine's bundle legitimately differs
  # from this machine's config and is not drift.
  local profile stage hash prev found=""
  while IFS= read -r profile; do
    [ -f "$SECRETS_DIR/$profile.sha256" ] || continue
    stage="$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-drift.XXXXXX")"
    if secrets_stage "$profile" "$stage" >/dev/null; then
      hash="$(secrets_content_hash "$stage")"
      prev="$(cat "$SECRETS_DIR/$profile.sha256")"
      [ "$hash" != "$prev" ] && found="$found  $profile"$'\n'
    fi
    rm -rf "$stage"
  done < <(secrets_machine_profiles)

  if [ -n "$found" ]; then
    capture_drift "Unsealed agent config differs from the repo (run ./setup.sh --secrets-seal):"
    printf '%s' "$found"
  else
    success "Sealed agent config up to date"
  fi
}

# Which tools have config but no usable secret behind it. Reads only the
# keychain-sentinel metadata the tools already write; never reads a secret
# value, and makes no assumption about where a credential should come from.
dotfiles_reauth() {
  local root; root="$(secrets_config_root)"
  local dir base file found=""

  info "agent-* profiles whose secrets live in this machine's keychain"

  for dir in "$root"/agent-* "$root"/app.paulie.agent-*; do
    [ -d "$dir" ] || continue
    base="$(basename "$dir")"
    [ "$base" = "agent-slack" ] && continue

    for file in "$dir/credentials.json" "$dir/config.json"; do
      [ -f "$file" ] || continue
      python3 - "$file" "$base" <<'PYEOF'
import json, sys
path, tool = sys.argv[1], sys.argv[2]
try:
    data = json.load(open(path))
except Exception:
    sys.exit(0)

SENTINEL = "__KEYCHAIN__"
# Sibling fields that name a list entry better than its index does.
LABELS = ("label", "alias", "name", "workspace_name", "workspace_url", "username")
hits = set()

def label_for(entry, index):
    if isinstance(entry, dict):
        for key in LABELS:
            value = entry.get(key)
            if isinstance(value, str) and value and value != SENTINEL:
                return value
    return str(index)

def walk(node, trail):
    if isinstance(node, dict):
        for k, v in node.items():
            walk(v, trail + [k])
    elif isinstance(node, list):
        for i, v in enumerate(node):
            walk(v, trail + [label_for(v, i)])
    elif node == SENTINEL and len(trail) > 1:
        # Drop the leaf (the secret field itself); what remains identifies the
        # profile, connection, or workspace the secret belongs to.
        hits.add(".".join(trail[:-1]))

walk(data, [])
for h in sorted(hits):
    print(f"  {tool:<28} {h}")
PYEOF
    done
  done | sort -u | while IFS= read -r line; do
    [ -n "$line" ] && printf '%s\n' "$line"
  done

  echo ""
  info "Each needs authenticating on a new machine. This lists what exists"
  info "here, not what is missing there — the family has no shared registry of"
  info "keychain service names to diff against. Use each tool's own auth"
  info "command, and mint a fresh credential where the service allows it."
}
