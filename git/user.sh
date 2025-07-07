# Git user configuration
# Only prompt for user info if not already configured

if [ -z "$(git config --global user.name)" ]; then
    echo "Git user name not configured."
    echo "Please enter the name you would like to use in git commits:"
    read gitname
    if [ ! -z "$gitname" ]; then
        git config --global user.name "$gitname"
        echo "Git user name set to: $gitname"
    else
        echo "Warning: Git user name not configured"
    fi
else
    echo "Git user name already configured: $(git config --global user.name)"
fi

if [ -z "$(git config --global user.email)" ]; then
    echo "Git user email not configured."
    echo "Please enter the email address to use in git commits:"
    read gitemail
    if [ ! -z "$gitemail" ]; then
        git config --global user.email "$gitemail"
        echo "Git user email set to: $gitemail"
    else
        echo "Warning: Git user email not configured"
    fi
else
    echo "Git user email already configured: $(git config --global user.email)"
fi

# Note: GPG signing key should be configured manually if desired
# Current signing key (if any): $(git config --global user.signingkey)
if [ ! -z "$(git config --global user.signingkey)" ]; then
    echo "GPG signing key already configured: $(git config --global user.signingkey)"
fi