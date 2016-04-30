# Personalise Git

```
git config --global user.name "your name"
git config --global user.email "your@email.com"
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
clip < ~/.ssh/id_rsa.pub
```

