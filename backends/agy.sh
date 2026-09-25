#!/usr/bin/env bash
# ==============================================================================
# shell-ai: Antigravity (agy) Backend Adapter
# ==============================================================================

backend_agy_is_available() {
    command -v agy >/dev/null 2>&1
}

backend_agy_ask() {
    local prompt="$*"
    if ! backend_agy_is_available; then
        echo "Error: 'agy' CLI is not installed or not in PATH." >&2
        echo "Visit https://antigravity.google/docs/cli for installation." >&2
        return 1
    fi
    agy -p "$prompt"
}

backend_agy_cmd() {
    local prompt="$*"
    if ! backend_agy_is_available; then
        echo "Error: 'agy' CLI is not installed or not in PATH." >&2
        return 1
    fi
    local instruction="Output ONLY the single, raw, executable Linux shell command to accomplish: $prompt.
Do NOT include markdown formatting, backticks, comments, or explanations.
Just the one-line command string."

    local output
    output=$(agy -p "$instruction" 2>/dev/null)
    
    # Strip markdown backticks if any were returned
    echo "$output" | sed -E '/^```/d' | grep -v '^[[:space:]]*$' | head -n 1
}

backend_agy_fix() {
    local last_cmd="$1"
    local exit_code="${2:-1}"
    local context="$3"
    
    local status_msg="failed with exit code ${exit_code}"
    [ "$exit_code" = "0" ] && status_msg="returned exit code 0 but produced an error or unexpected output"
    local prompt="The following shell command ${status_msg}:

\`\`\`bash
${last_cmd}
\`\`\`"
    if [ -n "$context" ]; then
        prompt="${prompt}
Terminal Context / Output:
\`\`\`
${context}
\`\`\`"
    fi
    prompt="${prompt}
Explain concisely what went wrong and provide the corrected command."
    backend_agy_ask "$prompt"
}

backend_agy_interactive() {
    if ! backend_agy_is_available; then
        echo "Error: 'agy' CLI is not installed or not in PATH." >&2
        return 1
    fi
    agy "$@"
}
