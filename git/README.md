# Run git setup

```
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/git/setup.sh)"
```

# Setup SSH

```
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
