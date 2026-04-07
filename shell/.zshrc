# -----------------------------------------------------------------------------
# Dotfiles-managed zsh bootstrap
# Only the managed block below is maintained by dotfiles setup.
# Tools/installers may append outside this block.
# -----------------------------------------------------------------------------
# >>> DOTFILES MANAGED START >>>

# Shared tracked config (symlinked from dotfiles)
[ -f "$HOME/.zshrc.shared" ] && source "$HOME/.zshrc.shared"

# Machine-specific overrides (untracked)
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

# <<< DOTFILES MANAGED END <<<
# -----------------------------------------------------------------------------

