export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="shhac-starship-rounded-bubble"
ZSH_CUSTOM="$HOME/.zsh"
export DEFAULT_USER="paul"

plugins=(git git-open)

source $ZSH/oh-my-zsh.sh

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Load conf.d
for file in ~/.zsh/conf.d/*; do
  [ -r "$file" ] && source "$file"
done

# Local overrides (machine-specific, not tracked in dotfiles)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
