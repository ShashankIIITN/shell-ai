#!/bin/bash
HISTORY_FILE="/tmp/test-history.txt"
add_to_history() {
    local q="$1"
    local a="$2"
    {
        echo "Previous Query: $q"
        echo "Previous Answer:"
        echo "$a"
        echo "---"
    } >> "$HISTORY_FILE"
    
    # Keep only last 3 blocks
    awk 'BEGIN {RS="---\n"} {if (length($0) > 0) a[NR]=$0} END {for(i=NR-2; i<=NR; i++) if(i in a) printf "%s---\n", a[i]}' "$HISTORY_FILE" > "$HISTORY_FILE.tmp" && mv "$HISTORY_FILE.tmp" "$HISTORY_FILE"
}
add_to_history "Q1" "A1"
add_to_history "Q2" "A2"
add_to_history "Q3" "A3"
add_to_history "Q4" "A4"
cat "$HISTORY_FILE"
