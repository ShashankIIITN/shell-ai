#!/usr/bin/env bash
# ==============================================================================
# shell-ai: GitHub Copilot CLI Backend Adapter
# ==============================================================================

backend_copilot_is_available() {
    command -v gh >/dev/null 2>&1 && gh extension list 2>/dev/null | grep -q "gh-copilot"
}

backend_copilot_ask() {
    local prompt="$*"
    if ! command -v gh >/dev/null 2>&1; then
        echo "Error: GitHub CLI ('gh') is not installed." >&2
        return 1
    fi
    gh copilot explain "$prompt"
}

backend_copilot_cmd() {
    local prompt="$*"
    if ! command -v gh >/dev/null 2>&1; then
        echo "Error: GitHub CLI ('gh') is not installed." >&2
        return 1
    fi
    gh copilot suggest -t shell "$prompt"
}

backend_copilot_fix() {
    local last_cmd="$1"
    backend_copilot_ask "Why did this command fail: $last_cmd"
}

backend_copilot_interactive() {
    gh copilot
}
