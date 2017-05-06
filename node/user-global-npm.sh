# Set PATH to contain user's global npm install location
if [[ ! -e ~/.npm-global ]]; then
    if command -v npm >/dev/null 2>&1; then
        echo "npm is installed but ~/.npm-global does not exist"
        if read -q '?Would you like to set it up [Y/n]? '; then
            mkdir ~/.npm-global
            npm config set prefix '~/.npm-global'
            echo  # newline
            echo "~/.npm-global set up"
        else
            echo  # newline
        fi
    fi
fi
export PATH=~/.npm-global/bin:$PATH

