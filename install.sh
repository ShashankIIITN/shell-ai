#!/usr/bin/env bash
# ==============================================================================
# shell-ai Installer
# ==============================================================================
set -e

REPO_URL="https://github.com/ShashankIIITN/shell-ai.git"
INSTALL_DIR="${HOME}/.shell-ai"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell-ai"
BIN_DIR="${HOME}/.local/bin"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

echo -e "${BLUE}${BOLD}==> Installing shell-ai...${RESET}"

# 1. Determine source directory (local clone vs curl installer)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
if [ -f "$SCRIPT_DIR/bin/shell-ai" ]; then
    SOURCE_DIR="$SCRIPT_DIR"
else
    SOURCE_DIR="$INSTALL_DIR"
    if [ -d "$INSTALL_DIR" ]; then
        echo -e "${YELLOW}Existing installation found at $INSTALL_DIR. Updating...${RESET}"
        git -C "$INSTALL_DIR" pull --ff-only || true
    else
        echo -e "Cloning repository to $INSTALL_DIR..."
        git clone "$REPO_URL" "$INSTALL_DIR"
    fi
fi

# 2. Link binary into ~/.local/bin
mkdir -p "$BIN_DIR"
ln -sf "$SOURCE_DIR/bin/shell-ai" "$BIN_DIR/shell-ai"
chmod +x "$SOURCE_DIR/bin/shell-ai"
echo -e "${GREEN}✔${RESET} Linked executable to ${BOLD}$BIN_DIR/shell-ai${RESET}"

# 3. Initialize config if not existing
mkdir -p "$CONFIG_DIR"
if [ ! -f "$CONFIG_DIR/config" ]; then
    cp "$SOURCE_DIR/config.example" "$CONFIG_DIR/config"
    echo -e "${GREEN}✔${RESET} Created default config at ${BOLD}$CONFIG_DIR/config${RESET}"
else
    echo -e "${BLUE}ℹ${RESET} Config file already exists at $CONFIG_DIR/config"
fi

# 4. Configure Shell
CURRENT_SHELL="$(basename "${SHELL:-zsh}")"

# Check for Oh-My-Zsh
OMZ_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
if [ -d "$OMZ_CUSTOM/plugins" ]; then
    mkdir -p "$OMZ_CUSTOM/plugins"
    ln -sfn "$SOURCE_DIR" "$OMZ_CUSTOM/plugins/shell-ai"
    echo -e "${GREEN}✔${RESET} Registered as Oh-My-Zsh plugin: ${BOLD}shell-ai${RESET}"
    echo -e "${YELLOW}  👉 Add 'shell-ai' to your plugins list in ~/.zshrc:${RESET}"
    echo -e "     plugins=(... ${BOLD}shell-ai${RESET})"
elif [ "$CURRENT_SHELL" = "zsh" ] || [ -f "$HOME/.zshrc" ]; then
    SOURCE_LINE="[ -f \"$SOURCE_DIR/shell-ai.plugin.zsh\" ] && source \"$SOURCE_DIR/shell-ai.plugin.zsh\""
    if ! grep -q "shell-ai.plugin.zsh" "$HOME/.zshrc" 2>/dev/null; then
        echo "" >> "$HOME/.zshrc"
        echo "# shell-ai integration" >> "$HOME/.zshrc"
        echo "$SOURCE_LINE" >> "$HOME/.zshrc"
        echo -e "${GREEN}✔${RESET} Added plugin loader to ${BOLD}~/.zshrc${RESET}"
    else
        echo -e "${BLUE}ℹ${RESET} Plugin loader already present in ~/.zshrc"
    fi
elif [ "$CURRENT_SHELL" = "bash" ] || [ -f "$HOME/.bashrc" ]; then
    SOURCE_LINE="[ -f \"$SOURCE_DIR/shell-ai.bash\" ] && source \"$SOURCE_DIR/shell-ai.bash\""
    if ! grep -q "shell-ai.bash" "$HOME/.bashrc" 2>/dev/null; then
        echo "" >> "$HOME/.bashrc"
        echo "# shell-ai integration" >> "$HOME/.bashrc"
        echo "$SOURCE_LINE" >> "$HOME/.bashrc"
        echo -e "${GREEN}✔${RESET} Added plugin loader to ${BOLD}~/.bashrc${RESET}"
    else
        echo -e "${BLUE}ℹ${RESET} Plugin loader already present in ~/.bashrc"
    fi
fi

echo ""
echo -e "${GREEN}${BOLD}🚀 shell-ai installation complete!${RESET}"
echo ""
echo -e "${BOLD}Quick Usage:${RESET}"
echo -e "  • ${BOLD}%ai <prompt>${RESET}      - Ask any question right in your terminal"
echo -e "  • ${BOLD}%agy <prompt>${RESET}     - Ask Google Antigravity CLI"
echo -e "  • ${BOLD}%claude <prompt>${RESET}  - Ask Anthropic Claude Code"
echo -e "  • ${BOLD}%ollama <prompt>${RESET}  - Ask local offline Ollama models"
echo -e "  • ${BOLD}Ctrl + G${RESET}          - Type a question in your prompt and press Ctrl+G to get the command!"
echo -e "  • ${BOLD}%ai fix${RESET}           - Explain and fix the last failed command"
echo ""
echo -e "To activate now, restart your terminal or run:"
echo -e "  ${BOLD}source ~/.zshrc${RESET}  (or source ~/.bashrc)"
echo ""
