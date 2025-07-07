# Git Configuration

Complete git setup with aliases, user configuration, and workflow helpers.

## Quick Setup

```bash
# From dotfiles root
./git/setup.sh

# Or as part of full setup
./setup.sh
```

## Key Features

### Git Aliases

- **Quick Commands**: `git a` (add), `git ci` (commit), `git co` (checkout), `git st` (status)
- **Branch Management**: `git sw` (switch), `git swc` (switch create), `git br` (branch)
- **History & Diffs**: `git lg` (pretty log), `git dsf` (diff-so-fancy), `git last`
- **Rebase & Cleanup**: `git ri` (rebase interactive), `git please` (force push with lease)
- **Branch Cleanup**: `git merged-remote-view/clean`, `git deleted-remote-view/clean`

### Special Functions

- **gm**: Conventional commit helper - `gm feat api "add endpoint"` → `feat[api]: add endpoint`
- **Branch switching**: `git swc feature-name` creates and switches to new branch
- **Pretty logs**: `git lg` shows colorized, graphical commit history
- **Branch cleanup**: View and clean merged/deleted remote branches safely

## SSH Setup

```bash
# Generate SSH key
ssh-keygen -t rsa -b 4096 -C "your@email.com"
# ... follow instructions ...
# Ensure agent is running
eval $(ssh-agent -s)
# Add key to agent
ssh-add ~/.ssh/id_rsa
# Copy public key to clipboard so you can add it to github
cat ~/.ssh/id_rsa.pub | pbcopy
```
