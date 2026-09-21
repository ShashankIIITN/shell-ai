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

# Clean ~/.zshrc
if [ -f "$HOME/.zshrc" ]; then
    sed -i '/shell-ai/d' "$HOME/.zshrc"
    echo "Cleaned shell-ai references from ~/.zshrc"
fi

# Clean ~/.bashrc
if [ -f "$HOME/.bashrc" ]; then
    sed -i '/shell-ai/d' "$HOME/.bashrc"
    echo "Cleaned shell-ai references from ~/.bashrc"
fi

echo "Optional: If you want to delete your configuration, run: rm -rf $CONFIG_DIR"
echo "shell-ai uninstalled successfully."
