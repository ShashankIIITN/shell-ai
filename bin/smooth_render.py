#!/usr/bin/env python3
import sys
import re

BOLD = "\033[1m"; RESET = "\033[0m"; DIM = "\033[2m"
BLUE = "\033[1;34m"; CYAN = "\033[1;36m"; YELLOW = "\033[1;33m"; GREEN = "\033[32m"

def render_word(word, in_code):
    if in_code:
        return word
    
    # Check if the word itself has full bold or code markers
    # It won't match across spaces, but it's okay for live streaming
    w = re.sub(r'\*\*(.*?)\*\*', f'{BOLD}\\1{RESET}', word)
    w = re.sub(r'`(.*?)`', f'{CYAN}\\1{RESET}', w)
    return w

def main():
    word_buf = ""
    line_start = True
    in_code = False

    while True:
        char = sys.stdin.read(1)
        if not char:
            sys.stdout.write(render_word(word_buf, in_code))
            break

        word_buf += char

        # Flush on word boundaries
        if char in (' ', '\n', '\t'):
            if line_start:
                # Handle Headers
                if word_buf == '# ':
                    sys.stdout.write(f"\n{BLUE}{BOLD}■ ")
                    word_buf = ""
                    line_start = False
                    continue
                elif word_buf == '## ':
                    sys.stdout.write(f"\n{CYAN}{BOLD}▸ ")
                    word_buf = ""
                    line_start = False
                    continue
                elif word_buf == '### ':
                    sys.stdout.write(f"\n{YELLOW}{BOLD}▪ ")
                    word_buf = ""
                    line_start = False
                    continue
            
            # Handle Code Blocks
            if word_buf.strip() == '```' or word_buf.strip().startswith('```'):
                in_code = not in_code
                if in_code:
                    sys.stdout.write(f"{DIM}  ╭────────────────────────────────────{RESET}\n{GREEN}  │ ")
                else:
                    sys.stdout.write(f"{RESET}\n{DIM}  ╰────────────────────────────────────{RESET}\n")
                word_buf = ""
                line_start = (char == '\n')
                continue

            # Handle normal word
            sys.stdout.write(render_word(word_buf, in_code))
            if char == '\n':
                if in_code:
                    sys.stdout.write(f"{GREEN}  │ ")
                line_start = True
            else:
                line_start = False
            
            sys.stdout.flush()
            word_buf = ""

if __name__ == "__main__":
    main()
