# Local LLM Coding Setup for Mac Mini M4 (32GB)

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![macOS](https://img.shields.io/badge/macOS-Apple%20Silicon-blue)](https://www.apple.com/mac-mini/)
[![Ollama](https://img.shields.io/badge/Ollama-0.18+-green)](https://ollama.com/)

A complete, production-ready setup for running open-source LLMs locally for AI-powered coding assistance on Apple Silicon, with seamless integration to enterprise cloud models (AWS Bedrock).

## Why This Setup?

| Benefit | Description |
|---------|-------------|
| **Free Local Models** | Run Qwen, DeepSeek, Codestral locally - no API costs |
| **Enterprise Ready** | Seamless integration with AWS Bedrock (Claude) |
| **Privacy First** | Code stays on your machine with local models |
| **Memory Persistence** | AI remembers your project context across sessions |
| **Unified Interface** | One API for all models via LiteLLM |

## Quick Start

### One-Command Setup (Recommended)

```bash
# Clone the repository
git clone https://github.com/devopz-ai/local-llm-coding-setup.git
cd local-llm-coding-setup

# Run the interactive master setup
./scripts/master-setup.sh
```

The master setup script will:
1. Check your system (macOS, RAM, dependencies)
2. Let you select which models to install
3. Let you choose tools (OpenCode, Aider, mem0)
4. Install and configure everything
5. Test and validate the setup
6. Show you how to use it

### Manual Setup (Advanced)

```bash
# Run individual setup scripts
./scripts/setup.sh           # Basic setup
./scripts/pull-models.sh     # Download models
./scripts/setup-litellm.sh   # Install LiteLLM
./scripts/setup-opencode.sh  # Install OpenCode
./scripts/setup-memory.sh    # Install mem0

# Start services
./scripts/start-litellm.sh
./scripts/start-aider.sh
```

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DEVELOPER TOOLS                                    │
│                                                                              │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌──────────┐  ┌─────────────┐ │
│  │  Aider   │  │ OpenCode │  │Claude Code │  │ Continue │  │  Open WebUI │ │
│  │  (CLI)   │  │  (CLI)   │  │   (CLI)    │  │(VS Code) │  │    (Web)    │ │
│  └────┬─────┘  └────┬─────┘  └─────┬──────┘  └────┬─────┘  └──────┬──────┘ │
│       │             │              │              │               │         │
│       └─────────────┴──────────────┴──────────────┴───────────────┘         │
│                                    │                                         │
└────────────────────────────────────┼─────────────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                         MEMORY LAYER (Optional)                             │
│                                                                             │
│    ┌─────────────────────────────────────────────────────────────────────┐ │
│    │                            mem0                                      │ │
│    │         Intelligent Memory for Persistent Context                    │ │
│    │                                                                      │ │
│    │   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐            │ │
│    │   │   SQLite    │    │  ChromaDB   │    │nomic-embed  │            │ │
│    │   │  (History)  │    │ (Vectors)   │    │(Embeddings) │            │ │
│    │   └─────────────┘    └─────────────┘    └─────────────┘            │ │
│    └─────────────────────────────────────────────────────────────────────┘ │
│                                                                             │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                            API GATEWAY                                      │
│                                                                             │
│                    ┌───────────────────────────────┐                       │
│                    │         LiteLLM Proxy         │                       │
│                    │      http://localhost:4000     │                       │
│                    │                               │                       │
│                    │  • OpenAI-compatible API      │                       │
│                    │  • Automatic model routing    │                       │
│                    │  • Fallback support           │                       │
│                    │  • Cost tracking              │                       │
│                    └───────────────┬───────────────┘                       │
│                                    │                                        │
└────────────────────────────────────┼────────────────────────────────────────┘
                                     │
                  ┌──────────────────┼──────────────────┐
                  │                  │                  │
                  ▼                  ▼                  ▼
┌─────────────────────┐  ┌─────────────────────┐  ┌─────────────────────┐
│   LOCAL (FREE)      │  │   AWS BEDROCK       │  │   OTHER PROVIDERS   │
│                     │  │                     │  │                     │
│   ┌─────────────┐   │  │   ┌─────────────┐   │  │   ┌─────────────┐   │
│   │   Ollama    │   │  │   │  Claude 3.5 │   │  │   │   OpenAI    │   │
│   │             │   │  │   │   Sonnet    │   │  │   │   Anthropic │   │
│   │ • Qwen 2.5  │   │  │   │   Opus      │   │  │   │   Groq      │   │
│   │ • DeepSeek  │   │  │   │   Haiku     │   │  │   │             │   │
│   │ • Codestral │   │  │   ├─────────────┤   │  │   └─────────────┘   │
│   │ • Llama 3   │   │  │   │  Llama 3.1  │   │  │                     │
│   └─────────────┘   │  │   │  Titan      │   │  │                     │
│                     │  │   └─────────────┘   │  │                     │
│   Cost: FREE        │  │   Cost: $$          │  │   Cost: $$$         │
│   Privacy: 100%     │  │   Privacy: AWS      │  │   Privacy: API      │
└─────────────────────┘  └─────────────────────┘  └─────────────────────┘
```

## Table of Contents

1. [Hardware Requirements](#hardware-requirements)
2. [Installation](#installation)
3. [Available Tools](#available-tools)
4. [Model Recommendations](#model-recommendations)
5. [LiteLLM Proxy Setup](#litellm-proxy-setup)
6. [AWS Bedrock Integration](#aws-bedrock-integration)
7. [Memory Management](#memory-management)
8. [CLI Tools](#cli-tools)
9. [IDE Integration](#ide-integration)
10. [Configuration Reference](#configuration-reference)
11. [Troubleshooting](#troubleshooting)

---

## Hardware Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| Chip | Apple M1 | Apple M4 |
| RAM | 16GB | 32GB+ |
| Storage | 50GB free | 100GB+ free |
| macOS | 13.0+ | 14.0+ |

### Model Size vs RAM

| RAM | Comfortable Models | Possible (Slower) |
|-----|-------------------|-------------------|
| 16GB | 7B models | 14B models |
| 32GB | 14B models | 32B models |
| 64GB | 32B models | 70B models |

---

## Installation

### Step 1: Prerequisites

```bash
# Install Homebrew (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Ollama
brew install ollama

# Start Ollama service
ollama serve
```

### Step 2: Clone and Setup

```bash
# Clone repository
git clone https://github.com/devopz-ai/local-llm-coding-setup.git
cd local-llm-coding-setup

# Run setup script
./scripts/setup.sh
```

### Step 3: Download Models

```bash
# Download recommended coding models
./scripts/pull-models.sh
```

### Step 4: Start Coding

```bash
# Option A: Quick start with Aider
./scripts/start-aider.sh

# Option B: Start LiteLLM for all tools
./scripts/start-litellm.sh
```

---

## Available Tools

| Tool | Type | Best For | Install |
|------|------|----------|---------|
| **Aider** | CLI | Pair programming, git integration | `pip install aider-chat` |
| **OpenCode** | CLI | Simple terminal coding | `brew install opencode` |
| **Claude Code** | CLI | Official Anthropic CLI | `brew install claude-code` |
| **Continue** | IDE | VS Code/Cursor integration | VS Code Extension |
| **Open WebUI** | Web | ChatGPT-like interface | Docker or pip |

### Tool Comparison

```
┌─────────────────────────────────────────────────────────────────┐
│                        TOOL COMPARISON                          │
├─────────────────┬──────────┬──────────┬────────────┬───────────┤
│ Feature         │  Aider   │ OpenCode │Claude Code │ Continue  │
├─────────────────┼──────────┼──────────┼────────────┼───────────┤
│ Interface       │ Terminal │ Terminal │  Terminal  │  VS Code  │
│ File Editing    │    ✓     │    ✓     │     ✓      │     ✓     │
│ Git Integration │  Strong  │   Good   │   Strong   │   Basic   │
│ Local Models    │  Native  │Via Proxy │ Via Proxy  │  Native   │
│ Bedrock Support │Via Proxy │Via Proxy │   Native   │ Via Proxy │
│ Memory/Context  │  Chat    │  Config  │  Built-in  │  Context  │
│ Learning Curve  │  Medium  │   Low    │    Low     │   Low     │
└─────────────────┴──────────┴──────────┴────────────┴───────────┘
```

---

## Model Recommendations

### For Coding on 32GB Mac

| Model | Size | Speed | Quality | Best For |
|-------|------|-------|---------|----------|
| `qwen2.5-coder:7b` | 4.5GB | Fast | Good | Quick tasks, autocomplete |
| `qwen2.5-coder:14b` | 9GB | Medium | Better | **Daily coding (recommended)** |
| `qwen2.5-coder:32b` | 20GB | Slow | Best | Complex refactoring |
| `deepseek-coder-v2:16b` | 10GB | Medium | Great | Algorithm design |
| `codestral:22b` | 13GB | Medium | Good | IDE integration |

### Pull Models

```bash
# Essential models
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b

# Additional models
ollama pull deepseek-coder-v2:16b
ollama pull codestral:22b
```

### Task-Based Recommendations

| Task | Local Model (FREE) | Cloud Model ($$) |
|------|-------------------|------------------|
| Quick questions | qwen-coder-fast | claude-haiku |
| Code completion | qwen-coder | claude-haiku |
| Code review | qwen-coder | claude-sonnet |
| Refactoring | qwen-coder-best | claude-sonnet |
| Architecture | qwen-coder-best | claude-opus |

---

## LiteLLM Proxy Setup

LiteLLM provides a unified OpenAI-compatible API for all models.

### Install and Start

```bash
# Install
./scripts/setup-litellm.sh

# Start proxy
./scripts/start-litellm.sh

# Verify
curl http://localhost:4000/v1/models
```

### Available Models via LiteLLM

| Model Name | Backend | Cost |
|------------|---------|------|
| `qwen-coder-fast` | Ollama | FREE |
| `qwen-coder` | Ollama | FREE |
| `qwen-coder-best` | Ollama | FREE |
| `deepseek-coder` | Ollama | FREE |
| `claude-sonnet` | Bedrock | $$ |
| `claude-opus` | Bedrock | $$$ |
| `claude-haiku` | Bedrock | $ |

### Usage Example

```bash
# Use local model (FREE)
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-1234" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-coder",
    "messages": [{"role": "user", "content": "Write a Python quicksort"}]
  }'
```

---

## AWS Bedrock Integration

### Setup AWS Credentials

```bash
# Install AWS CLI
brew install awscli

# Configure credentials
aws configure
# Enter: Access Key, Secret Key, Region (us-west-2)

# Verify
aws sts get-caller-identity
```

### Enable Model Access

1. Go to [AWS Bedrock Console](https://console.aws.amazon.com/bedrock/)
2. Navigate to **Model access**
3. Request access to Claude models
4. Wait for approval (usually instant)

### Use Bedrock Models

```bash
# Via LiteLLM
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-1234" \
  -d '{"model": "claude-sonnet", "messages": [{"role": "user", "content": "Hello"}]}'

# Via Aider
aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model claude-sonnet
```

---

## Memory Management

Keep conversation context across sessions using mem0.

### Setup

```bash
./scripts/setup-memory.sh
```

### Usage

```bash
# Add project context
mem add "This project uses FastAPI with PostgreSQL"
mem add "Authentication uses JWT tokens"

# Search memories
mem search "What database?"

# List all memories
mem list

# Use Aider with memory
aider-mem
```

### How It Works

```
Session 1                    Session 2
─────────                    ─────────
User: "Uses FastAPI"         User: "What framework?"
         │                            │
         ▼                            ▼
    ┌─────────┐                 ┌─────────┐
    │  mem0   │ ───────────────▶│  mem0   │
    │  SAVE   │    persisted    │ RECALL  │
    └─────────┘                 └─────────┘
                                      │
                                      ▼
                               AI: "FastAPI"
```

---

## CLI Tools

### Aider (Recommended)

```bash
# Direct Ollama
aider --model ollama/qwen2.5-coder:14b

# Via LiteLLM (all models)
aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model qwen-coder

# With Bedrock Claude
aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model claude-sonnet
```

**Aider Commands:**
```
/add <file>     Add file to context
/drop <file>    Remove file
/run <cmd>      Run shell command
/diff           Show changes
/commit         Commit changes
/undo           Undo last change
/help           Show all commands
```

### OpenCode

```bash
# Install
brew install opencode

# Start
opencode
```

### Claude Code

```bash
# Install
brew install claude-code

# Configure for Bedrock
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-west-2

# Start
claude
```

---

## IDE Integration

### VS Code - Continue Extension

1. Install Continue extension from VS Code marketplace
2. Configure `~/.continue/config.json`:

```json
{
  "models": [
    {
      "title": "Local Qwen (FREE)",
      "provider": "openai",
      "model": "qwen-coder",
      "apiBase": "http://localhost:4000",
      "apiKey": "sk-1234"
    },
    {
      "title": "Bedrock Claude",
      "provider": "openai",
      "model": "claude-sonnet",
      "apiBase": "http://localhost:4000",
      "apiKey": "sk-1234"
    }
  ],
  "tabAutocompleteModel": {
    "provider": "openai",
    "model": "qwen-coder-fast",
    "apiBase": "http://localhost:4000",
    "apiKey": "sk-1234"
  }
}
```

### Cursor IDE

1. Open Cursor Settings → Models
2. Add endpoint: `http://localhost:4000`
3. API Key: `sk-1234`
4. Select model

---

## Configuration Reference

### Environment Variables

Add to `~/.zshrc`:

```bash
# Ollama
export OLLAMA_API_BASE=http://localhost:11434
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=2
export OLLAMA_KEEP_ALIVE="5m"

# LiteLLM
export OPENAI_API_BASE=http://localhost:4000
export OPENAI_API_KEY=sk-1234

# AWS Bedrock
export AWS_DEFAULT_REGION=us-west-2
```

### Shell Aliases

```bash
# Aider shortcuts
alias aider-local="aider --model ollama/qwen2.5-coder:14b"
alias aider-fast="aider --model ollama/qwen2.5-coder:7b"
alias aider-claude="aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model claude-sonnet"

# OpenCode shortcuts
alias oc="opencode"
alias oc-fast="OPENCODE_MODEL=qwen-coder-fast opencode"

# Memory
alias mem="memory-helper.py"
alias aider-mem="aider-with-memory.sh"
```

### File Locations

| Config | Location |
|--------|----------|
| Ollama | `~/.ollama/` |
| LiteLLM | `~/.litellm/config.yaml` |
| mem0 | `~/.mem0/config.yaml` |
| Continue | `~/.continue/config.json` |
| Aider | `~/.aider.conf.yml` |
| AWS | `~/.aws/credentials` |

---

## Troubleshooting

### Ollama Issues

```bash
# Check if running
curl http://localhost:11434/

# Restart
pkill ollama && ollama serve

# Check loaded models
ollama ps

# View logs
tail -f ~/.ollama/logs/server.log
```

### LiteLLM Issues

```bash
# Check health
curl http://localhost:4000/health

# List models
curl http://localhost:4000/v1/models

# Restart
pkill -f litellm && ./scripts/start-litellm.sh
```

### Memory Issues

```bash
# Check memory usage
ollama ps

# Unload models
ollama stop qwen2.5-coder:32b

# Use smaller model
ollama run qwen2.5-coder:7b
```

### AWS Bedrock Issues

```bash
# Verify credentials
aws sts get-caller-identity

# Check model access
aws bedrock list-foundation-models --query "modelSummaries[?contains(modelId,'claude')]"
```

---

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](docs/architecture.md) | Detailed system architecture |
| [Models Comparison](docs/models-comparison.md) | In-depth model comparison |
| [LiteLLM + Bedrock](docs/litellm-bedrock-guide.md) | Enterprise integration guide |
| [OpenCode Guide](docs/opencode-local-llm-guide.md) | OpenCode setup and usage |
| [Claude Code Guide](docs/claude-code-cli-guide.md) | Claude Code CLI setup |
| [Memory Guide](docs/memory-management-guide.md) | Memory system documentation |
| [Troubleshooting](docs/troubleshooting.md) | Common issues and fixes |

---

## Project Structure

```
local-llm-coding-setup/
├── README.md                    # This file
├── CLAUDE.md                    # AI assistant context
├── LICENSE                      # MIT License
├── .github/
│   ├── ISSUE_TEMPLATE/          # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md # PR template
│   ├── CONTRIBUTING.md          # Contribution guidelines
│   └── workflows/               # CI/CD workflows
├── scripts/
│   ├── setup.sh                 # Initial setup
│   ├── setup-litellm.sh         # LiteLLM setup
│   ├── setup-opencode.sh        # OpenCode setup
│   ├── setup-memory.sh          # Memory setup
│   ├── pull-models.sh           # Model download
│   ├── start-litellm.sh         # Start LiteLLM
│   ├── start-webui.sh           # Start Open WebUI
│   └── start-aider.sh           # Start Aider
├── configs/
│   ├── litellm-config.yaml      # LiteLLM config
│   ├── mem0-config.yaml         # Memory config
│   ├── continue-config.json     # VS Code config
│   └── aider-config.yml         # Aider config
└── docs/
    ├── architecture.md          # System architecture
    ├── models-comparison.md     # Model details
    └── troubleshooting.md       # Troubleshooting
```

---

## Contributing

Contributions are welcome! Please read our [Contributing Guidelines](.github/CONTRIBUTING.md) first.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Author

**Rashed Ahmed**

- Email: rashed.ahmed@devopz.ai
- GitHub: [@devopz-ai](https://github.com/devopz-ai)

---

## Acknowledgments

- [Ollama](https://ollama.com/) - Local model serving
- [LiteLLM](https://github.com/BerriAI/litellm) - Unified LLM gateway
- [Aider](https://aider.chat/) - AI pair programming
- [mem0](https://mem0.ai/) - Memory layer for LLMs
- [Continue](https://continue.dev/) - VS Code AI extension
