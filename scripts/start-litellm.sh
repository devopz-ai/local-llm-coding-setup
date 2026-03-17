#!/bin/bash
# start-litellm.sh - Start LiteLLM proxy server
set -e

echo "=========================================="
echo "Starting LiteLLM Proxy"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check if LiteLLM is installed
if ! command -v litellm &> /dev/null; then
    echo -e "${RED}LiteLLM not installed.${NC}"
    echo "Run: ./scripts/setup-litellm.sh"
    exit 1
fi

# Check if Ollama is running (for local models)
if curl -s http://localhost:11434/ >/dev/null 2>&1; then
    echo -e "${GREEN}Ollama is running${NC} - Local models available"
else
    echo -e "${YELLOW}Ollama not running${NC} - Starting..."
    ollama serve &
    sleep 3
fi

# Check AWS credentials (for Bedrock)
if aws sts get-caller-identity &> /dev/null 2>&1; then
    echo -e "${GREEN}AWS credentials configured${NC} - Bedrock models available"
else
    echo -e "${YELLOW}AWS not configured${NC} - Bedrock models unavailable"
    echo "  Configure with: aws configure"
fi

echo ""

# Config file location
CONFIG_FILE="$HOME/.litellm/config.yaml"
if [ ! -f "$CONFIG_FILE" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    CONFIG_FILE="$SCRIPT_DIR/../configs/litellm-config.yaml"
fi

echo "Using config: $CONFIG_FILE"
echo ""

# Check if port 4000 is in use
if lsof -i :4000 >/dev/null 2>&1; then
    echo -e "${YELLOW}Port 4000 is already in use.${NC}"
    echo "LiteLLM may already be running."
    echo ""
    read -p "Kill existing process and restart? (y/N): " response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        pkill -f "litellm" 2>/dev/null || true
        sleep 2
    else
        echo "Exiting."
        exit 0
    fi
fi

echo "=========================================="
echo -e "${CYAN}LiteLLM Proxy Starting on port 4000${NC}"
echo "=========================================="
echo ""
echo "API Base URL: http://localhost:4000"
echo "API Key: sk-1234 (any string works)"
echo ""
echo "Available Models:"
echo "  LOCAL (FREE):"
echo "    - qwen-coder-fast    (7B, fastest)"
echo "    - qwen-coder         (14B, balanced)"
echo "    - qwen-coder-best    (32B, best quality)"
echo "    - deepseek-coder     (16B, algorithms)"
echo ""
echo "  BEDROCK (Enterprise):"
echo "    - claude-sonnet      (Claude 3.5 Sonnet)"
echo "    - claude-opus        (Claude 3 Opus)"
echo "    - claude-haiku       (Claude 3.5 Haiku)"
echo ""
echo "  ALIASES (for compatibility):"
echo "    - gpt-4       → routes to qwen-coder"
echo "    - gpt-3.5-turbo → routes to qwen-coder-fast"
echo ""
echo "Test with:"
echo '  curl http://localhost:4000/v1/models'
echo ""
echo "Press Ctrl+C to stop"
echo "=========================================="
echo ""

# Start LiteLLM
litellm --config "$CONFIG_FILE" --port 4000
