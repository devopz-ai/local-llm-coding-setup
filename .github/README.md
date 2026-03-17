# DevOpz AI - Local LLM Coding Setup

Enterprise-grade local AI coding environment for Mac Mini M4.

## Overview

This repository provides a complete setup for running open-source LLMs locally for coding assistance, with seamless integration to enterprise cloud models (AWS Bedrock).

## Key Features

- **Free Local Models**: Qwen, DeepSeek, Codestral via Ollama
- **Enterprise Models**: AWS Bedrock (Claude 3.5 Sonnet, Opus, Haiku)
- **Unified API**: LiteLLM proxy for seamless model switching
- **Memory Management**: Persistent context across sessions with mem0
- **Multiple Interfaces**: CLI (Aider, OpenCode, Claude Code), Web UI, IDE extensions

## Quick Links

- [Full Documentation](../README.md)
- [Architecture Overview](../docs/architecture.md)
- [Setup Guide](../README.md#quick-start)
- [Troubleshooting](../docs/troubleshooting.md)

## Repository Structure

```
local-llm-coding-setup/
├── scripts/          # Setup and launch scripts
├── configs/          # Configuration files
├── docs/             # Documentation
└── .github/          # GitHub templates and workflows
```

## Getting Started

```bash
git clone https://github.com/devopz-ai/local-llm-coding-setup.git
cd local-llm-coding-setup
./scripts/setup.sh
./scripts/pull-models.sh
./scripts/start-aider.sh
```

## License

MIT License - See [LICENSE](../LICENSE) for details.

## Author

**Rashed Ahmed**
Email: rashed.ahmed@devopz.ai
GitHub: [@devopz-ai](https://github.com/devopz-ai)
