#!/usr/bin/env bash
# ==============================================================================
# shell-ai: Claude Code Backend Adapter
# ==============================================================================

backend_claude_is_available() {
    command -v claude >/dev/null 2>&1
}

backend_claude_ask() {
    local prompt="$*"
    if ! backend_claude_is_available; then
        echo "Error: 'claude' CLI is not installed or not in PATH." >&2
        echo "Run: npm install -g @anthropic-ai/claude-code" >&2
        return 1
    fi
    claude -p "$prompt"
}

backend_claude_cmd() {
    local prompt="$*"
    if ! backend_claude_is_available; then
        echo "Error: 'claude' CLI is not installed or not in PATH." >&2
        return 1
    fi
    local instruction="Output ONLY the single, raw, executable Linux shell command to accomplish: $prompt.
Do NOT include markdown formatting, backticks, comments, or explanations.
Just the one-line command string."

    local output
    output=$(claude -p "$instruction" 2>/dev/null)
    
    echo "$output" | sed -E '/^```/d' | grep -v '^[[:space:]]*$' | head -n 1
}

backend_claude_fix() {
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
    backend_claude_ask "$prompt"
}

backend_claude_interactive() {
    if ! backend_claude_is_available; then
        echo "Error: 'claude' CLI is not installed or not in PATH." >&2
        return 1
    fi
    claude "$@"
}
