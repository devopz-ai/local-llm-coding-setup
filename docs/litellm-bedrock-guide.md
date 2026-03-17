# LiteLLM + AWS Bedrock Integration Guide

Complete guide for using LiteLLM as a unified proxy for local (Ollama) and enterprise (AWS Bedrock) models.

## Overview

LiteLLM provides:
- **Unified API**: One OpenAI-compatible endpoint for all models
- **Model Routing**: Seamlessly switch between free local and paid cloud models
- **Fallbacks**: Automatic failover if a model is unavailable
- **Cost Tracking**: Monitor usage across providers
- **Compatibility**: Works with any tool that supports OpenAI API

## Architecture

```
                    ┌─────────────────┐
                    │   Your Tools    │
                    │  Aider/Continue │
                    └────────┬────────┘
                             │
                             ▼
                    ┌─────────────────┐
                    │    LiteLLM      │
                    │  localhost:4000 │
                    └────────┬────────┘
                             │
          ┌──────────────────┼──────────────────┐
          ▼                  ▼                  ▼
    ┌───────────┐     ┌───────────┐     ┌───────────┐
    │  Ollama   │     │  Bedrock  │     │  OpenAI   │
    │  (FREE)   │     │ (Claude)  │     │ (GPT-4)   │
    └───────────┘     └───────────┘     └───────────┘
```

## Quick Start

### 1. Install LiteLLM

```bash
./scripts/setup-litellm.sh
# or
pip install 'litellm[proxy]'
```

### 2. Configure AWS (for Bedrock)

```bash
# Install AWS CLI
brew install awscli

# Configure credentials
aws configure

# Verify
aws sts get-caller-identity
```

### 3. Start LiteLLM

```bash
./scripts/start-litellm.sh
# or
litellm --config ~/.litellm/config.yaml --port 4000
```

### 4. Use with Any Tool

```bash
# Environment setup
export OPENAI_API_BASE=http://localhost:4000
export OPENAI_API_KEY=sk-1234

# Use with Aider
aider --model qwen-coder  # FREE local
aider --model claude-sonnet  # Bedrock
```

## Model Reference

### Local Models (FREE via Ollama)

| LiteLLM Model Name | Ollama Model | Size | Speed |
|-------------------|--------------|------|-------|
| `qwen-coder-fast` | qwen2.5-coder:7b | 4.5GB | Fast |
| `qwen-coder` | qwen2.5-coder:14b | 9GB | Medium |
| `qwen-coder-best` | qwen2.5-coder:32b | 20GB | Slow |
| `deepseek-coder` | deepseek-coder-v2:16b | 10GB | Medium |
| `codestral` | codestral:22b | 13GB | Medium |
| `llama` | llama3.2:8b | 4.5GB | Fast |

### Enterprise Models (AWS Bedrock)

| LiteLLM Model Name | Bedrock Model ID | Best For |
|-------------------|------------------|----------|
| `claude-sonnet` | anthropic.claude-3-5-sonnet-* | Best balance |
| `claude-opus` | anthropic.claude-3-opus-* | Most capable |
| `claude-haiku` | anthropic.claude-3-5-haiku-* | Fast & cheap |
| `bedrock-llama` | meta.llama3-1-70b-instruct-* | Open source |
| `titan` | amazon.titan-text-premier-* | AWS native |

### Compatibility Aliases

These map common model names to local models:

| Request Model | Routes To |
|--------------|-----------|
| `gpt-4` | qwen-coder (14B) |
| `gpt-3.5-turbo` | qwen-coder-fast (7B) |

## AWS Bedrock Setup

### Step 1: Enable Model Access

1. Go to [AWS Console](https://console.aws.amazon.com/bedrock/)
2. Navigate to **Model access**
3. Click **Manage model access**
4. Select models:
   - Anthropic > Claude 3.5 Sonnet
   - Anthropic > Claude 3 Opus
   - Anthropic > Claude 3.5 Haiku
5. Click **Request model access**
6. Wait for approval (usually instant)

### Step 2: Configure AWS Credentials

Option A - AWS CLI:
```bash
aws configure
# AWS Access Key ID: YOUR_KEY
# AWS Secret Access Key: YOUR_SECRET
# Default region: us-west-2
# Output format: json
```

Option B - Environment Variables:
```bash
export AWS_ACCESS_KEY_ID=YOUR_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET
export AWS_DEFAULT_REGION=us-west-2
```

Option C - AWS Profile:
```bash
# ~/.aws/credentials
[bedrock]
aws_access_key_id = YOUR_KEY
aws_secret_access_key = YOUR_SECRET

# ~/.aws/config
[profile bedrock]
region = us-west-2

# Use profile
export AWS_PROFILE=bedrock
```

### Step 3: Verify Access

```bash
# Check credentials
aws sts get-caller-identity

# List available models
aws bedrock list-foundation-models \
  --query "modelSummaries[?contains(modelId, 'claude')].[modelId,modelName]" \
  --output table

# Test model invocation
aws bedrock-runtime invoke-model \
  --model-id anthropic.claude-3-5-haiku-20241022-v1:0 \
  --body '{"anthropic_version":"bedrock-2023-05-31","max_tokens":100,"messages":[{"role":"user","content":"Hello"}]}' \
  --cli-binary-format raw-in-base64-out \
  output.json
```

## LiteLLM Configuration

### Basic Config (~/.litellm/config.yaml)

```yaml
model_list:
  # Local FREE model
  - model_name: qwen-coder
    litellm_params:
      model: ollama/qwen2.5-coder:14b
      api_base: http://localhost:11434

  # Bedrock Claude
  - model_name: claude-sonnet
    litellm_params:
      model: bedrock/anthropic.claude-3-5-sonnet-20241022-v2:0
      aws_region_name: us-west-2

litellm_settings:
  fallbacks:
    - claude-sonnet: [qwen-coder]  # Fallback to local if Bedrock fails
```

### Advanced Config with Load Balancing

```yaml
model_list:
  # Multiple instances for load balancing
  - model_name: claude
    litellm_params:
      model: bedrock/anthropic.claude-3-5-sonnet-20241022-v2:0
      aws_region_name: us-west-2
  - model_name: claude
    litellm_params:
      model: bedrock/anthropic.claude-3-5-sonnet-20241022-v2:0
      aws_region_name: us-east-1

router_settings:
  routing_strategy: least-busy
  num_retries: 2
```

### Config with Cost Tracking

```yaml
litellm_settings:
  success_callback: ["langfuse"]  # or "helicone", "lunary"

general_settings:
  database_url: sqlite:///litellm_usage.db
```

## Usage Examples

### With curl

```bash
# Local model (FREE)
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-1234" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen-coder",
    "messages": [{"role": "user", "content": "Write a quicksort in Python"}]
  }'

# Bedrock Claude
curl http://localhost:4000/v1/chat/completions \
  -H "Authorization: Bearer sk-1234" \
  -H "Content-Type: application/json" \
  -d '{
    "model": "claude-sonnet",
    "messages": [{"role": "user", "content": "Design a microservices architecture for an e-commerce platform"}]
  }'
```

### With Python

```python
from openai import OpenAI

client = OpenAI(
    base_url="http://localhost:4000",
    api_key="sk-1234"
)

# Use local model (FREE)
response = client.chat.completions.create(
    model="qwen-coder",
    messages=[{"role": "user", "content": "Write a binary search"}]
)

# Use Bedrock Claude
response = client.chat.completions.create(
    model="claude-sonnet",
    messages=[{"role": "user", "content": "Explain SOLID principles"}]
)
```

### With Aider

```bash
# Local model (FREE)
aider --openai-api-base http://localhost:4000 \
      --openai-api-key sk-1234 \
      --model qwen-coder

# Bedrock Claude
aider --openai-api-base http://localhost:4000 \
      --openai-api-key sk-1234 \
      --model claude-sonnet
```

### With Continue (VS Code)

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
  ]
}
```

## Cost Management

### Bedrock Pricing (as of 2024)

| Model | Input (per 1M tokens) | Output (per 1M tokens) |
|-------|----------------------|------------------------|
| Claude 3.5 Sonnet | $3.00 | $15.00 |
| Claude 3 Opus | $15.00 | $75.00 |
| Claude 3.5 Haiku | $0.80 | $4.00 |
| Llama 3.1 70B | $0.99 | $0.99 |

### Cost-Saving Strategies

1. **Use local models for routine tasks**
   - Code completion: qwen-coder-fast (FREE)
   - Simple questions: qwen-coder (FREE)
   - Code review: qwen-coder (FREE)

2. **Use Bedrock for complex tasks**
   - Architecture design: claude-sonnet
   - Complex debugging: claude-sonnet
   - Critical code review: claude-opus

3. **Use Haiku for fast, cheap cloud tasks**
   - Quick validations: claude-haiku
   - Simple transformations: claude-haiku

4. **Set up fallbacks**
   ```yaml
   litellm_settings:
     fallbacks:
       - claude-sonnet: [qwen-coder-best]
   ```

### Monitor Usage

```bash
# Check LiteLLM spend
curl http://localhost:4000/spend/logs

# AWS Cost Explorer
aws ce get-cost-and-usage \
  --time-period Start=2024-01-01,End=2024-01-31 \
  --granularity MONTHLY \
  --filter '{"Dimensions":{"Key":"SERVICE","Values":["Amazon Bedrock"]}}' \
  --metrics "BlendedCost"
```

## Troubleshooting

### LiteLLM Won't Start

```bash
# Check port availability
lsof -i :4000

# Kill existing process
pkill -f litellm

# Start with debug logging
litellm --config ~/.litellm/config.yaml --port 4000 --debug
```

### Bedrock Authentication Errors

```bash
# Verify credentials
aws sts get-caller-identity

# Check region
aws configure get region

# Test Bedrock access
aws bedrock list-foundation-models --query "modelSummaries[0]"
```

### Model Not Found

```bash
# List available models in LiteLLM
curl http://localhost:4000/v1/models

# Check model is in config
cat ~/.litellm/config.yaml | grep model_name
```

### Slow Responses

1. Check Ollama is running: `ollama ps`
2. Use smaller model for quick tasks
3. Reduce context length
4. Check network latency to AWS

### Ollama Models Not Available

```bash
# Ensure Ollama is running
curl http://localhost:11434/

# Pull missing models
ollama pull qwen2.5-coder:14b

# Restart LiteLLM
pkill -f litellm
./scripts/start-litellm.sh
```

## Security Best Practices

1. **Never commit AWS credentials**
2. **Use IAM roles** in production (not access keys)
3. **Restrict Bedrock permissions** to only needed models
4. **Use VPC endpoints** for Bedrock in production
5. **Enable CloudTrail** for audit logging
6. **Set spending limits** in AWS Budgets

## Further Reading

- [LiteLLM Documentation](https://docs.litellm.ai/)
- [AWS Bedrock User Guide](https://docs.aws.amazon.com/bedrock/latest/userguide/)
- [Bedrock Pricing](https://aws.amazon.com/bedrock/pricing/)
- [LiteLLM Bedrock Integration](https://docs.litellm.ai/docs/providers/bedrock)
