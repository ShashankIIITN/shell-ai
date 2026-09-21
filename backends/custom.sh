#!/usr/bin/env bash
# ==============================================================================
# shell-ai: Custom Script / API Backend Adapter
# ==============================================================================
# Configure via:
#   export SHELL_AI_CUSTOM_ASK_CMD="my_ai_script --query"
#   export SHELL_AI_CUSTOM_CMD_CMD="my_ai_script --generate"

backend_custom_is_available() {
    [ -n "$SHELL_AI_CUSTOM_ASK_CMD" ] || [ -n "$SHELL_AI_CUSTOM_CMD_CMD" ]
}

backend_custom_ask() {
    local prompt="$*"
    if [ -z "$SHELL_AI_CUSTOM_ASK_CMD" ]; then
        echo "Error: SHELL_AI_CUSTOM_ASK_CMD is not configured in your environment or ~/.config/shell-ai/config" >&2
        return 1
    fi
    eval "$SHELL_AI_CUSTOM_ASK_CMD \"\$prompt\""
}

backend_custom_cmd() {
    # shellcheck disable=SC2034
    local prompt="$*"
    if [ -z "$SHELL_AI_CUSTOM_CMD_CMD" ]; then
        if [ -n "$SHELL_AI_CUSTOM_ASK_CMD" ]; then
            eval "$SHELL_AI_CUSTOM_ASK_CMD \"Output ONLY executable command for: \$prompt\"" | sed -E '/^```/d' | grep -v '^[[:space:]]*$' | head -n 1
            return $?
        fi
        echo "Error: SHELL_AI_CUSTOM_CMD_CMD is not configured." >&2
        return 1
    fi
    eval "$SHELL_AI_CUSTOM_CMD_CMD \"\$prompt\""
}

backend_custom_fix() {
    local last_cmd="$1"
    local exit_code="${2:-1}"
    backend_custom_ask "Command '$last_cmd' failed with exit code $exit_code. Suggest a fix."
}

backend_custom_interactive() {
    if [ -n "$SHELL_AI_CUSTOM_INTERACTIVE_CMD" ]; then
        eval "$SHELL_AI_CUSTOM_INTERACTIVE_CMD"
    else
        echo "No interactive command configured for custom backend." >&2
    fi
}
