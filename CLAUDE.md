# CLAUDE.md - Project Context for AI Assistants

This file provides context for AI coding assistants working on this project.

## Project Overview

This repository contains setup guides and scripts for running open-source LLMs locally on a Mac Mini M4 (32GB RAM) for coding assistance, with seamless integration to enterprise cloud models via AWS Bedrock.

## System Specifications

- **Hardware**: Mac Mini M4, 32GB Unified Memory
- **OS**: macOS
- **Primary Use Case**: AI-powered coding assistance (local + cloud)

## Architecture

```
┌─────────────────────────────────────────┐
│           Coding Tools                   │
│  Aider | Continue | OpenCode | WebUI    │
└──────────────────┬──────────────────────┘
                   │
                   ▼
          ┌────────────────┐
          │    LiteLLM     │  ← Unified API (port 4000)
          └────────┬───────┘
                   │
      ┌────────────┼────────────┐
      ▼            ▼            ▼
┌──────────┐ ┌──────────┐ ┌──────────┐
│  Ollama  │ │ Bedrock  │ │  Other   │
│  (FREE)  │ │ (Claude) │ │ Providers│
└──────────┘ └──────────┘ └──────────┘
```

## Installed Components

### Ollama (Local Model Server)
- **Version**: 0.18.0+
- **API Endpoint**: http://localhost:11434
- **Config Location**: ~/.ollama/

### LiteLLM (Unified Proxy)
- **API Endpoint**: http://localhost:4000
- **Config Location**: ~/.litellm/config.yaml
- **Purpose**: Routes requests to Ollama or Bedrock

### AWS Bedrock (Enterprise)
- **Region**: us-west-2
- **Models**: Claude 3.5 Sonnet, Claude 3 Opus, Claude 3.5 Haiku

### Installed Models (Ollama - FREE)
- qwen2.5-coder:7b (fast)
- qwen2.5-coder:14b (balanced)
- qwen2.5-coder:32b (best quality)
- deepseek-coder-v2:16b (algorithms)
- codestral:22b (IDE/FIM)

### Tools
- **Aider**: CLI pair programming tool
- **OpenCode**: Alternative CLI assistant
- **Open WebUI**: Web interface for chat
- **Continue**: VS Code extension

## Directory Structure

```
local-llm-coding-setup/
├── README.md                    # Main documentation
├── CLAUDE.md                    # This file
├── scripts/
│   ├── setup.sh                 # Initial setup (Ollama + Aider)
│   ├── setup-litellm.sh         # LiteLLM proxy setup
│   ├── setup-opencode.sh        # OpenCode CLI setup
│   ├── pull-models.sh           # Download Ollama models
│   ├── start-litellm.sh         # Start LiteLLM proxy
│   ├── start-webui.sh           # Start Open WebUI
│   └── start-aider.sh           # Start Aider session
├── configs/
│   ├── litellm-config.yaml      # LiteLLM routing config
│   ├── continue-config.json     # VS Code Continue config
│   ├── aider-config.yml         # Aider configuration
│   └── ollama-modelfile-coding  # Custom model settings
└── docs/
    ├── litellm-bedrock-guide.md # LiteLLM + Bedrock guide
    ├── models-comparison.md     # Detailed model comparison
    └── troubleshooting.md       # Common issues and fixes
```

## Common Commands

```bash
# Start LiteLLM (unified API for all models)
./scripts/start-litellm.sh

# Use local model (FREE)
aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model qwen-coder

# Use Bedrock Claude (Enterprise)
aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model claude-sonnet

# Direct Ollama usage
ollama run qwen2.5-coder:14b

# Check what's running
ollama ps
curl http://localhost:4000/v1/models
```

## Model Recommendations by Task

| Task | Model | Cost | Rationale |
|------|-------|------|-----------|
| Quick questions | qwen-coder-fast | FREE | Fast local |
| Daily coding | qwen-coder | FREE | Good balance |
| Code review | qwen-coder | FREE | Sufficient |
| Complex refactoring | claude-sonnet | $$ | Best quality |
| Architecture design | claude-opus | $$$ | Most capable |
| Fast cloud tasks | claude-haiku | $ | Cheap & fast |

## LiteLLM Model Names

| LiteLLM Name | Backend | Description |
|--------------|---------|-------------|
| qwen-coder-fast | Ollama | 7B fast model |
| qwen-coder | Ollama | 14B balanced |
| qwen-coder-best | Ollama | 32B best local |
| deepseek-coder | Ollama | Algorithm focused |
| claude-sonnet | Bedrock | Claude 3.5 Sonnet |
| claude-opus | Bedrock | Claude 3 Opus |
| claude-haiku | Bedrock | Claude 3.5 Haiku |

## Environment Variables

Required in `~/.zshrc`:

```bash
# Ollama settings
export OLLAMA_API_BASE=http://localhost:11434
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=2
export OLLAMA_KEEP_ALIVE="5m"

# LiteLLM shortcuts
export OPENAI_API_BASE=http://localhost:4000
export OPENAI_API_KEY=sk-1234

# AWS (for Bedrock)
export AWS_DEFAULT_REGION=us-west-2
```

## Coding Conventions for Scripts

- Scripts use bash with `set -e` for error handling
- All paths should be absolute or use `$HOME`
- Include helpful echo statements for user feedback
- Check for dependencies before executing
- Use colors for status messages (GREEN=ok, YELLOW=warning, RED=error)

## Troubleshooting Checklist

1. Is Ollama running? (`curl http://localhost:11434`)
2. Is LiteLLM running? (`curl http://localhost:4000/health`)
3. Is the model loaded? (`ollama ps`)
4. AWS credentials configured? (`aws sts get-caller-identity`)
5. Bedrock access enabled? (Check AWS Console)
6. Enough memory available? (Check Activity Monitor)

## Related Projects

- [Ollama](https://github.com/ollama/ollama)
- [LiteLLM](https://github.com/BerriAI/litellm)
- [Aider](https://github.com/paul-gauthier/aider)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Continue](https://github.com/continuedev/continue)
- [AWS Bedrock](https://aws.amazon.com/bedrock/)
