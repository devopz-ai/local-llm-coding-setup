# CLAUDE.md - Project Context for AI Assistants

This file provides context for AI coding assistants working on this project.

## Project Overview

This repository contains setup guides and scripts for running open-source LLMs locally on a Mac Mini M4 (32GB RAM) for coding assistance.

## System Specifications

- **Hardware**: Mac Mini M4, 32GB Unified Memory
- **OS**: macOS
- **Primary Use Case**: Local AI-powered coding assistance

## Installed Components

### Ollama (Model Server)
- **Version**: 0.18.0+
- **API Endpoint**: http://localhost:11434
- **Config Location**: ~/.ollama/

### Installed Models
- qwen2.5-coder:7b (primary, fast)
- qwen2.5-coder:14b (better quality)
- Additional models as needed

### Tools
- **Aider**: CLI pair programming tool
- **Open WebUI**: Web interface for chat
- **Continue**: VS Code extension

## Directory Structure

```
local-llm-coding-setup/
├── README.md              # Main documentation
├── CLAUDE.md              # This file
├── scripts/
│   ├── setup.sh           # Initial setup script
│   ├── pull-models.sh     # Download recommended models
│   ├── start-webui.sh     # Start Open WebUI
│   └── start-aider.sh     # Start Aider session
├── configs/
│   ├── continue-config.json    # VS Code Continue config
│   ├── aider-config.yml        # Aider configuration
│   └── ollama-modelfile        # Custom model settings
└── docs/
    ├── models-comparison.md    # Detailed model comparison
    └── troubleshooting.md      # Common issues and fixes
```

## Common Commands

```bash
# Check Ollama status
ollama ps
ollama list

# Run model interactively
ollama run qwen2.5-coder:14b

# Start Aider for coding
aider --model ollama/qwen2.5-coder:14b

# Start Open WebUI (Docker)
docker start open-webui
```

## Model Recommendations by Task

| Task | Model | Rationale |
|------|-------|-----------|
| Quick questions | qwen2.5-coder:7b | Fast response |
| Code review | qwen2.5-coder:14b | Better understanding |
| Complex refactoring | qwen2.5-coder:32b | Best quality |
| Algorithm design | deepseek-coder-v2:16b | Strong reasoning |

## Performance Notes

- **Context Window**: Default 4096, can increase to 8192-16384
- **Parallel Requests**: Set OLLAMA_NUM_PARALLEL=2 for multi-request handling
- **Memory**: Keep max 2 models loaded simultaneously
- **GPU Acceleration**: Fully utilized via Metal on M4

## Environment Variables

Required in `~/.zshrc`:

```bash
export OLLAMA_API_BASE=http://localhost:11434
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=2
export OLLAMA_KEEP_ALIVE="5m"
```

## Coding Conventions for Scripts

- Scripts use bash with `set -e` for error handling
- All paths should be absolute or use `$HOME`
- Include helpful echo statements for user feedback
- Check for dependencies before executing

## Troubleshooting Checklist

1. Is Ollama running? (`pgrep ollama`)
2. Is the API accessible? (`curl http://localhost:11434`)
3. Is the model loaded? (`ollama ps`)
4. Enough memory available? (Check Activity Monitor)

## Related Projects

- [Ollama](https://github.com/ollama/ollama)
- [Aider](https://github.com/paul-gauthier/aider)
- [Open WebUI](https://github.com/open-webui/open-webui)
- [Continue](https://github.com/continuedev/continue)
