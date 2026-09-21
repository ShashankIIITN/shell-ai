#!/usr/bin/env bash
# ==============================================================================
# shell-ai Uninstaller
# ==============================================================================
set -e

BIN_LINK="${HOME}/.local/bin/shell-ai"
OMZ_PLUGIN="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/shell-ai"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell-ai"

echo "Uninstalling shell-ai..."

# Remove binary symlink
if [ -L "$BIN_LINK" ] || [ -f "$BIN_LINK" ]; then
    rm -f "$BIN_LINK"
    echo "Removed $BIN_LINK"
fi

# Remove OMZ plugin symlink
if [ -L "$OMZ_PLUGIN" ]; then
    rm -f "$OMZ_PLUGIN"
    echo "Removed $OMZ_PLUGIN"
fi

# Clean ~/.zshrc (only remove installer-added lines, not user comments)
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/# shell-ai integration$/d; /shell-ai\.plugin\.zsh/d' "$HOME/.zshrc"
    echo "Cleaned shell-ai references from ~/.zshrc"
fi

# Clean ~/.bashrc
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/# shell-ai integration$/d; /shell-ai\.bash/d' "$HOME/.bashrc"
    echo "Cleaned shell-ai references from ~/.bashrc"
fi

# Clean config.fish
FISH_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
if [ -f "$FISH_CONF" ]; then
    sed -i '/# shell-ai integration$/d; /shell-ai\.fish/d' "$FISH_CONF"
    echo "Cleaned shell-ai references from $FISH_CONF"
fi

echo "Optional: If you want to delete your configuration, run: rm -rf $CONFIG_DIR"
echo "shell-ai uninstalled successfully."
