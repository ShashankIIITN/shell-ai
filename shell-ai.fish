# ==============================================================================
# shell-ai.fish - Fish Shell Integration for shell-ai
# ==============================================================================

# Add bin to PATH
set -l SHELL_AI_DIR (cd (dirname (status filename)) && pwd)
if not contains "$SHELL_AI_DIR/bin" $PATH
    set -gx PATH "$SHELL_AI_DIR/bin" $PATH
end

# Load user config (robust parsing of bash-style exports)
set -l USER_CONFIG_DIR "$HOME/.config/shell-ai"
if set -q XDG_CONFIG_HOME
    set USER_CONFIG_DIR "$XDG_CONFIG_HOME/shell-ai"
end

if test -f "$USER_CONFIG_DIR/config"
    while read -l line
        # Skip blank lines and comments
        set line (string trim -- "$line")
        test -z "$line"; and continue
        string match -q '#*' -- "$line"; and continue

        # Strip 'export ' prefix if present
        set line (string replace -r '^export\\s+' '' -- "$line")

        # Only process SHELL_AI_ variables for safety
        string match -q 'SHELL_AI_*' -- "$line"; or continue

        # Split on first '=' only (handles values containing '=')
        set -l arr (string split -m 1 '=' -- "$line")
        test (count $arr) -ge 2; or continue

        set -l k $arr[1]
        # Strip inline comments: remove unquoted # and everything after
        set -l v (string replace -r '\\s+#.*$' '' -- $arr[2])
        # Strip surrounding quotes (single or double)
        set v (string replace -r '^["\'](.*)["\']\$' '$1' -- "$v")

        set -gx $k $v
    end < "$USER_CONFIG_DIR/config"
end

# Configuration defaults
set -q SHELL_AI_KEYBIND; or set -gx SHELL_AI_KEYBIND "\cg"
set -q SHELL_AI_PREFIX; or set -gx SHELL_AI_PREFIX "%"

# 1. Ctrl+G magic generation
function _shell_ai_fish_suggest_cmd
    set -l buf (commandline)
    if test -z "$buf"
        return
    end
    
    commandline -r "⌛ [shell-ai generating command...]"
    commandline -f repaint
    
    set -l gen_cmd (shell-ai cmd "$buf" 2>/dev/null)
    if test -n "$gen_cmd"
        commandline -r "$gen_cmd"
    else
        commandline -r "$buf"
    end
end

bind $SHELL_AI_KEYBIND _shell_ai_fish_suggest_cmd

# 2. Wrapper Functions (using eval to support dynamic prefix)
function _shell_ai_create_wrappers
    set -l prefix $SHELL_AI_PREFIX
    
    # Eval is needed to define functions with dynamic names
    eval "function {$prefix}ai; shell-ai ask \$argv; end"
    eval "function {$prefix}fix; shell-ai fix \"\$status\" (history -n 1) \"\$argv\"; end"
    
    # Specific backends
    eval "function {$prefix}agy; BACKEND_OVERRIDE=agy shell-ai ask \$argv; end"
    eval "function {$prefix}claude; BACKEND_OVERRIDE=claude shell-ai ask \$argv; end"
    eval "function {$prefix}ollama; BACKEND_OVERRIDE=ollama shell-ai ask \$argv; end"
    eval "function {$prefix}copilot; BACKEND_OVERRIDE=copilot shell-ai ask \$argv; end"
    eval "function {$prefix}cmd; shell-ai cmd \$argv; end"
end

_shell_ai_create_wrappers
