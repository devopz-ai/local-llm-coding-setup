# Claude Code CLI Guide

Claude Code is Anthropic's official CLI for AI-powered coding assistance. This guide covers setup with AWS Bedrock and integration with local models.

## What is Claude Code?

Claude Code is a terminal-based AI coding assistant that:
- Understands your entire codebase
- Can read, write, and edit files
- Runs shell commands
- Integrates with git
- Maintains conversation context
- Works with Claude models via API or Bedrock

## Installation

### Install via npm

```bash
npm install -g @anthropic-ai/claude-code
```

### Install via Homebrew

```bash
brew install claude-code
```

### Verify Installation

```bash
claude --version
claude --help
```

## Configuration Options

Claude Code can connect to:
1. **Anthropic API** (direct)
2. **AWS Bedrock** (enterprise)
3. **LiteLLM Proxy** (for local model fallback)

### Option 1: Anthropic API (Direct)

```bash
# Set API key
export ANTHROPIC_API_KEY=sk-ant-xxxxx

# Run Claude Code
claude
```

### Option 2: AWS Bedrock (Enterprise - Recommended)

```bash
# Configure AWS credentials
aws configure

# Set Bedrock as provider
export CLAUDE_CODE_USE_BEDROCK=1
export AWS_REGION=us-west-2

# Or use specific profile
export AWS_PROFILE=bedrock

# Run Claude Code
claude
```

#### Bedrock Configuration File

Create `~/.claude-code/config.json`:

```json
{
  "provider": "bedrock",
  "aws": {
    "region": "us-west-2",
    "profile": "default"
  },
  "model": "anthropic.claude-3-5-sonnet-20241022-v2:0",
  "options": {
    "maxTokens": 4096,
    "temperature": 0.3
  }
}
```

### Option 3: Via LiteLLM (Hybrid Local + Cloud)

Use LiteLLM to route between local models and Bedrock:

```bash
# Start LiteLLM
./scripts/start-litellm.sh

# Configure Claude Code to use LiteLLM
export OPENAI_API_BASE=http://localhost:4000
export OPENAI_API_KEY=sk-1234

# In config, use OpenAI-compatible mode
```

## AWS Bedrock Setup

### Step 1: Enable Model Access

1. Go to [AWS Bedrock Console](https://console.aws.amazon.com/bedrock/)
2. Navigate to **Model access**
3. Request access to Claude models:
   - Claude 3.5 Sonnet
   - Claude 3 Opus
   - Claude 3.5 Haiku

### Step 2: IAM Permissions

Create IAM policy for Bedrock:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "bedrock:InvokeModel",
        "bedrock:InvokeModelWithResponseStream"
      ],
      "Resource": [
        "arn:aws:bedrock:*::foundation-model/anthropic.claude-*"
      ]
    }
  ]
}
```

### Step 3: Configure AWS CLI

```bash
aws configure
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET
# Default region: us-west-2
# Output format: json

# Verify
aws sts get-caller-identity
aws bedrock list-foundation-models --query "modelSummaries[?contains(modelId,'claude')]"
```

## Usage

### Basic Usage

```bash
# Start in your project directory
cd ~/my-project
claude

# Ask questions
> Explain the architecture of this project
> How does authentication work?

# Make changes
> Add input validation to the user registration
> Write tests for the payment module

# Run commands
> Run the test suite
> Check for security vulnerabilities
```

### Command Line Options

```bash
# Use specific model
claude --model claude-3-5-sonnet

# Set output format
claude --output-format markdown

# Increase verbosity
claude --verbose

# Non-interactive mode
claude --message "Explain main.py" --no-interactive
```

### Project-Specific Configuration

Create `.claude-code.json` in your project root:

```json
{
  "context": {
    "include": ["src/**/*.py", "tests/**/*.py"],
    "exclude": ["node_modules", "dist", ".git"]
  },
  "instructions": "This is a Python FastAPI project. Follow PEP 8 style guide.",
  "autoCommit": false
}
```

## Integration with Memory Systems

Claude Code can be enhanced with external memory systems. See [Memory Management Guide](./memory-management-guide.md) for details.

### Quick Memory Integration

```bash
# Use with mem0 for persistent memory
export CLAUDE_CODE_MEMORY_PROVIDER=mem0
export MEM0_API_KEY=your_key

# Claude Code will now remember context across sessions
claude
```

## Cost Management

### Bedrock Pricing

| Model | Input (1M tokens) | Output (1M tokens) |
|-------|-------------------|-------------------|
| Claude 3.5 Sonnet | $3.00 | $15.00 |
| Claude 3 Opus | $15.00 | $75.00 |
| Claude 3.5 Haiku | $0.80 | $4.00 |

### Cost-Saving Tips

1. Use Haiku for simple tasks
2. Limit context with `.claude-code.json`
3. Use local models via LiteLLM for routine tasks
4. Set token limits in config

## Troubleshooting

### Bedrock Connection Issues

```bash
# Check AWS credentials
aws sts get-caller-identity

# Test Bedrock access
aws bedrock-runtime invoke-model \
  --model-id anthropic.claude-3-5-haiku-20241022-v1:0 \
  --body '{"anthropic_version":"bedrock-2023-05-31","max_tokens":100,"messages":[{"role":"user","content":"Hi"}]}' \
  output.json

cat output.json
```

### Model Not Available

```bash
# List available models
aws bedrock list-foundation-models \
  --query "modelSummaries[?contains(modelId,'claude')].modelId"

# Check model access status
aws bedrock list-foundation-models \
  --query "modelSummaries[?contains(modelId,'claude')].[modelId,modelLifecycle.status]"
```

### Rate Limiting

If you hit rate limits:
1. Request quota increase in AWS Console
2. Use provisioned throughput for consistent performance
3. Implement retry logic in your workflow

## Comparison with Other Tools

| Feature | Claude Code | Aider | OpenCode |
|---------|-------------|-------|----------|
| Provider | Anthropic/Bedrock | Multiple | Multiple |
| Local LLM | Via proxy | Native | Via proxy |
| Memory | Built-in | Chat history | Config-based |
| Git Integration | Strong | Strong | Good |
| File Editing | Yes | Yes | Yes |
| Shell Commands | Yes | Yes | Yes |

## Further Reading

- [Claude Code Documentation](https://docs.anthropic.com/claude-code)
- [AWS Bedrock User Guide](https://docs.aws.amazon.com/bedrock/)
- [Memory Management Guide](./memory-management-guide.md)
