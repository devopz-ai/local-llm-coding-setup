#!/bin/bash
# setup-litellm.sh - Install and configure LiteLLM proxy
set -e

echo "=========================================="
echo "LiteLLM Proxy Setup"
echo "=========================================="
echo ""
echo "LiteLLM provides a unified OpenAI-compatible API for:"
echo "  - Local models (Ollama) - FREE"
echo "  - AWS Bedrock (Claude, Llama, Titan)"
echo "  - OpenAI, Anthropic, and 100+ providers"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python3 not found. Please install Python first.${NC}"
    exit 1
fi

# Install LiteLLM
echo -e "${YELLOW}Installing LiteLLM...${NC}"
pip3 install 'litellm[proxy]'

echo ""
echo -e "${GREEN}LiteLLM installed successfully!${NC}"
echo ""

# Create config directory
CONFIG_DIR="$HOME/.litellm"
mkdir -p "$CONFIG_DIR"

# Check for existing config
if [ -f "$CONFIG_DIR/config.yaml" ]; then
    echo -e "${YELLOW}Existing config found at $CONFIG_DIR/config.yaml${NC}"
    read -p "Overwrite? (y/N): " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        echo "Keeping existing config."
        echo ""
        echo "Start LiteLLM with: litellm --config $CONFIG_DIR/config.yaml"
        exit 0
    fi
fi

# Copy config template
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cp "$SCRIPT_DIR/../configs/litellm-config.yaml" "$CONFIG_DIR/config.yaml"

echo -e "${GREEN}Config created at: $CONFIG_DIR/config.yaml${NC}"
echo ""

# AWS Bedrock setup
echo "=========================================="
echo "AWS Bedrock Configuration (Optional)"
echo "=========================================="
echo ""
echo "To use AWS Bedrock models, you need AWS credentials configured."
echo ""

if command -v aws &> /dev/null; then
    if aws sts get-caller-identity &> /dev/null 2>&1; then
        AWS_ACCOUNT=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
        AWS_REGION=$(aws configure get region 2>/dev/null || echo "not set")
        echo -e "${GREEN}AWS CLI configured!${NC}"
        echo "  Account: $AWS_ACCOUNT"
        echo "  Region: $AWS_REGION"
        echo ""
        echo "Make sure Bedrock model access is enabled in your AWS account."
    else
        echo -e "${YELLOW}AWS CLI installed but not configured.${NC}"
        echo ""
        echo "Configure with: aws configure"
        echo "Or set environment variables:"
        echo "  export AWS_ACCESS_KEY_ID=your_key"
        echo "  export AWS_SECRET_ACCESS_KEY=your_secret"
        echo "  export AWS_DEFAULT_REGION=us-west-2"
    fi
else
    echo -e "${YELLOW}AWS CLI not installed.${NC}"
    echo ""
    echo "Install with: brew install awscli"
    echo "Then configure: aws configure"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Start LiteLLM proxy:"
echo "  ./scripts/start-litellm.sh"
echo ""
echo "Or manually:"
echo "  litellm --config ~/.litellm/config.yaml --port 4000"
echo ""
echo "Then use any tool with:"
echo "  OPENAI_API_BASE=http://localhost:4000"
echo "  OPENAI_API_KEY=sk-1234  # any dummy key"
echo ""
echo "Available models after starting:"
echo "  - ollama/qwen2.5-coder:7b      (FREE - local)"
echo "  - ollama/qwen2.5-coder:14b     (FREE - local)"
echo "  - bedrock/claude-3-5-sonnet    (Bedrock - requires AWS)"
echo "  - bedrock/claude-3-opus        (Bedrock - requires AWS)"
echo ""
