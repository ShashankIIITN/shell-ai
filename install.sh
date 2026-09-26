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
if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh}" ] || [ -d "$HOME/.oh-my-zsh" ]; then
    mkdir -p "$OMZ_CUSTOM/plugins"
    ln -sfn "$SOURCE_DIR" "$OMZ_CUSTOM/plugins/shell-ai"
    echo -e "${GREEN}✔${RESET} Registered as Oh-My-Zsh plugin: ${BOLD}shell-ai${RESET}"
    echo -e "${YELLOW}  👉 Add 'shell-ai' to your plugins list in ~/.zshrc:${RESET}"
    echo -e "     plugins=(... ${BOLD}shell-ai${RESET})"
elif [ "$CURRENT_SHELL" = "zsh" ] || [ -f "$HOME/.zshrc" ]; then
    SOURCE_LINE="[ -f \"$SOURCE_DIR/shell-ai.plugin.zsh\" ] && source \"$SOURCE_DIR/shell-ai.plugin.zsh\""
    if ! grep -q "shell-ai.plugin.zsh" "$HOME/.zshrc" 2>/dev/null; then
        {
            echo ""
            echo "# shell-ai integration"
            echo "$SOURCE_LINE"
        } >> "$HOME/.zshrc"
        echo -e "${GREEN}✔${RESET} Added plugin loader to ${BOLD}~/.zshrc${RESET}"
    else
        echo -e "${BLUE}ℹ${RESET} Plugin loader already present in ~/.zshrc"
    fi
elif [ "$CURRENT_SHELL" = "bash" ] || [ -f "$HOME/.bashrc" ]; then
    SOURCE_LINE="[ -f \"$SOURCE_DIR/shell-ai.bash\" ] && source \"$SOURCE_DIR/shell-ai.bash\""
    if ! grep -q "shell-ai.bash" "$HOME/.bashrc" 2>/dev/null; then
        {
            echo ""
            echo "# shell-ai integration"
            echo "$SOURCE_LINE"
        } >> "$HOME/.bashrc"
        echo -e "${GREEN}✔${RESET} Added plugin loader to ${BOLD}~/.bashrc${RESET}"
    else
        echo -e "${BLUE}ℹ${RESET} Plugin loader already present in ~/.bashrc"
    fi
fi

if [ "$CURRENT_SHELL" = "fish" ] || [ -d "$HOME/.config/fish" ]; then
    FISH_CONF="${XDG_CONFIG_HOME:-$HOME/.config}/fish/config.fish"
    mkdir -p "$(dirname "$FISH_CONF")"
    SOURCE_LINE="test -f \"$SOURCE_DIR/shell-ai.fish\"; and source \"$SOURCE_DIR/shell-ai.fish\""
    if ! grep -q "shell-ai.fish" "$FISH_CONF" 2>/dev/null; then
        {
            echo ""
            echo "# shell-ai integration"
            echo "$SOURCE_LINE"
        } >> "$FISH_CONF"
        echo -e "${GREEN}✔${RESET} Added plugin loader to ${BOLD}$FISH_CONF${RESET}"
    else
        echo -e "${BLUE}ℹ${RESET} Plugin loader already present in $FISH_CONF"
    fi
fi

# 5. Interactive Configuration Setup
# Because curl | bash consumes stdin, we must check for and read directly from /dev/tty
if [ -c /dev/tty ] && [ -f "$CONFIG_DIR/config" ]; then
    echo ""
    echo -e "${YELLOW}${BOLD}==> Interactive Setup${RESET}"
    read -r -p "Would you like to configure shell-ai now? [Y/n]: " do_setup < /dev/tty
    if [[ ! "$do_setup" =~ ^[Nn] ]]; then
        # Default backend
        echo ""
        echo -e "Select your default AI backend:"
        echo -e "  1) ollama  (Local, free)"
        echo -e "  2) agy     (Google Antigravity)"
        echo -e "  3) claude  (Anthropic)"
        echo -e "  4) copilot (GitHub CLI)"
        read -r -p "Choice [1]: " b_choice < /dev/tty
        case "$b_choice" in
            2) sel_backend="agy" ;;
            3) sel_backend="claude" ;;
            4) sel_backend="copilot" ;;
            *) sel_backend="ollama" ;;
        esac
        sed -i "s/^export SHELL_AI_DEFAULT_BACKEND=.*/export SHELL_AI_DEFAULT_BACKEND=\"$sel_backend\"/" "$CONFIG_DIR/config"
        
        # If ollama, prompt for model
        if [ "$sel_backend" = "ollama" ]; then
            read -r -p "Ollama model [qwen3-4b:latest]: " o_model < /dev/tty
            o_model="${o_model:-qwen3-4b:latest}"
            sed -i "s/^export SHELL_AI_OLLAMA_MODEL=.*/export SHELL_AI_OLLAMA_MODEL=\"$o_model\"/" "$CONFIG_DIR/config"
        fi

        # Prefix
        echo ""
        echo -e "Select your preferred terminal prefix trigger:"
        echo -e "  1) @   (Recommended, e.g. @ai, @ollama)"
        echo -e "  2) ,   (e.g. ,ai, ,ollama)"
        echo -e "  3) %   (e.g. %ai - Note: clunky in non-interactive scripts)"
        echo -e "  4) ??  (e.g. ?? write a story)"
        read -r -p "Choice [1]: " p_choice < /dev/tty
        case "$p_choice" in
            2) sel_prefix="," ;;
            3) sel_prefix="%" ;;
            4) sel_prefix="??" ;;
            *) sel_prefix="@" ;;
        esac
        sed -i "s/^export SHELL_AI_PREFIX=.*/export SHELL_AI_PREFIX=\"$sel_prefix\"/" "$CONFIG_DIR/config"

        echo -e "${GREEN}✔${RESET} Configuration saved to ${BOLD}$CONFIG_DIR/config${RESET}"
    fi
fi

# Determine display prefix for quick usage instructions
disp_prefix="$(grep '^export SHELL_AI_PREFIX=' "$CONFIG_DIR/config" | cut -d'"' -f2 || echo "@")"
if [ "$disp_prefix" = "??" ]; then
    disp_prefix="??"
fi

echo ""
echo -e "${GREEN}${BOLD}🚀 shell-ai installation complete!${RESET}"
echo ""
echo -e "${BOLD}Quick Usage:${RESET}"
echo -e "  • ${BOLD}${disp_prefix}ai <prompt>${RESET}      - Ask any question right in your terminal"
if [ "$disp_prefix" != "??" ]; then
    echo -e "  • ${BOLD}${disp_prefix}agy <prompt>${RESET}     - Ask Google Antigravity CLI"
    echo -e "  • ${BOLD}${disp_prefix}claude <prompt>${RESET}  - Ask Anthropic Claude Code"
    echo -e "  • ${BOLD}${disp_prefix}ollama <prompt>${RESET}  - Ask local offline Ollama models"
fi
echo -e "  • ${BOLD}Ctrl + G${RESET}          - Type a question in your prompt and press Ctrl+G to get the command!"
echo -e "  • ${BOLD}${disp_prefix}ai fix${RESET}           - Explain and fix the last failed command"
echo ""
echo -e "To activate now, restart your terminal or run:"
echo -e "  ${BOLD}source ~/.zshrc${RESET}  (or source ~/.bashrc)"
echo ""
