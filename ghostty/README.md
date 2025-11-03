# Ghostty Terminal Configuration

This directory contains configuration for [Ghostty](https://ghostty.org), a fast, feature-rich terminal emulator.

## Features

- **Custom keybindings**: Shift-Enter for newline
- **Theme**: Catppuccin Mocha (customizable)
- **Font**: Fira Code with ligature support

## Installation

### Install Ghostty

**macOS:**
```bash
brew install ghostty
```

**Other platforms:**
Visit [ghostty.org](https://ghostty.org) for installation instructions.

### Apply Configuration

Run the setup script:
```bash
./ghostty/setup.sh
```

Or as part of the main dotfiles setup:
```bash
./setup.sh
```

## Configuration File

The configuration is stored at `~/.config/ghostty/config` (or `$XDG_CONFIG_HOME/ghostty/config`).

### Current Settings

- **Keybinding**: `shift+enter` - Insert newline character
- **Theme**: Catppuccin Mocha
- **Font**: Fira Code

## Customization

Edit `ghostty/config` in this repository, then run:
```bash
./ghostty/setup.sh
```

To see all available options:
```bash
ghostty +show-config --default --docs
```

Or visit the [Ghostty documentation](https://ghostty.org/docs/config).

## Available Themes

The config includes commented-out alternatives:
- Github-Dark-Default
- Ayu Mirage
- Catppuccin Mocha (active)

To change themes, edit the `theme` line in `ghostty/config`.
