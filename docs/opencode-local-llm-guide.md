# Using OpenCode with Local LLMs

OpenCode is an AI coding agent built for the terminal, similar to Claude Code. This guide shows how to use it with free local models via Ollama and LiteLLM.

## What is OpenCode?

OpenCode is a terminal-based AI coding assistant that:
- Works directly in your terminal
- Understands your codebase context
- Can read, write, and edit files
- Runs shell commands
- Integrates with git
- Supports multiple LLM providers

## Installation

### Option 1: Homebrew (Recommended)

```bash
brew install opencode
```

### Option 2: npm

```bash
npm install -g @opencode-ai/cli
```

### Option 3: From Source

```bash
git clone https://github.com/opencode-ai/opencode
cd opencode
npm install
npm run build
npm link
```

### Verify Installation

```bash
opencode --version
opencode --help
```

## Configuration for Local LLMs

OpenCode requires a configuration file to define custom providers like LiteLLM or direct Ollama access.

### Method 1: opencode.json Config (Recommended)

Create the configuration file at `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "litellm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LiteLLM (Local)",
      "options": {
        "baseURL": "http://localhost:4000/v1",
        "apiKey": "{env:LITELLM_API_KEY}"
      },
      "models": {
        "qwen-coder-fast": {
          "name": "Qwen 2.5 Coder 7B (FREE)",
          "limit": { "context": 32768, "output": 8192 }
        },
        "qwen-coder": {
          "name": "Qwen 2.5 Coder 14B (FREE)",
          "limit": { "context": 32768, "output": 8192 }
        },
        "claude-sonnet": {
          "name": "Claude 3.5 Sonnet (Bedrock)",
          "limit": { "context": 200000, "output": 8192 }
        }
      }
    },
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (Direct)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen2.5-coder:7b": {
          "name": "Qwen 2.5 Coder 7B",
          "limit": { "context": 32768, "output": 8192 }
        }
      }
    }
  }
}
```

Then set the API key environment variable in `~/.zshrc`:
```bash
export LITELLM_API_KEY=sk-litellm-master-key-change-me
```

### Method 2: Running OpenCode with Local Models

Once configured, run OpenCode with the `-m` flag:

```bash
# Via LiteLLM proxy (recommended)
opencode -m litellm/qwen-coder-fast

# Direct Ollama access
opencode -m ollama/qwen2.5-coder:7b

# Using Bedrock through LiteLLM
opencode -m litellm/claude-sonnet
```

### Method 3: Shell Aliases (Convenience)

Add these aliases to `~/.zshrc`:

```bash
# OpenCode with local models
alias oc="opencode -m litellm/qwen-coder-fast"
alias oc-fast="opencode -m litellm/qwen-coder-fast"
alias oc-ollama="opencode -m ollama/qwen2.5-coder:7b"
alias oc-claude="opencode -m litellm/claude-sonnet"
```

### Verifying Configuration

Check available models after configuration:

```bash
# List LiteLLM models
opencode models litellm

# List Ollama models
opencode models ollama
```

## Available Local Models

When using LiteLLM, these models are available:

| Model Name | Description | Speed | Quality |
|------------|-------------|-------|---------|
| `qwen-coder-fast` | Qwen 7B | Fast | Good |
| `qwen-coder` | Qwen 14B | Medium | Better |
| `qwen-coder-best` | Qwen 32B | Slow | Best |
| `deepseek-coder` | DeepSeek 16B | Medium | Great for algorithms |
| `codestral` | Mistral 22B | Medium | Good FIM support |

When using Ollama directly:

| Model Name | Description |
|------------|-------------|
| `qwen2.5-coder:7b` | Fast, daily use |
| `qwen2.5-coder:14b` | Balanced |
| `qwen2.5-coder:32b` | Best quality |
| `deepseek-coder-v2:16b` | Algorithm focused |
| `codestral:22b` | IDE/completion focused |

## Quick Start

### 1. Ensure Ollama is Running

```bash
# Check if running
curl http://localhost:11434/

# If not, start it
ollama serve
```

### 2. Start OpenCode

```bash
# Navigate to your project
cd /path/to/your/project

# Start OpenCode
opencode
```

### 3. Basic Usage

Once in OpenCode:

```
# Ask a question
> How does the authentication system work in this codebase?

# Request code changes
> Add input validation to the user registration function

# Run a command
> Run the test suite and fix any failures

# Review changes
> Review the changes I made today and suggest improvements
```

## Usage Examples

### Example 1: Code Exploration

```bash
cd ~/my-project
opencode

> Explain the architecture of this project
> What are the main entry points?
> How is error handling implemented?
```

### Example 2: Feature Development

```bash
cd ~/my-project
opencode

> Add a new endpoint POST /api/users that creates a user
> Include input validation and error handling
> Write tests for the new endpoint
```

### Example 3: Debugging

```bash
cd ~/my-project
opencode

> The login function is failing with a 500 error. Debug it.
> Check the logs and identify the root cause
> Fix the issue and verify the fix
```

### Example 4: Refactoring

```bash
cd ~/my-project
opencode

> Refactor the database module to use connection pooling
> Ensure backward compatibility
> Update the documentation
```

## Configuration Options

### Full Configuration File

Create `~/.opencode/config.json`:

```json
{
  "provider": "openai-compatible",
  "apiBase": "http://localhost:4000",
  "apiKey": "sk-1234",
  "model": "qwen-coder",

  "options": {
    "temperature": 0.3,
    "maxTokens": 4096,
    "topP": 0.9
  },

  "editor": {
    "command": "code",
    "args": ["--wait"]
  },

  "git": {
    "autoCommit": false,
    "commitPrefix": "feat: "
  },

  "shell": {
    "confirmCommands": true,
    "allowedCommands": ["npm", "yarn", "pnpm", "git", "make"]
  },

  "context": {
    "includeGitHistory": true,
    "maxFiles": 50,
    "ignorePatterns": ["node_modules", ".git", "dist"]
  }
}
```

### Model-Specific Configurations

For different tasks, you might want different models:

```json
{
  "profiles": {
    "fast": {
      "provider": "openai-compatible",
      "apiBase": "http://localhost:4000",
      "apiKey": "sk-1234",
      "model": "qwen-coder-fast"
    },
    "quality": {
      "provider": "openai-compatible",
      "apiBase": "http://localhost:4000",
      "apiKey": "sk-1234",
      "model": "qwen-coder-best"
    },
    "cloud": {
      "provider": "openai-compatible",
      "apiBase": "http://localhost:4000",
      "apiKey": "sk-1234",
      "model": "claude-sonnet"
    }
  }
}
```

Use profiles:
```bash
opencode --profile fast    # Quick tasks
opencode --profile quality # Complex refactoring
opencode --profile cloud   # Use Bedrock Claude
```

## Shell Aliases

Add to `~/.zshrc` for convenience:

```bash
# OpenCode with local models via LiteLLM
alias oc="opencode -m litellm/qwen-coder-fast"
alias oc-fast="opencode -m litellm/qwen-coder-fast"
alias oc-best="opencode -m litellm/qwen-coder-best"
alias oc-claude="opencode -m litellm/claude-sonnet"

# Direct Ollama access (no LiteLLM needed)
alias oc-ollama="opencode -m ollama/qwen2.5-coder:7b"

# Ensure LiteLLM is running before OpenCode
function opencode-local() {
    # Check if LiteLLM is running
    if ! curl -s http://localhost:4000/health > /dev/null 2>&1; then
        echo "Starting LiteLLM..."
        litellm --config ~/.litellm/config.yaml --port 4000 &
        sleep 3
    fi
    opencode "$@"
}
alias ocl="opencode-local"
```

## Tips for Best Results

### 1. Provide Context

OpenCode works better when it understands your project:

```
> This is a Node.js Express API with PostgreSQL database.
> The main files are in src/ and tests are in test/.
> We use TypeScript and follow the Airbnb style guide.
```

### 2. Be Specific

Instead of:
```
> Fix the bug
```

Try:
```
> The getUserById function in src/users/service.ts returns null
> instead of throwing an error when the user doesn't exist.
> Fix this to throw a NotFoundError.
```

### 3. Use Incremental Changes

For large changes, break them down:

```
> First, let's understand the current authentication flow
> Now, let's design the new OAuth integration
> Implement the OAuth callback handler
> Add tests for the new functionality
> Update the documentation
```

### 4. Review Before Committing

```
> Show me a diff of all changes
> Run the tests before committing
> Create a commit with a descriptive message
```

## Comparison: OpenCode vs Aider

| Feature | OpenCode | Aider |
|---------|----------|-------|
| Interface | Interactive terminal | Interactive terminal |
| File editing | Yes | Yes |
| Git integration | Yes | Yes (stronger) |
| Shell commands | Yes | Yes |
| Multiple files | Yes | Yes |
| Ollama support | Via OpenAI-compat | Native |
| Learning curve | Lower | Medium |
| Customization | Good | Extensive |

**Use OpenCode when:**
- You want a simpler setup
- You prefer a more conversational interface
- You're new to AI coding assistants

**Use Aider when:**
- You need stronger git integration
- You want more control over file context
- You need architect/editor mode separation

## Troubleshooting

### OpenCode Can't Connect to LiteLLM

```bash
# Check LiteLLM is running
curl http://localhost:4000/health

# Check available models
curl http://localhost:4000/v1/models

# Restart LiteLLM
pkill -f litellm
./scripts/start-litellm.sh
```

### Slow Responses

1. Use a smaller model:
```bash
OPENCODE_MODEL=qwen-coder-fast opencode
```

2. Check Ollama memory:
```bash
ollama ps
ollama stop qwen2.5-coder:32b  # Stop large model
```

3. Reduce context:
```json
{
  "context": {
    "maxFiles": 20
  }
}
```

### Model Not Found

```bash
# List available models in LiteLLM
curl http://localhost:4000/v1/models | jq '.data[].id'

# List Ollama models
ollama list

# Pull missing model
ollama pull qwen2.5-coder:14b
```

### Configuration Not Loading

```bash
# Check config location
ls -la ~/.opencode/config.json

# Validate JSON
cat ~/.opencode/config.json | jq .

# Use explicit config
opencode --config /path/to/config.json
```

## Integration with Workflow

### With Git

```bash
cd ~/my-project
git checkout -b feature/new-auth

opencode
> Implement OAuth2 login with Google provider
> Add tests
> Create a commit message

git push origin feature/new-auth
```

### With VS Code

```bash
# Open project in VS Code
code ~/my-project

# In terminal within VS Code
opencode
> Review the open files and suggest improvements
```

### With CI/CD

```bash
# In CI script, use OpenCode for automated fixes
export OPENAI_API_BASE=http://localhost:4000
export OPENAI_API_KEY=sk-1234

opencode --non-interactive "Fix linting errors in src/"
```

## Further Reading

- [OpenCode Documentation](https://opencode.ai/docs)
- [OpenCode GitHub](https://github.com/opencode-ai/opencode)
- [LiteLLM + OpenCode](https://docs.litellm.ai/docs/providers/openai_compatible)
- [Ollama Models](https://ollama.com/library)
