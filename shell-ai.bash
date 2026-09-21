#!/usr/bin/env bash
# ==============================================================================
# shell-ai.bash - Bash Integration for shell-ai
# Source this file in your ~/.bashrc
# ==============================================================================

SHELL_AI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Add bin to PATH
if [[ ":$PATH:" != *":${SHELL_AI_DIR}/bin:"* ]]; then
    export PATH="${SHELL_AI_DIR}/bin:$PATH"
fi

# Load user config
USER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell-ai"
if [[ -f "$USER_CONFIG_DIR/config" ]]; then
    source "$USER_CONFIG_DIR/config"
fi

# Prompt-to-Command Keybinding (Ctrl+G in Bash Readline)
_shell_ai_bash_suggest_cmd() {
    [[ -z "$READLINE_LINE" ]] && return
    local gen_cmd
    gen_cmd="$(shell-ai cmd "$READLINE_LINE" 2>/dev/null)"
    if [[ -n "$gen_cmd" ]]; then
        READLINE_LINE="$gen_cmd"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

# Bind Ctrl+G in Bash
bind -x '"\C-g": _shell_ai_bash_suggest_cmd'

# Wrapper Functions
ai() {
    if [[ $# -eq 0 ]]; then
        shell-ai interactive
    else
        shell-ai ask "$*"
    fi
}

fix-last() {
    local last_status="$?"
    local last_cmd
    last_cmd="$(HISTTIMEFORMAT= history 1 | sed -e 's/^[ ]*[0-9]*[ ]*//')"
    shell-ai fix "$last_status" "$last_cmd"
}
