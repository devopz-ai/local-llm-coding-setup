# CLAUDE.md - Project Context for AI Assistants

This file provides context for AI coding assistants working on this project.

## Project Overview

This repository provides a complete setup for running open-source LLMs locally on a Mac Mini M4 (32GB RAM) for AI-powered coding assistance, with seamless integration to enterprise cloud models via AWS Bedrock and persistent memory across sessions.

## System Architecture

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DEVELOPER TOOLS                                    │
│                                                                              │
│  ┌──────────┐  ┌──────────┐  ┌────────────┐  ┌──────────┐  ┌─────────────┐ │
│  │  Aider   │  │ OpenCode │  │Claude Code │  │ Continue │  │  Open WebUI │ │
│  │  (CLI)   │  │  (CLI)   │  │   (CLI)    │  │(VS Code) │  │    (Web)    │ │
│  └────┬─────┘  └────┬─────┘  └─────┬──────┘  └────┬─────┘  └──────┬──────┘ │
│       └─────────────┴──────────────┴──────────────┴───────────────┘         │
│                                    │                                         │
└────────────────────────────────────┼─────────────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                         MEMORY LAYER (mem0)                                 │
│                                                                             │
│   ┌─────────────┐    ┌─────────────┐    ┌─────────────┐                   │
│   │   SQLite    │    │  ChromaDB   │    │nomic-embed  │                   │
│   │  (History)  │    │ (Vectors)   │    │(Embeddings) │                   │
│   └─────────────┘    └─────────────┘    └─────────────┘                   │
│                                                                             │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     │
                                     ▼
┌────────────────────────────────────────────────────────────────────────────┐
│                     LiteLLM Proxy (localhost:4000)                          │
│                         OpenAI-Compatible API                               │
└────────────────────────────────────┬────────────────────────────────────────┘
                                     │
                  ┌──────────────────┼──────────────────┐
                  ▼                  ▼                  ▼
         ┌───────────────┐  ┌───────────────┐  ┌───────────────┐
         │    Ollama     │  │  AWS Bedrock  │  │    Other      │
         │    (FREE)     │  │   (Claude)    │  │   Providers   │
         │               │  │               │  │               │
         │ • Qwen 2.5    │  │ • Sonnet      │  │ • OpenAI      │
         │ • DeepSeek    │  │ • Opus        │  │ • Anthropic   │
         │ • Codestral   │  │ • Haiku       │  │ • Groq        │
         └───────────────┘  └───────────────┘  └───────────────┘
```

## System Specifications

- **Hardware**: Mac Mini M4, 32GB Unified Memory
- **OS**: macOS
- **Primary Use Case**: AI-powered coding assistance (local + cloud)

## Installed Components

### Model Serving
| Component | Endpoint | Purpose |
|-----------|----------|---------|
| Ollama | localhost:11434 | Local model server |
| LiteLLM | localhost:4000 | Unified API gateway |
| AWS Bedrock | us-west-2 | Enterprise Claude models |

### Memory Management
| Component | Purpose |
|-----------|---------|
| mem0 | Intelligent memory layer |
| ChromaDB | Vector database |
| nomic-embed-text | Local embeddings |

### Developer Tools
| Tool | Type | Primary Use |
|------|------|-------------|
| Aider | CLI | Pair programming |
| OpenCode | CLI | Terminal coding |
| Claude Code | CLI | Anthropic official |
| Continue | IDE | VS Code extension |
| Open WebUI | Web | Chat interface |

### Available Models

**Local (FREE via Ollama):**
- qwen2.5-coder:7b (fast)
- qwen2.5-coder:14b (balanced)
- qwen2.5-coder:32b (best quality)
- deepseek-coder-v2:16b (algorithms)
- codestral:22b (IDE/FIM)

**Enterprise (AWS Bedrock):**
- claude-sonnet (Claude 3.5 Sonnet)
- claude-opus (Claude 3 Opus)
- claude-haiku (Claude 3.5 Haiku)

## Directory Structure

```
local-llm-coding-setup/
├── README.md                    # Main documentation
├── CLAUDE.md                    # This file (AI context)
├── LICENSE                      # MIT License
├── .github/
│   ├── README.md                # GitHub profile README
│   ├── ISSUE_TEMPLATE/          # Issue templates
│   ├── PULL_REQUEST_TEMPLATE.md # PR template
│   ├── CONTRIBUTING.md          # Contribution guidelines
│   └── FUNDING.yml              # Funding info
├── scripts/
│   ├── setup.sh                 # Initial setup (Ollama + Aider)
│   ├── setup-litellm.sh         # LiteLLM proxy setup
│   ├── setup-opencode.sh        # OpenCode CLI setup
│   ├── setup-memory.sh          # Memory management setup
│   ├── pull-models.sh           # Download Ollama models
│   ├── start-litellm.sh         # Start LiteLLM proxy
│   ├── start-webui.sh           # Start Open WebUI
│   ├── start-aider.sh           # Start Aider session
│   ├── memory-helper.py         # Memory CLI tool
│   └── aider-with-memory.sh     # Aider with memory context
├── configs/
│   ├── litellm-config.yaml      # LiteLLM routing config
│   ├── mem0-config.yaml         # Memory management config
│   ├── continue-config.json     # VS Code Continue config
│   ├── aider-config.yml         # Aider configuration
│   └── ollama-modelfile-coding  # Custom model settings
└── docs/
    ├── architecture.md          # Detailed architecture
    ├── claude-code-cli-guide.md # Claude Code setup
    ├── opencode-local-llm-guide.md # OpenCode guide
    ├── memory-management-guide.md  # Memory system docs
    ├── litellm-bedrock-guide.md # LiteLLM + Bedrock
    ├── models-comparison.md     # Model comparison
    └── troubleshooting.md       # Troubleshooting guide
```

## Common Commands

```bash
# Start all services
./scripts/start-litellm.sh       # Start unified API

# Coding with local models (FREE)
aider --model ollama/qwen2.5-coder:14b
aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model qwen-coder

# Coding with Bedrock (Enterprise)
aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model claude-sonnet

# Memory commands
mem add "Project uses FastAPI"    # Add memory
mem search "framework"            # Search memories
mem list                          # List all memories
aider-mem                         # Aider with memory context

# Model management
ollama ps                         # Check loaded models
ollama list                       # List installed models
curl http://localhost:4000/v1/models  # List LiteLLM models
```

## Model Selection Guide

| Task | Model | Cost | Why |
|------|-------|------|-----|
| Quick questions | qwen-coder-fast | FREE | Fast response |
| Daily coding | qwen-coder | FREE | Good balance |
| Code review | qwen-coder | FREE | Sufficient quality |
| Complex refactoring | claude-sonnet | $$ | Best quality |
| Architecture design | claude-opus | $$$ | Most capable |
| Fast cloud tasks | claude-haiku | $ | Cheap & fast |

## Environment Variables

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

## Coding Conventions for Scripts

- Use `#!/bin/bash` with `set -e` for error handling
- Use absolute paths or `$HOME`
- Include color-coded status messages
- Check dependencies before executing
- Document usage in script header

## Troubleshooting Quick Reference

| Issue | Check | Fix |
|-------|-------|-----|
| Ollama not responding | `curl localhost:11434` | `pkill ollama && ollama serve` |
| LiteLLM not responding | `curl localhost:4000/health` | Restart with `start-litellm.sh` |
| Model not found | `ollama list` | `ollama pull <model>` |
| AWS auth failed | `aws sts get-caller-identity` | `aws configure` |
| Out of memory | `ollama ps` | `ollama stop <large-model>` |

## Related Projects

- [Ollama](https://github.com/ollama/ollama) - Local model serving
- [LiteLLM](https://github.com/BerriAI/litellm) - Unified LLM gateway
- [mem0](https://github.com/mem0ai/mem0) - Memory layer
- [Aider](https://github.com/paul-gauthier/aider) - AI pair programming
- [OpenCode](https://github.com/opencode-ai/opencode) - Terminal coding
- [Continue](https://github.com/continuedev/continue) - VS Code extension
- [Open WebUI](https://github.com/open-webui/open-webui) - Chat interface
- [AWS Bedrock](https://aws.amazon.com/bedrock/) - Enterprise LLMs

## Author

**Rashed Ahmed**
- Email: rashed.ahmed@devopz.ai
- GitHub: [@devopz-ai](https://github.com/devopz-ai)
