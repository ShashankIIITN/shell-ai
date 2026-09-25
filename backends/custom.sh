#!/usr/bin/env bash
# ==============================================================================
# shell-ai: Custom Script / API Backend Adapter
# ==============================================================================
# Configure via:
#   export SHELL_AI_CUSTOM_ASK_CMD="my_ai_script --query"
#   export SHELL_AI_CUSTOM_CMD_CMD="my_ai_script --generate"
# NOTE: The command string is word-split (like a shell command) but the prompt
# is always passed as a single safe argument — no shell injection possible.

backend_custom_is_available() {
    [ -n "$SHELL_AI_CUSTOM_ASK_CMD" ] || [ -n "$SHELL_AI_CUSTOM_CMD_CMD" ]
}

# Split a config command string into an array safely (word-split only on the
# command/flags, not on the user-supplied prompt argument).
_backend_custom_run() {
    local cmd_str="$1"
    local prompt="$2"
    # Read the command string into an array via eval-safe word-splitting
    local -a cmd_arr
    IFS=' ' read -r -a cmd_arr <<< "$cmd_str"
    "${cmd_arr[@]}" "$prompt"
}

backend_custom_ask() {
    local prompt="$*"
    if [ -z "$SHELL_AI_CUSTOM_ASK_CMD" ]; then
        echo "Error: SHELL_AI_CUSTOM_ASK_CMD is not configured in your environment or ~/.config/shell-ai/config" >&2
        return 1
    fi
    _backend_custom_run "$SHELL_AI_CUSTOM_ASK_CMD" "$prompt"
}

backend_custom_cmd() {
    local prompt="$*"
    if [ -z "$SHELL_AI_CUSTOM_CMD_CMD" ]; then
        if [ -n "$SHELL_AI_CUSTOM_ASK_CMD" ]; then
            _backend_custom_run "$SHELL_AI_CUSTOM_ASK_CMD" "Output ONLY executable command for: $prompt" \
                | sed -E '/^```/d' | grep -v '^[[:space:]]*$' | head -n 1
            return $?
        fi
        echo "Error: SHELL_AI_CUSTOM_CMD_CMD is not configured." >&2
        return 1
    fi
    _backend_custom_run "$SHELL_AI_CUSTOM_CMD_CMD" "$prompt"
}

backend_custom_fix() {
    local last_cmd="$1"
    local exit_code="${2:-1}"
    backend_custom_ask "Command '$last_cmd' failed with exit code $exit_code. Suggest a fix."
}

backend_custom_interactive() {
    if [ -n "$SHELL_AI_CUSTOM_INTERACTIVE_CMD" ]; then
        # Interactive commands may legitimately need shell features; document clearly
        # shellcheck disable=SC2086
        $SHELL_AI_CUSTOM_INTERACTIVE_CMD
    else
        echo "No interactive command configured for custom backend." >&2
    fi
}
