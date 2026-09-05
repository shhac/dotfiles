# secrets/

Encrypted, profile-scoped config bundles for the `agent-*` CLI family.

## What is and isn't in here

**In:** `config.json` and `credentials.json` from `~/.config/agent-*/` — profile
names, hostnames, org and project IDs, and keychain *markers*.

**Not in:** any actual secret. The `agent-*` family stores real credentials in
the OS keychain and writes only a `__KEYCHAIN__` sentinel into these files, so a
bundle is portable configuration, never a credential store. A new machine
restores config from here and then re-authenticates each tool separately.

Also excluded: `*.lock`, `*.bak-*`, `audit.log`, cache directories, and
`agent-deepweb`'s cookie jars (AES-GCM ciphertext whose key lives in the
keychain, so they are meaningless off-machine). Only the filenames in
`SECRETS_ALLOWED_FILES` in `lib/secrets.sh` are ever bundled — an allowlist, so
a tool that starts writing new state has to be added deliberately.

## Files

| File | Tracked | What it is |
|---|---|---|
| `recipients.txt` | yes | age public keys. Safe to commit. |
| `identity.age` | yes | The age identity, passphrase-sealed. Bootstrap path. |
| `profiles.conf` | yes | Which config dir belongs to which profile. |
| `<profile>.tar.gz.age` | yes | The sealed bundle. |
| `<profile>.sha256` | yes | Content fingerprint — see *Why a hash* below. |
| `.open/` | **no** | Decrypted working copies. Gitignored. |

## Usage

```sh
./setup.sh --secrets-init          # once: generate the identity, seal it
./setup.sh --secrets-seal          # after changing any agent-* config
./setup.sh --secrets-open          # on a new machine, for its profiles
./setup.sh --reauth                # list profiles still needing a credential
```

A machine opts in by naming its profiles in `~/.dotfiles-profile.local`
(gitignored). On a machine that has none set, `--secrets-open` and
`--secrets-seal` list the available profiles, ask which to use, and write the
file for you:

```
This machine has no profile set.
Available profiles:
  1. work
Select a profile [1-1]:
```

Or write it directly:

```sh
echo 'DOTFILES_PROFILE=work' > ~/.dotfiles-profile.local
```

Under `--yes` there is no prompt: it fails with the list of available profiles.
That is deliberate — the previous behaviour silently fell back to a profile that
matched no bundle, so a forgotten setting looked like a successful restore of
nothing.

Comma-separated for more than one. A machine that sets nothing gets only
`common`, so work config never lands somewhere it wasn't asked for.

## Sharing is opt-in: profile names decide it

Profile names are arbitrary, and a config dir may be listed under more than one.
That makes "do these two machines share this, or not?" a naming decision rather
than something forced on you:

```
agent-sql   laptop      # laptop's own connections
agent-sql   desktop     # desktop's own connections, independent bundle
agent-dd    shared      # both machines, one bundle
```

```sh
# laptop
echo 'DOTFILES_PROFILE=laptop,shared'  > ~/.dotfiles-profile.local
# desktop
echo 'DOTFILES_PROFILE=desktop,shared' > ~/.dotfiles-profile.local
```

Distinct names give fully independent blobs that can never conflict. A shared
name gives one blob both machines write — which is what you want for config that
should stay in step, and is where a conflict can occur. Sealing is a no-op when
content matches, so a shared profile only churns when it genuinely diverges.

**`--secrets-seal` and drift only ever touch this machine's profiles.** Sealing
another machine's profile would rewrite its bundle from *this* machine's live
config — replacing its data rather than conflicting. Name profiles explicitly
(`./setup.sh --secrets-seal laptop desktop`) if you ever want that.

## Security, stated plainly

The sealed identity is committed to a **public** repository, and it unlocks
every bundle. The passphrase is therefore the whole of the protection, with two
consequences worth being explicit about:

- The ciphertext is permanently public and archived — forks, clones, and GitHub
  retention — so guessing the passphrase is an unlimited-time offline attack.
- A future passphrase compromise **retroactively decrypts every historical
  bundle in git history**. Re-sealing does not unpublish old blobs, and there is
  no rotation story.

Use a long generated passphrase. This is a requirement, not advice.

What this does *not* risk: no credential is in here, so a compromise discloses
infrastructure shape (hostnames, org IDs, workspace URLs), not access.

## The seal-time guard

`--secrets-seal` refuses to encrypt anything that looks like a live credential:
known prefixes (`xoxc-`, `sk_live_`, `ghp_`, `AKIA…`, JWTs, PEM private keys)
and any secret-named field holding a long opaque string where the tools would
normally have left a `__KEYCHAIN__` marker. It reports key paths, never values.

This exists because "these files contain no secrets" is a property of the tools
as they behave today, not a guarantee. A future version storing a token inline
would otherwise reach a public repo, where exposure cannot be undone. The
one-off audit that justified this design is now a standing check.

It deliberately ignores `connections.<name>.credential`: in this family that
field names a credential *alias* to look up, not the credential itself.

## Why a content hash, not a hash of the blob

`age` is nondeterministic per invocation: sealing identical input twice gives
different ciphertext. So the repo commits a fingerprint of the *plaintext*
instead, and `--secrets-seal` re-encrypts only when that changes. Without it,
every seal would write a fresh binary blob and `--capture` would report drift
for a no-op — training you to ignore the one check the design depends on.

The fingerprint hashes file contents, not the archive, because tar embeds
mtimes, modes, and uid/gid, and differs between bsdtar (macOS) and GNU tar
(Linux/WSL2). Restoring a bundle chmods files to 0600, which by itself was
enough to make every rebuild mismatch its own seal.

## Known limitations

- **Profiles are per config *directory*, not per profile within a file.**
  `agent-vercel` keeps a work and a personal account in one `credentials.json`,
  and `agent-slack` keeps work and community workspaces together. Assigning the
  directory to `work` carries all of them. Splitting within a file would mean
  rewriting the tool's own config format, which this deliberately does not do.
- **A shared profile has no merge story.** Two machines writing the same profile
  produce a binary conflict. `.gitattributes` marks the blobs
  `binary -diff -merge` so it fails loudly rather than corrupting silently;
  resolve by opening both, merging the plaintext, and re-sealing. Give the
  machines distinct profile names to avoid the situation entirely.
- **`age` reads passphrases from `/dev/tty` only**, so `./setup.sh --yes` cannot
  unseal. `--secrets-open` decrypts the identity once per run rather than once
  per bundle, so it prompts a single time.

## Why this is copied into place, not stowed

Every other package in this repo is stowed, so this one is worth explaining.

The `agent-*` family writes config atomically — temp file, then `rename` over
the target (`lib-agent-cli/creds/store.go`). `rename` replaces a symlink rather
than following it, so a stowed config would be silently unlinked the first time
any tool wrote to it, leaving the repo copy stale. Worse, the next
`./setup.sh --stow-only` would then treat the live file as a conflict, back it
up, and relink to that stale copy — silently reverting real configuration.
