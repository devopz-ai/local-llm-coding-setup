#!/bin/bash
# start-aider.sh - Start Aider AI pair programming session
set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo "=========================================="
echo "Aider - AI Pair Programming"
echo "=========================================="
echo ""

# Check if Ollama is running
if ! curl -s http://localhost:11434/ >/dev/null 2>&1; then
    echo -e "${YELLOW}Starting Ollama server...${NC}"
    ollama serve &
    sleep 3
fi

# Check if Aider is installed
if ! command -v aider >/dev/null 2>&1; then
    echo -e "${RED}Aider is not installed.${NC}"
    echo "Installing with pip..."
    pip3 install aider-chat
fi

# List available models
echo "Available models:"
echo ""
ollama list | grep -E "coder|code" || ollama list
echo ""

# Model selection
echo "Select a model:"
echo "  1) qwen2.5-coder:7b   (fast, ~4.5GB)"
echo "  2) qwen2.5-coder:14b  (balanced, ~9GB) [default]"
echo "  3) qwen2.5-coder:32b  (best quality, ~20GB)"
echo "  4) deepseek-coder-v2:16b (complex reasoning)"
echo "  5) codestral:22b      (Mistral's model)"
echo "  6) Custom model"
echo ""
read -p "Enter choice [2]: " choice
choice=${choice:-2}

case $choice in
    1) MODEL="qwen2.5-coder:7b" ;;
    2) MODEL="qwen2.5-coder:14b" ;;
    3) MODEL="qwen2.5-coder:32b" ;;
    4) MODEL="deepseek-coder-v2:16b" ;;
    5) MODEL="codestral:22b" ;;
    6)
        read -p "Enter model name: " MODEL
        ;;
    *) MODEL="qwen2.5-coder:14b" ;;
esac

# Check if model is available
if ! ollama list | grep -q "$MODEL"; then
    echo ""
    echo -e "${YELLOW}Model $MODEL not found. Pulling...${NC}"
    ollama pull "$MODEL"
fi

echo ""
echo -e "${GREEN}Starting Aider with $MODEL${NC}"
echo ""
echo "=========================================="
echo "Aider Quick Reference:"
echo "=========================================="
echo -e "${CYAN}/add <file>${NC}     - Add file to context"
echo -e "${CYAN}/drop <file>${NC}    - Remove file from context"
echo -e "${CYAN}/run <cmd>${NC}      - Run a shell command"
echo -e "${CYAN}/diff${NC}           - Show pending changes"
echo -e "${CYAN}/commit${NC}         - Commit changes"
echo -e "${CYAN}/undo${NC}           - Undo last change"
echo -e "${CYAN}/help${NC}           - Show all commands"
echo -e "${CYAN}/quit${NC} or Ctrl+D - Exit"
echo "=========================================="
echo ""

# Set environment
export OLLAMA_API_BASE=http://localhost:11434

# Start Aider
aider --model "ollama/$MODEL"
