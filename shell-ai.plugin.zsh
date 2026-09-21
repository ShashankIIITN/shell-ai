# ==============================================================================
# shell-ai.plugin.zsh - Zsh Plugin for Seamless Terminal AI Integration
# Compatible with: Oh-My-Zsh, Zinit, Antigen, Sheldon, and manual sourcing.
# ==============================================================================

# Ensure 0-indexed or 1-indexed safety and preserve standard zsh options
0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${terminfo[sgr0]:+$0}"
SHELL_AI_PLUGIN_DIR="${0:A:h}"

# Add shell-ai bin directory to PATH if not already present
if [[ ":$PATH:" != *":${SHELL_AI_PLUGIN_DIR}/bin:"* ]]; then
    export PATH="${SHELL_AI_PLUGIN_DIR}/bin:$PATH"
fi

# Load optional user config
USER_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/shell-ai"
if [[ -f "$USER_CONFIG_DIR/config" ]]; then
    source "$USER_CONFIG_DIR/config"
fi

# Configuration defaults
: ${SHELL_AI_KEYBIND:="^G"}
: ${SHELL_AI_PREFIX:="%"}

# ------------------------------------------------------------------------------
# 1. ZLE Widget: Ctrl+G (Prompt-to-Command Buffer Replacement)
# ------------------------------------------------------------------------------
_shell_ai_suggest_cmd() {
    local original_buffer="$BUFFER"
    [[ -z "$original_buffer" ]] && return

    # Temporary visual indicator
    BUFFER="⌛ [shell-ai generating command...]"
    zle -R

    local gen_cmd
    gen_cmd="$(shell-ai cmd "$original_buffer" 2>/dev/null)"

    if [[ -n "$gen_cmd" ]]; then
        BUFFER="$gen_cmd"
        CURSOR=${#BUFFER}
    else
        BUFFER="$original_buffer"
    fi
    zle redisplay
}
zle -N _shell_ai_suggest_cmd
bindkey "$SHELL_AI_KEYBIND" _shell_ai_suggest_cmd

# ------------------------------------------------------------------------------
# 2. ZLE Widget: Intercept '%ai', '%agy', '%claude', etc. on Enter
# ------------------------------------------------------------------------------
_shell_ai_accept_line() {
    local trimmed="${BUFFER#"${BUFFER%%[![:space:]]*}"}" # strip leading spaces

    # Check for Error Fix trigger: '%ai fix' or '%fix'
    if [[ "$trimmed" == "${SHELL_AI_PREFIX}ai fix"* ]] || [[ "$trimmed" == "${SHELL_AI_PREFIX}fix"* ]]; then
        local last_status="$?"
        local last_cmd="$(fc -ln -1 2>/dev/null | sed -e 's/^[[:space:]]*//')"
        print -s "$BUFFER" # Save to history
        BUFFER=" shell-ai fix \"$last_status\" ${(q)last_cmd}"
        zle .accept-line
        return
    fi

    # Check for Provider-Specific Prefix: %agy, %claude, %ollama, %copilot, %custom
    for backend in agy claude ollama copilot custom; do
        if [[ "$trimmed" == "${SHELL_AI_PREFIX}${backend}" ]] || [[ "$trimmed" == "${SHELL_AI_PREFIX}${backend} "* ]]; then
            local query="${trimmed#"${SHELL_AI_PREFIX}${backend}"}"
            query="${query#"${query%%[![:space:]]*}"}" # strip leading space

            print -s "$BUFFER"
            if [[ -z "$query" ]]; then
                BUFFER=" shell-ai interactive \"$backend\""
            else
                local -a args
                args=("${(@Q)${(z)query}}")
                local -a qargs
                for a in "${args[@]}"; do qargs+=("${(q)a}"); done
                BUFFER=" BACKEND_OVERRIDE=\"$backend\" shell-ai ${qargs[@]}"
            fi
            zle .accept-line
            return
        fi
    done

    # Check for Default Prefix: %ai <query> or ?? <query>
    if [[ "$trimmed" == "${SHELL_AI_PREFIX}ai"* ]] || [[ "$trimmed" == "??"* ]]; then
        local query=""
        if [[ "$trimmed" == "${SHELL_AI_PREFIX}ai"* ]]; then
            query="${trimmed#"${SHELL_AI_PREFIX}ai"}"
        else
            query="${trimmed#"??"}"
        fi
        query="${query#"${query%%[![:space:]]*}"}"

        print -s "$BUFFER"
        if [[ -z "$query" ]]; then
            BUFFER=" shell-ai interactive"
        else
            local -a args
            args=("${(@Q)${(z)query}}")
            local -a qargs
            for a in "${args[@]}"; do qargs+=("${(q)a}"); done
            BUFFER=" shell-ai ${qargs[@]}"
        fi
        zle .accept-line
        return
    fi

    # Pass through to normal shell execution
    zle .accept-line
}
zle -N accept-line _shell_ai_accept_line

# ------------------------------------------------------------------------------
# 3. Convenience Shell Functions & Aliases
# ------------------------------------------------------------------------------
ai() {
    if [[ $# -eq 0 ]]; then
        shell-ai interactive
    else
        shell-ai ask "$*"
    fi
}

fix-last() {
    local last_status="$?"
    local last_cmd="$(fc -ln -1 2>/dev/null | sed -e 's/^[[:space:]]*//')"
    shell-ai fix "$last_status" "$last_cmd"
}
