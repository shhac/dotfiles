# Dotfiles

Personal dotfiles for macOS development environment setup with git, shell, and vim configurations.

## Quick Start

### Local Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/shhac/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run complete setup
./setup.sh
```

### Remote Setup (Legacy)

```bash
# macOS complete setup
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/setup.sh)"
```

## What Gets Configured

- **Git**: Aliases, user settings, push/pull configuration, diff tools
- **Shell**: Oh My Zsh with custom theme, plugins, and configuration files
- **Vim**: Basic vim configuration with syntax highlighting and sensible defaults
- **macOS**: System preferences, Homebrew packages, development tools

### Tools Installed (macOS)

- **Development**: git, tig, diff-so-fancy, doppler, graphite
- **Utilities**: thefuck, tldr, pwgen
- **GUI Apps**: Visual Studio Code, iTerm2, Fira Code font
- **Node.js**: via NVM with latest LTS

## Individual Component Setup

You can run individual setup scripts for specific components:

```bash
# Git configuration only
./git/setup.sh

# Shell configuration only  
./shell/setup.sh

# Vim configuration only
./vim/setup.sh

# macOS full setup (includes all components)
./mac/setup.sh
```

## Key Features

### Git Configuration
- **Conventional commits**: Use `gm feat api "add new endpoint"` for `feat[api]: add new endpoint`
- **Extensive aliases**: `git sw` (switch), `git lg` (pretty log), `git please` (force push with lease)
- **Modern workflow**: Configured for current Git best practices

### Shell Configuration
- **Oh My Zsh**: With `ataganoster` custom theme
- **Custom functions**: Utility functions in `shell/conf.d/`
- **Tool integration**: Doppler, Graphite, Claude CLI support
- **Plugin support**: git-open and other productivity plugins

### Modern Development Tools
- **Doppler**: Secrets management with `dope()` function
- **Graphite**: Git workflow tool with completions
- **Claude CLI**: AI assistant with convenient alias

## Directory Structure

```
dotfiles/
├── setup.sh              # Main setup script
├── git/                   # Git configuration
│   ├── setup.sh
│   ├── aliases.sh
│   ├── user.sh
│   └── ...
├── shell/                 # Shell configuration
│   ├── setup.sh
│   ├── conf.d/            # Configuration modules
│   └── themes/            # Custom zsh themes
├── vim/                   # Vim configuration
│   ├── setup.sh
│   └── .vimrc
├── mac/                   # macOS-specific setup
│   ├── setup.sh
│   ├── osx-config.sh      # System preferences
│   └── iterm2-profiles/   # Terminal configurations
└── CLAUDE.md             # Claude Code guidance
```

## Requirements

- **macOS**: 10.15+ (for macOS setup)
- **Git**: For cloning and git configuration
- **curl**: For downloading dependencies
- **Internet connection**: For initial tool downloads

## Troubleshooting

### Common Issues

1. **Permission errors**: Ensure scripts are executable with `chmod +x setup.sh`
2. **Homebrew path issues**: Restart terminal after Homebrew installation
3. **Oh My Zsh conflicts**: Remove existing `~/.oh-my-zsh` if switching themes fails

### Manual Fixes

- **Reset shell config**: `rm -rf ~/.oh-my-zsh ~/.zsh && ./shell/setup.sh`
- **Homebrew PATH**: Add `/opt/homebrew/bin` to PATH on Apple Silicon Macs
- **Git user**: Update with `git config --global user.name "Your Name"`

## Contributing

1. Test changes locally before committing
2. Update documentation for new features
3. Use conventional commit format: `gm feat component "description"`
4. Ensure scripts work on fresh macOS installations

## License

Personal dotfiles - use at your own discretion.