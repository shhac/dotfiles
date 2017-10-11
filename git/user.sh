echo "Please enter the name you would like to use in git commits:"
read gitname
if [ -z "$gitname" ]; then
    echo "Not git user name not configured"
else
    git config --global user.name "$gitname"
fi

echo "Please enter the email address to use in git commits:"
read gitemail
if [ -z "$gitemail" ]; then
    echo "Not git user email not configured"
else
    git config --global user.email "$gitemail"
fi
