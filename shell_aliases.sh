alias g=git
alias esfix="eslint --fix --"
alias ip="dig +short myip.opendns.com @resolver1.opendns.com"
alias localip="ipconfig getifaddr en0"
alias listip="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

# Mac

alias afk="/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend"
alias subl="open -a Sublime\\ Text"

# Mac/Linux

mkd() {
    for dir in "$@"; do
        mkdir "$dir"
        cd "$dir"
    done
}

pwg() {
    pwgen -cnsB ${1-64} 1 | tr -d '\n' | pbcopy;
    printf "Copied: " && pbpaste && printf "\n";
}

mozjpeg() {
    if [ "$#" -ne 3 ]; then
        echo "Usage: $0 quality infile outfile"
    else
        /usr/local/opt/mozjpeg/bin/cjpeg -quality $1 "$2" -outfile "$3"
    fi
}
