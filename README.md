# Dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/). Supports macOS, Linux, and WSL2.

## Quick Start (Fresh Mac)

On a brand new Mac, you only need `git` (comes with Xcode CLT):

```bash
# 1. Clone this repo
git clone https://github.com/shhac/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run the setup
./setup.sh
```

That's it. The setup script handles everything:

1. Installs **Xcode Command Line Tools** (if needed)
2. Installs **Homebrew**
3. Installs all packages from the **Brewfile** (CLI tools, casks, fonts, Mac App Store apps)
4. Installs **Oh My Zsh**, **NVM + Node.js LTS**, **Tmux Plugin Manager**
5. **Stows** all config packages as symlinks into `$HOME`
6. Prompts for **git identity** (name, email, GPG key)
7. Optionally applies **macOS system preferences**
8. Sets **brew's zsh** as the default shell

### Non-interactive mode

```bash
./setup.sh --yes
```

### Stow-only and doctor modes

```bash
./setup.sh --stow-only          # Stow all packages for this OS
./setup.sh --stow-only codex    # Stow one package
./setup.sh --doctor             # Check stow, symlinks, secrets, and permissions
```

## How It Works

Packages are listed explicitly in `stow-packages.txt`. Each package mirrors
`$HOME`:

```
dotfiles/
├── shell/              → ~/.zshrc.shared, ~/.zprofile, ~/.zsh/conf.d/*, ~/.zsh/themes/*
├── git/                → ~/.gitconfig, ~/.gitignore_global
├── vim/                → ~/.vimrc
├── nvim/               → ~/.config/nvim/init.vim
├── ghostty/            → ~/.config/ghostty/config
├── codex/              → ~/.codex/pets/* (custom pets only)
├── cmux/               → ~/.config/cmux/cmux.json
├── graphite/           → ~/.config/graphite/aliases
├── agents/             → ~/.agents/.skill-lock.json
├── tmux/               → ~/.tmux.conf
├── ssh/                → ~/.ssh/config
├── gpg/                → ~/.gnupg/gpg-agent.conf
│
├── os-macos/           # macOS-specific (not stowed directly)
│   ├── setup.sh        # Main setup orchestrator
│   └── defaults.sh     # macOS system preferences
│
├── os-linux/           # Linux setup
├── os-wsl2/            # WSL2 setup
├── lib/                # Shared shell utilities
├── scripts/            # Helper scripts used by setup
├── templates/          # Bootstrap templates copied into local files
├── Brewfile            # Homebrew packages, casks, and apps
├── stow-packages.txt   # Explicit package manifest
├── setup.sh            # Entry point (detects OS, delegates)
└── .stow-local-ignore  # Prevents stow from linking repo files
```

Running `stow shell` from this directory creates symlinks:
- `~/.zshrc.shared` → `dotfiles/shell/.zshrc.shared`
- `~/.zprofile` → `dotfiles/shell/.zprofile`
- `~/.zsh/conf.d/git.sh` → `dotfiles/shell/.zsh/conf.d/git.sh`
- etc.

Prefer `./setup.sh --stow-only [package]` for normal package updates; it uses the
same backup and OS-override logic as full setup.

`~/.zshrc` is intentionally a local bootstrap file (not symlinked) that sources `~/.zshrc.shared` and `~/.zshrc.local`.

## Machine-Specific Overrides

Configs use the **`.local` file pattern** — tracked files source/include an untracked `.local` counterpart:

| Tracked config | Sources/includes | Purpose |
|---|---|---|
| `~/.zshrc.shared` | `~/.zshrc.local` (via local `~/.zshrc` bootstrap) | Shared shell config + machine-specific PATH/env |
| `~/.gitconfig` | `~/.gitconfig.local` | User identity, signing key, `[includeIf]` |
| `~/.ssh/config` | `~/.ssh/config.local` | Machine-specific SSH hosts |
| `~/.zprofile` | `~/.zprofile.local` | Machine-specific shell profile |

All `.local` files are gitignored. Create them on each machine for local customization.

## Git Aliases

Extensive aliases are configured in `git/.gitconfig`:

| Alias | Command | Description |
|---|---|---|
| `git sw` | `switch` | Switch branches |
| `git swc` | `switch -c` | Create and switch to branch |
| `git st` | `status -sb` | Short status |
| `git lg` | `log --graph ...` | Pretty log with graph |
| `git please` | `push --force-with-lease` | Safe force push |
| `git commend` | `commit --amend --no-edit` | Amend without editing message |
| `git dsf` | diff via diff-so-fancy | Pretty diffs |
| `git merged-remote-view` | | View merged remote branches |
| `git merged-remote-clean` | | Delete merged remote branches |
| `git deleted-remote-view` | | View deleted remote branches (dry-run) |
| `git deleted-remote-clean` | | Clean up deleted remote refs |

## Git Commit Function

The `gm` shell function (in `shell/.zsh/conf.d/git.sh`) provides structured conventional commits:

```bash
gm feat api "add user authentication"    # feat[api]: add user authentication
gm fix - "resolve login issue"           # fix: resolve login issue
gm chore deps "update package versions"  # chore[deps]: update package versions
```

## Shell Configuration

- **Zsh** with **Oh My Zsh** and custom themes
- **Default theme:** `shhac-starship-rounded-bubble`
- **Plugins:** `git`, `git-open`
- **Custom functions/aliases** loaded from `~/.zsh/conf.d/`
- **11 custom themes** available in `~/.zsh/themes/`

## Codex

Custom Codex pets are tracked in `codex/.codex/pets/` and stowed into
`~/.codex/pets/`. The rest of `~/.codex` is intentionally left untracked because
it contains auth state, caches, sessions, logs, local runtime paths, and trusted
workspace settings.

The currently selected pet lives in `~/.codex/config.toml` as local app state.
After setting up a new machine, reselect the preferred custom pet in Codex.

## Agent Skills

Global skills installed with `npx skills` are tracked by lock metadata in
`agents/.agents/.skill-lock.json`, not by vendoring installed skill directories.
Setup uses `scripts/install-skills-from-lock.sh` to reinstall the locked skills.
Set `DOTFILES_SKILLS_AGENTS=claude-code,codex` to force target agents; otherwise
the `skills` CLI auto-detects available agents.

Personal skill source lives outside this repo, in the sibling `../skills` repo.

## Secrets

Secrets are not tracked. The repo includes `age` in the Brewfile and ignores
common decrypted secret filenames, but there is no automatic secret encryption
workflow yet. Files such as `.npmrc`, `.yarnrc`, `.yarnrc.yml`, `.netrc`, cloud
credentials, tokens, and `.local` overrides should stay untracked unless they are
sanitized or deliberately encrypted.

## After Setup

These steps require manual action:

- [ ] Import GPG secret keys: `gpg --import /path/to/private-key.asc`
- [ ] Copy SSH keys to `~/.ssh/` and `chmod 600 ~/.ssh/id_*`
- [ ] Sign into Mac App Store (for `mas` packages)
- [ ] Authenticate: `gh auth login`, `npm login`, `gt auth`
- [ ] Edit `~/.zshrc.local`, `~/.gitconfig.local`, `~/.ssh/config.local` for machine-specific config
- [ ] Review macOS defaults: `./setup.sh macos`

## Adding New Configs

To track a new tool's config:

```bash
# 1. Create a stow package mirroring the home directory structure
mkdir -p toolname/.config/toolname
cp ~/.config/toolname/config toolname/.config/toolname/config

# 2. Add it to stow-packages.txt, then stow it
./setup.sh --stow-only toolname

# 3. Verify the symlink
ls -la ~/.config/toolname/config
```

## Updating

After making changes to tracked configs on your machine (they're symlinks, so changes go directly to the repo):

```bash
cd ~/.dotfiles
git hunk add --all
git commit -m "update: description of changes"
git push
```

To update the Brewfile after installing new packages:

```bash
brew bundle dump --force --describe --file=~/.dotfiles/Brewfile
```
