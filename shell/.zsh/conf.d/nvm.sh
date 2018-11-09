alias nvm-lsr="nvm ls-remote | tail -4"
nvm-current-major() {
    node --version | cut -d. -f1
}
nvm-i() {
    local current_version=`node --version`
    nvm install ${1} --reinstall-packages-from=${2-$current_version}
}
nvm-only() {
    local current_version=`node --version`
    local major=`nvm-current-major`
    local other_versions=`nvm ls $major --no-colors | grep -v $current_version | tr -d ' *>-'`
    while read -r other_version; do
        if [ ! -z "$other_version" ]; then
            nvm uninstall $other_version
        fi
    done <<< "$other_versions"
}
nvm-bump() {
    local current_version=`node --version`
    if [ ! -z "$1" ]; then
        if ! nvm use "$1" ; then
            if nvm-i "$1" ; then
                return 0
            fi
            return 1
        fi
    fi
    local new_major=`nvm-current-major`
    nvm-i $new_major
    nvm-only

    local current_survived=`nvm ls $current_version | grep -v "N/A" | wc -l | tr -d ' '`

    if [ "$current_survived" -gt "0" ]; then
        nvm use $current_version
    fi
}
