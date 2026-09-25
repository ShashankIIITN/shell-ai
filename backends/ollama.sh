#!/usr/bin/env bash
# ==============================================================================
# shell-ai: Ollama (Local Offline Models) Backend Adapter
# ==============================================================================

backend_ollama_is_available() {
    command -v ollama >/dev/null 2>&1
}

backend_ollama_get_model() {
    if [ -n "$SHELL_AI_OLLAMA_MODEL" ]; then
        echo "$SHELL_AI_OLLAMA_MODEL"
        return
    fi
    # Cache the model list to avoid multiple ollama subprocess calls
    local model_list
    model_list=$(ollama list 2>/dev/null)
    if echo "$model_list" | grep -q "qwen2.5-coder"; then
        echo "qwen2.5-coder"
    elif echo "$model_list" | grep -q "llama3"; then
        echo "llama3"
    elif echo "$model_list" | grep -q "mistral"; then
        echo "mistral"
    else
        echo "llama3"
    fi
}

backend_ollama_ask() {
    local prompt="$*"
    if ! backend_ollama_is_available; then
        echo "Error: 'ollama' CLI is not installed or not in PATH." >&2
        echo "Visit https://ollama.com to download and install." >&2
        return 1
    fi
    local model
    model=$(backend_ollama_get_model)
    ollama run "$model" "$prompt"
}

backend_ollama_cmd() {
    local prompt="$*"
    if ! backend_ollama_is_available; then
        echo "Error: 'ollama' CLI is not installed or not in PATH." >&2
        return 1
    fi
    local model
    model=$(backend_ollama_get_model)
    local instruction="System: You are a Linux shell command generator. Output ONLY the raw executable Linux command. No explanations, no markdown backticks.
Task: $prompt"

    local output
    output=$(ollama run "$model" "$instruction" 2>/dev/null)
    
    echo "$output" | sed -E '/^```/d' | grep -v '^[[:space:]]*$' | head -n 1
}

backend_ollama_fix() {
    local last_cmd="$1"
    local exit_code="${2:-1}"
    local context="$3"
    
    local status_msg="failed with exit code ${exit_code}"
    [ "$exit_code" = "0" ] && status_msg="returned exit code 0 but produced an error or unexpected output"
    local prompt="The following Linux shell command ${status_msg}:

\`\`\`bash
${last_cmd}
\`\`\`"
    if [ -n "$context" ]; then
        prompt="${prompt}
Terminal Context:
\`\`\`
${context}
\`\`\`"
    fi
    prompt="${prompt}
Explain briefly why it failed and give the corrected command."
    backend_ollama_ask "$prompt"
}

backend_ollama_interactive() {
    if ! backend_ollama_is_available; then
        echo "Error: 'ollama' CLI is not installed or not in PATH." >&2
        return 1
    fi
    local model
    model=$(backend_ollama_get_model)
    ollama run "$model"
}
