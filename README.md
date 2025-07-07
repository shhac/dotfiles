# Dotfiles

Personal dotfiles for cross-platform development environment setup with git, shell, and vim configurations.

## Quick Start

### Local Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/shhac/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Make setup scripts executable
chmod +x setup.sh */setup.sh

# Run complete setup
./setup.sh
```

### Remote Setup (Legacy)

```bash
# macOS complete setup
sh -c "$(curl -fsSL https://raw.github.com/shhac/dotfiles/master/setup.sh)"
```

## Supported Platforms

### macOS
Complete development environment with Homebrew, modern CLI tools, and system preferences.

### WSL2 (Windows Subsystem for Linux)
Modern Windows development using Ubuntu on WSL2 with Docker, modern CLI tools, and Windows interoperability.

### Cygwin (Legacy)
Basic setup for legacy Windows environments. **Deprecated - use WSL2 instead.**

## What Gets Configured

- **Git**: Aliases, user settings, push/pull configuration, diff tools
- **Shell**: Oh My Zsh with custom theme, plugins, and configuration files
- **Vim**: Basic vim configuration with syntax highlighting and sensible defaults
- **Platform-specific**: System preferences, package management, development tools

### Tools Installed

#### macOS
- **Development**: git, tig, diff-so-fancy, doppler, graphite
- **Utilities**: thefuck, tealdeer, pwgen
- **GUI Apps**: Visual Studio Code, iTerm2, Fira Code font
- **Node.js**: via NVM with latest LTS

#### WSL2
- **Development**: git, docker, node.js, python3
- **Modern CLI**: exa, bat, fd, ripgrep, delta
- **Integration**: Windows interoperability, X11 forwarding
- **Package Management**: apt packages, Docker containers

## Individual Component Setup

You can run individual setup scripts for specific components:

```bash
# Make specific scripts executable if needed
chmod +x git/setup.sh shell/setup.sh vim/setup.sh mac/setup.sh

# Git configuration only
./git/setup.sh

# Shell configuration only  
./shell/setup.sh

# Vim configuration only
./vim/setup.sh

# macOS full setup (includes all components)
./mac/setup.sh

# WSL2 full setup (includes all components)
./wsl2/setup.sh
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
├── wsl2/                  # WSL2-specific setup
│   ├── setup.sh
│   ├── wsl-interop.sh     # Windows interoperability
│   ├── x11-setup.sh       # GUI application support
│   ├── wsl2-aliases.sh    # WSL2-specific aliases
│   └── README.md          # WSL2 documentation
└── CLAUDE.md             # Claude Code guidance
```

## Requirements

### macOS
- **macOS**: 10.15+ (for macOS setup)
- **Git**: For cloning and git configuration
- **curl**: For downloading dependencies

### WSL2
- **Windows**: 10 version 2004+ or Windows 11
- **WSL2**: Enabled with Ubuntu distribution
- **Internet connection**: For package downloads

### All Platforms
- **Git**: For cloning repository
- **curl**: For downloading dependencies

## Troubleshooting

### Common Issues

1. **Permission errors**: Make scripts executable with `chmod +x setup.sh */setup.sh`
2. **"Command not found" errors**: Run `chmod +x` on the specific script you're trying to execute
3. **Homebrew path issues**: Restart terminal after Homebrew installation
4. **Oh My Zsh conflicts**: Remove existing `~/.oh-my-zsh` if switching themes fails

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