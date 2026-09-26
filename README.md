# 🐚 shell-ai

> **Seamless, model-agnostic AI integration right inside your terminal.**  
> Ask questions, auto-generate commands into your prompt with <kbd>Ctrl</kbd>+<kbd>G</kbd>, and diagnose errors—all without leaving your shell workflow.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Shell](https://img.shields.io/badge/Shell-Zsh%20%7C%20Bash-green.svg)](https://www.zsh.org)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](CONTRIBUTING.md)

---

## ⚡ What is `shell-ai`?

`shell-ai` turns your everyday terminal prompt into an AI-powered workspace. Instead of opening a browser or switching windows, you can query AI directly in your prompt. Once the response is delivered, **full terminal control is instantly handed back to you**.

Unlike single-vendor tools, `shell-ai` is **engine-agnostic**. It seamlessly adapts to whatever AI tool you already use:
- 🚀 **Google Antigravity (`agy`)**
- 🧠 **Anthropic Claude Code (`claude`)**
- 🦙 **Ollama (Local offline models: `qwen3-4b`, `llama3`, `mistral`)**
- 🐙 **GitHub Copilot CLI (`gh copilot`)**
- 🛠️ **Custom API / script adapters**

---

## 🤔 Why use `shell-ai` instead of raw CLIs?

While you *can* just type `claude "question"` or `agy "question"`, `shell-ai` is designed to completely eliminate workflow friction:

1. **No Quotes or Escaping:** Stop fighting bash syntax. Instead of `claude "how do I find files?"`, just type naturally: `@ai how do I find files?`
2. **Zero Copy-Pasting (<kbd>Ctrl</kbd>+<kbd>G</kbd>):** Instead of asking the AI for a command, copying it, and pasting it back, just type your goal and press <kbd>Ctrl</kbd>+<kbd>G</kbd>. Your prompt instantly transforms into the executable command.
3. **Auto-Context Error Fixing:** Command failed? Just type `@ai fix`. The plugin automatically pulls the exact failed command and exit code from your shell history and diagnoses it.
4. **Clean Terminal Markdown & Smooth Streaming:** Outputs are intercepted by a lightweight Python word-by-word streaming engine. It formats and colors basic Markdown on-the-fly and drops line buffering so it streams instantaneously with zero artificial latency.

---

## ✨ Features

### 1. Inline Quick Ask (`@ai`, `@agy`, `@claude`, `@ollama`)
Type `@ai <your question>` or `@agy <question>` or `@claude <question>` right into your command prompt and hit <kbd>Enter</kbd>. It streams the answer inline and returns immediately to a fresh prompt:

```bash
$ @ai how do I compress a folder with tar
# -> AI explains: tar -czvf archive.tar.gz /path/to/folder
$ █
```

### 2. Prompt-to-Command Buffer Replacement (<kbd>Ctrl</kbd>+<kbd>G</kbd>)
Type what you want to do in plain English, hit <kbd>Ctrl</kbd>+<kbd>G</kbd>, and `shell-ai` replaces your prompt buffer with the exact executable command. You can review, edit, or hit <kbd>Enter</kbd> to run it!

```bash
$ find all files modified in the last 24 hours [press Ctrl+G]
$ find . -type f -mtime -1█
```

### 3. Smart Error Diagnoser (`@ai fix`)
A command failed with an obscure error? Just type `@ai fix` (or `@fix`). `shell-ai` inspects the last failed command from your history and diagnoses the error with a recommended fix.

```bash
$ git push origin main
error: failed to push some refs to 'git@github.com:...
$ @ai fix
# -> Analyzes failure and suggests: git pull --rebase origin main && git push
```

### 4. Interactive Drop-In
Running `@ai`, `@agy`, or `@claude` without arguments instantly drops you into the provider's interactive conversational session.

### 5. Conversational Memory
By default, `shell-ai` temporarily remembers your last 3 interactions to maintain conversational context. You can bypass this globally in the config, or temporarily on a per-query basis by passing the `-nc` (no context) flag:
```bash
$ @ai -nc write a story
```

---

## 🚀 Installation

### Option 1: macOS / Linux (Homebrew)
```bash
brew tap ShashankIIITN/homebrew-tap
brew install shell-ai
```

### Option 2: Debian / Ubuntu (APT)
You can download the latest `.deb` package directly from the [Releases page](https://github.com/ShashankIIITN/shell-ai/releases) and install it:
```bash
sudo dpkg -i shell-ai_*_all.deb
sudo apt-get install -f # Install missing dependencies if any
```

### Option 3: Arch Linux (AUR)
```bash
yay -S shell-ai-git
```
*(Or use `paru` or `makepkg`)*

### Option 4: Quick Install Script (All platforms)
```bash
curl -fsSL https://raw.githubusercontent.com/ShashankIIITN/shell-ai/main/install.sh | bash
```
> **Note:** If run in a standard terminal (TTY), the installer will launch a quick interactive wizard allowing you to choose your default backend, local model, and preferred trigger prefix!

### Option 5: Zsh Plugin Managers
**Oh-My-Zsh:**
```bash
git clone https://github.com/ShashankIIITN/shell-ai.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/shell-ai
# Add `shell-ai` to your plugins list in ~/.zshrc: plugins=(... shell-ai)
```
**Zinit:**
```zsh
zinit light ShashankIIITN/shell-ai
```

### Option 6: Manual Shell Source
Clone the repository:
```bash
git clone https://github.com/ShashankIIITN/shell-ai.git ~/.shell-ai
```
For **Zsh**, add to `~/.zshrc`:
```zsh
source ~/.shell-ai/shell-ai.plugin.zsh
```
For **Bash**, add to `~/.bashrc`:
```bash
source ~/.shell-ai/shell-ai.bash
```
For **Fish**, add to `~/.config/fish/config.fish`:
```fish
source ~/.shell-ai/shell-ai.fish
```
---

## ⚙️ Configuration

`shell-ai` works out-of-the-box with zero configuration by auto-detecting your installed AI CLI, or via the interactive installer. 

To manually customize settings, edit `~/.config/shell-ai/config`:

```bash
# Set your default AI engine (agy | claude | ollama | copilot | custom)
export SHELL_AI_DEFAULT_BACKEND="ollama"

# Choose model for local Ollama
export SHELL_AI_OLLAMA_MODEL="qwen3-4b:latest"

# Customize prompt-to-command hotkey (default is Ctrl+G)
export SHELL_AI_KEYBIND="^G"

# Customize prompt prefix (recommended: @)
export SHELL_AI_PREFIX="@"

# Disable color formatting (0 = enabled, 1 = disabled)
export SHELL_AI_NO_COLOR="0"

# Disable conversational memory context globally (0 = enabled, 1 = disabled)
export SHELL_AI_NO_CONTEXT="0"
```

---

## 🛠️ CLI Usage

`shell-ai` also comes with a standalone CLI runner you can use anywhere:

```bash
# Ask questions
shell-ai ask "how to set static IP on Ubuntu"

# Disable memory for an isolated query
shell-ai -nc ask "summarize linux in one sentence"

# Output ONLY the raw executable command (useful in scripts)
shell-ai cmd "list all listening ports"

# Target a specific backend
shell-ai -b claude ask "write a python quicksort"
shell-ai -b ollama cmd "find docker containers using over 500mb"

# Check detected backends
shell-ai list-backends
```

---

## 🧩 Adding Custom Backends

Adding a new AI provider is as simple as dropping a script into `backends/<name>.sh`:

```bash
backend_myllm_is_available() {
    command -v myllm >/dev/null 2>&1
}

backend_myllm_ask() {
    myllm query "$*"
}

backend_myllm_cmd() {
    myllm query "Output ONLY raw shell command for: $*"
}
```

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request or open an Issue for bug reports and feature requests.

1. Fork the repo
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See [LICENSE](LICENSE) for more information.
