# Local LLM Coding Setup for Mac Mini M4 (32GB)

A complete guide to setting up open-source LLMs for daily coding on Apple Silicon, with seamless integration between **free local models** and **enterprise cloud models** (AWS Bedrock).

## Hardware Specifications

- **Device**: Mac Mini M4
- **RAM**: 32GB Unified Memory
- **Recommended Models**: Up to 14B parameters (full speed), up to 32B (slower but usable)

## Quick Start

```bash
# 1. Run the setup script
./scripts/setup.sh

# 2. Pull recommended coding models
./scripts/pull-models.sh

# 3. Start the web UI
./scripts/start-webui.sh

# 4. For CLI coding assistant (like Claude Code)
./scripts/start-aider.sh
```

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                       Your Coding Tools                          │
│    Aider  │  OpenCode  │  Continue (VS Code)  │  Open WebUI     │
└─────────────────────────┬───────────────────────────────────────┘
                          │
                          ▼
                ┌───────────────────┐
                │     LiteLLM       │  ← Unified API Gateway
                │   (Port 4000)     │    OpenAI-compatible
                └─────────┬─────────┘
                          │
         ┌────────────────┼────────────────┐
         ▼                ▼                ▼
   ┌───────────┐   ┌────────────┐   ┌────────────┐
   │  Ollama   │   │    AWS     │   │   Other    │
   │  (FREE)   │   │  Bedrock   │   │  Providers │
   │           │   │            │   │            │
   │ • Qwen    │   │ • Claude   │   │ • OpenAI   │
   │ • DeepSeek│   │ • Llama    │   │ • Anthropic│
   │ • Codestrl│   │ • Titan    │   │            │
   └───────────┘   └────────────┘   └────────────┘
       LOCAL          ENTERPRISE        CLOUD
```

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Ollama Setup](#ollama-setup)
3. [Recommended Models](#recommended-models)
4. [LiteLLM Proxy](#litellm-proxy-unified-api) *(NEW)*
5. [AWS Bedrock Integration](#aws-bedrock-integration) *(NEW)*
6. [Web UI Options](#web-ui-options)
7. [CLI Coding Tools](#cli-coding-tools)
8. [IDE Integration](#ide-integration)
9. [Performance Tuning](#performance-tuning)
10. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### 1. Install Homebrew (if not installed)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 2. Install Ollama

```bash
# Download from official site (recommended)
# Visit: https://ollama.com/download/mac

# Or via Homebrew
brew install ollama
```

### 3. Verify Ollama Installation

```bash
ollama --version
# Should show: ollama version 0.x.x

# Start Ollama service (runs in background)
ollama serve
```

---

## Ollama Setup

### Starting Ollama

Ollama runs as a background service. You can start it in several ways:

```bash
# Option 1: Start manually (foreground)
ollama serve

# Option 2: Start via macOS app
# Just open the Ollama app from Applications

# Option 3: Check if already running
curl http://localhost:11434/api/tags
```

### Verify Ollama is Running

```bash
# Check status
curl http://localhost:11434/

# List installed models
ollama list
```

---

## Recommended Models

### For 32GB RAM Mac Mini M4

| Model | Size | Use Case | Command |
|-------|------|----------|---------|
| **qwen2.5-coder:7b** | ~4.5GB | Fast coding, daily use | `ollama pull qwen2.5-coder:7b` |
| **qwen2.5-coder:14b** | ~9GB | Better quality, still fast | `ollama pull qwen2.5-coder:14b` |
| **deepseek-coder-v2:16b** | ~10GB | Excellent for complex code | `ollama pull deepseek-coder-v2:16b` |
| **codestral:22b** | ~13GB | Mistral's coding model | `ollama pull codestral:22b` |
| **qwen2.5-coder:32b** | ~20GB | Best quality (slower) | `ollama pull qwen2.5-coder:32b` |

### Pull Recommended Models

```bash
# Essential (start with these)
ollama pull qwen2.5-coder:7b
ollama pull qwen2.5-coder:14b

# Additional (recommended)
ollama pull deepseek-coder-v2:16b
ollama pull codestral:22b

# For general chat/reasoning
ollama pull llama3.2:8b
ollama pull qwen2.5:14b
```

### Model Comparison

#### Qwen2.5-Coder (Recommended)
- **Strengths**: Excellent code completion, multi-language support, fast inference
- **Best for**: Daily coding, code review, refactoring
- **Languages**: Python, JavaScript, TypeScript, Go, Rust, Java, C++, and 90+ more

#### DeepSeek-Coder-V2
- **Strengths**: Strong reasoning, good at complex algorithms
- **Best for**: Algorithm design, debugging complex issues
- **Languages**: Especially good with Python and systems languages

#### Codestral
- **Strengths**: Fast, good at fill-in-the-middle completion
- **Best for**: IDE integration, autocomplete
- **Languages**: 80+ programming languages

### Test a Model

```bash
# Interactive chat
ollama run qwen2.5-coder:7b

# One-shot query
ollama run qwen2.5-coder:7b "Write a Python function to merge two sorted lists"

# Exit interactive mode
/bye
```

---

## LiteLLM Proxy (Unified API)

LiteLLM provides a unified OpenAI-compatible API that routes requests to multiple backends. This allows you to:

- **Switch seamlessly** between free local models and enterprise cloud models
- **Use any tool** that supports OpenAI API (most do!)
- **Add fallbacks** - if local model fails, fallback to cloud
- **Track costs** across all providers

### Install LiteLLM

```bash
# Run setup script
./scripts/setup-litellm.sh

# Or manually
pip install 'litellm[proxy]'
```

### Start LiteLLM Proxy

```bash
./scripts/start-litellm.sh

# Or manually
litellm --config ~/.litellm/config.yaml --port 4000
```

### Using LiteLLM

Once running, all tools can use the unified API:

```bash
# API endpoint
http://localhost:4000

# API key (any string works for local)
sk-1234
```

### Available Models via LiteLLM

| Model Name | Backend | Cost | Best For |
|------------|---------|------|----------|
| `qwen-coder-fast` | Ollama | FREE | Quick tasks |
| `qwen-coder` | Ollama | FREE | Daily coding |
| `qwen-coder-best` | Ollama | FREE | Best local quality |
| `deepseek-coder` | Ollama | FREE | Algorithms |
| `claude-sonnet` | Bedrock | $$ | Complex tasks |
| `claude-opus` | Bedrock | $$$ | Most capable |
| `claude-haiku` | Bedrock | $ | Fast & cheap |

### Example: Using with curl

```bash
# Use local model (FREE)
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-1234" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-coder",
    "messages": [{"role": "user", "content": "Write a Python hello world"}]
  }'

# Use Bedrock Claude (requires AWS credentials)
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-1234" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet",
    "messages": [{"role": "user", "content": "Write a Python hello world"}]
  }'
```

---

## AWS Bedrock Integration

AWS Bedrock provides enterprise-grade access to Claude, Llama, and other models with:
- **Security**: Your data stays in your AWS account
- **Compliance**: SOC2, HIPAA, etc.
- **No rate limits**: Based on your provisioned capacity
- **Cost control**: Pay per token, track via AWS billing

### Prerequisites

1. **AWS Account** with Bedrock access enabled
2. **Model Access**: Request access to models in AWS Console
3. **AWS CLI** configured with credentials

### Setup AWS CLI

```bash
# Install AWS CLI
brew install awscli

# Configure credentials
aws configure
# Enter: AWS Access Key ID, Secret Access Key, Region (us-west-2)

# Verify
aws sts get-caller-identity
```

### Enable Bedrock Model Access

1. Go to AWS Console > Bedrock > Model access
2. Request access to:
   - Anthropic Claude 3.5 Sonnet
   - Anthropic Claude 3 Opus
   - Anthropic Claude 3.5 Haiku
   - Meta Llama 3.1 (optional)
3. Wait for approval (usually instant for Claude)

### Available Bedrock Models

| Model | LiteLLM Name | Use Case |
|-------|--------------|----------|
| Claude 3.5 Sonnet | `claude-sonnet` | Best balance of speed/quality |
| Claude 3 Opus | `claude-opus` | Most capable, complex tasks |
| Claude 3.5 Haiku | `claude-haiku` | Fast, economical |
| Llama 3.1 70B | `bedrock-llama` | Open source alternative |
| Amazon Titan | `titan` | AWS native model |

### Using Bedrock with Aider

```bash
# Start LiteLLM first
./scripts/start-litellm.sh

# Then use Aider with Bedrock Claude
aider --openai-api-base http://localhost:4000 \
      --openai-api-key sk-1234 \
      --model claude-sonnet
```

### Cost Estimation (Bedrock)

| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|-------|----------------------|------------------------|
| Claude 3.5 Sonnet | $3.00 | $15.00 |
| Claude 3 Opus | $15.00 | $75.00 |
| Claude 3.5 Haiku | $0.80 | $4.00 |

*Tip: Use free local models for routine tasks, Bedrock for complex ones*

---

## Web UI Options

### Option 1: Open WebUI (Recommended)

The most popular and feature-rich web interface for Ollama.

#### Install via Docker

```bash
# Install Docker if not present
brew install --cask docker

# Start Docker Desktop, then run:
docker run -d -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  --restart always \
  ghcr.io/open-webui/open-webui:main
```

#### Access
- URL: http://localhost:3000
- Create an account on first visit (local only)
- Models auto-detected from Ollama

#### Install via pip (Alternative, no Docker)

```bash
pip install open-webui
open-webui serve
```

### Option 2: Ollama Web UI (Lightweight)

```bash
# Install
npm install -g ollama-webui-lite

# Run
ollama-webui-lite
```

### Option 3: Text Generation WebUI (Advanced)

For users who want maximum control:

```bash
# Clone repository
git clone https://github.com/oobabooga/text-generation-webui
cd text-generation-webui

# Run installer
./start_macos.sh
```

---

## CLI Coding Tools

### Aider - AI Pair Programming (Highly Recommended)

Aider is the closest experience to Claude Code for local LLMs.

#### Install Aider

```bash
# Via pip
pip install aider-chat

# Or via pipx (recommended for isolation)
brew install pipx
pipx install aider-chat
```

#### Configure for Ollama (Direct)

```bash
# Set environment variable
export OLLAMA_API_BASE=http://localhost:11434

# Run with Ollama model
aider --model ollama/qwen2.5-coder:14b
```

#### Configure for LiteLLM (Recommended - supports all models)

```bash
# Start LiteLLM first
./scripts/start-litellm.sh

# Use local model (FREE)
aider --openai-api-base http://localhost:4000 \
      --openai-api-key sk-1234 \
      --model qwen-coder

# Use Bedrock Claude (Enterprise)
aider --openai-api-base http://localhost:4000 \
      --openai-api-key sk-1234 \
      --model claude-sonnet
```

#### Create Aliases for Easy Access

Add to `~/.zshrc`:

```bash
# Aider with local LLM (direct Ollama)
alias aider-local="aider --model ollama/qwen2.5-coder:14b"
alias aider-fast="aider --model ollama/qwen2.5-coder:7b"

# Aider with LiteLLM (any model)
alias aider-lite="aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234"
alias aider-claude="aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model claude-sonnet"
```

#### Usage Examples

```bash
# Start in a project directory
cd /path/to/your/project
aider-local

# Add files to context
/add src/main.py src/utils.py

# Ask for changes
> Add error handling to the parse_config function

# Run tests
/run pytest

# Commit changes
/commit
```

### OpenCode - Alternative CLI Assistant

Another terminal-based AI coding assistant.

```bash
# Install
./scripts/setup-opencode.sh

# Use with LiteLLM
opencode
```

### llm CLI

```bash
# Install
pip install llm
llm install llm-ollama

# Use
llm -m qwen2.5-coder:7b "Explain this code: $(cat myfile.py)"
```

---

## IDE Integration

### VS Code - Continue Extension (Recommended)

Continue provides AI-powered coding assistance directly in VS Code.

#### Install

1. Open VS Code
2. Go to Extensions (Cmd+Shift+X)
3. Search for "Continue"
4. Install "Continue - Codestral, Claude, and more"

#### Configure for Ollama (Direct)

Create/edit `~/.continue/config.json`:

```json
{
  "models": [
    {
      "title": "Qwen2.5 Coder 14B",
      "provider": "ollama",
      "model": "qwen2.5-coder:14b",
      "apiBase": "http://localhost:11434"
    },
    {
      "title": "Qwen2.5 Coder 7B (Fast)",
      "provider": "ollama",
      "model": "qwen2.5-coder:7b",
      "apiBase": "http://localhost:11434"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Qwen2.5 Coder 7B",
    "provider": "ollama",
    "model": "qwen2.5-coder:7b"
  }
}
```

#### Configure for LiteLLM (All Models)

```json
{
  "models": [
    {
      "title": "Local - Qwen Coder",
      "provider": "openai",
      "model": "qwen-coder",
      "apiBase": "http://localhost:4000",
      "apiKey": "sk-1234"
    },
    {
      "title": "Bedrock - Claude Sonnet",
      "provider": "openai",
      "model": "claude-sonnet",
      "apiBase": "http://localhost:4000",
      "apiKey": "sk-1234"
    },
    {
      "title": "Bedrock - Claude Opus",
      "provider": "openai",
      "model": "claude-opus",
      "apiBase": "http://localhost:4000",
      "apiKey": "sk-1234"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Local Fast",
    "provider": "openai",
    "model": "qwen-coder-fast",
    "apiBase": "http://localhost:4000",
    "apiKey": "sk-1234"
  }
}
```

#### Usage

- **Chat**: Cmd+L to open chat panel
- **Autocomplete**: Tab to accept suggestions
- **Edit**: Cmd+I to edit selected code
- **Explain**: Select code, right-click, "Continue: Explain"

### Cursor IDE

Cursor has built-in support for Ollama:

1. Open Cursor Settings
2. Go to Models
3. Add Ollama endpoint: `http://localhost:11434`
4. Or add LiteLLM: `http://localhost:4000` with key `sk-1234`
5. Select your model

### Neovim/Vim

Use [avante.nvim](https://github.com/yetone/avante.nvim) or [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim):

```lua
-- Example with codecompanion.nvim
require("codecompanion").setup({
  adapters = {
    ollama = function()
      return require("codecompanion.adapters").extend("ollama", {
        schema = {
          model = { default = "qwen2.5-coder:14b" },
        },
      })
    end,
  },
})
```

---

## Performance Tuning

### Optimize Ollama for M4

Create `~/.ollama/config.json` (if it doesn't exist):

```json
{
  "gpu_layers": -1,
  "num_thread": 8,
  "num_ctx": 8192
}
```

### Environment Variables

Add to `~/.zshrc`:

```bash
# Ollama settings
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=2
export OLLAMA_KEEP_ALIVE="5m"

# For larger context windows (uses more memory)
export OLLAMA_NUM_CTX=8192
```

### Memory Management

```bash
# Check memory usage
ollama ps

# Unload models to free memory
ollama stop qwen2.5-coder:7b

# Set model to unload after idle time (in Modelfile)
# PARAMETER num_keep 0
```

### Model Performance Tips

| Scenario | Recommendation |
|----------|---------------|
| Quick questions | Use 7B models (FREE) |
| Complex refactoring | Use 14B+ or Claude (Bedrock) |
| Multiple models needed | Keep max 2 loaded |
| Long context needed | Increase `num_ctx` to 16384 |

---

## Troubleshooting

### Ollama Not Responding

```bash
# Check if running
pgrep ollama

# Restart Ollama
pkill ollama
ollama serve

# Check logs
tail -f ~/.ollama/logs/server.log
```

### Model Download Stuck

```bash
# Cancel and retry
# Press Ctrl+C, then:
ollama pull qwen2.5-coder:7b

# If corrupted, remove and re-pull
ollama rm qwen2.5-coder:7b
ollama pull qwen2.5-coder:7b
```

### Out of Memory

```bash
# Check what's loaded
ollama ps

# Stop unused models
ollama stop <model-name>

# Use smaller model
ollama run qwen2.5-coder:7b
```

### LiteLLM Issues

```bash
# Check if running
curl http://localhost:4000/health

# View logs
litellm --config ~/.litellm/config.yaml --port 4000 --debug

# Test model list
curl http://localhost:4000/v1/models
```

### Bedrock Connection Issues

```bash
# Verify AWS credentials
aws sts get-caller-identity

# Check Bedrock access
aws bedrock list-foundation-models --query "modelSummaries[?contains(modelId, 'claude')]"

# Ensure region is correct (us-west-2 recommended)
aws configure get region
```

### Slow Generation

1. Use smaller quantized model
2. Reduce context length
3. Close other memory-intensive apps
4. Check Activity Monitor for memory pressure

### Web UI Can't Connect to Ollama

```bash
# Ensure Ollama allows external connections
# For Docker, use host.docker.internal:11434

# Test connectivity
curl http://localhost:11434/api/tags
```

---

## Daily Workflow

### Recommended Daily Setup

1. **Morning**: Ensure Ollama is running (check menu bar or `ollama ps`)
2. **Start LiteLLM** for unified access: `./scripts/start-litellm.sh`
3. **For quick coding**: Use Aider with local model (FREE)
4. **For complex tasks**: Switch to Bedrock Claude
5. **For IDE work**: Use Continue in VS Code
6. **For exploration/learning**: Use Open WebUI

### Sample Workflow

```bash
# Start your day - start LiteLLM proxy
./scripts/start-litellm.sh &

# Quick question (FREE - local)
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-1234" \
  -d '{"model": "qwen-coder-fast", "messages": [{"role": "user", "content": "Quick: how to reverse a list in Python?"}]}'

# Coding session with local model (FREE)
aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model qwen-coder

# Complex refactoring with Claude (Bedrock)
aider --openai-api-base http://localhost:4000 --openai-api-key sk-1234 --model claude-sonnet

# In Aider:
/add src/search.py
> Refactor this to use async/await with proper error handling
/diff
/commit "Refactor search to async with error handling"
```

### Cost-Effective Strategy

| Task Type | Model | Cost |
|-----------|-------|------|
| Quick questions | qwen-coder-fast | FREE |
| Daily coding | qwen-coder | FREE |
| Code review | qwen-coder | FREE |
| Complex debugging | claude-haiku | $ |
| Major refactoring | claude-sonnet | $$ |
| Architecture design | claude-opus | $$$ |

---

## Additional Resources

- [Ollama Documentation](https://ollama.com/docs)
- [Ollama Model Library](https://ollama.com/library)
- [LiteLLM Documentation](https://docs.litellm.ai/)
- [AWS Bedrock Documentation](https://docs.aws.amazon.com/bedrock/)
- [Aider Documentation](https://aider.chat/)
- [Continue Documentation](https://docs.continue.dev/)
- [Open WebUI Documentation](https://docs.openwebui.com/)

---

## Contributing

Feel free to submit issues and enhancement requests!

## License

MIT License - Feel free to use and modify as needed.
