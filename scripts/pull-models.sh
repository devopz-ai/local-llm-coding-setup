#!/bin/bash
# pull-models.sh - Download recommended coding models for 32GB Mac
set -e

echo "=========================================="
echo "Pulling Recommended Coding Models"
echo "=========================================="
echo ""
echo "This will download approximately 30GB of models."
echo "You can skip any model by pressing Ctrl+C and running the next command manually."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if Ollama is running
if ! curl -s http://localhost:11434/ >/dev/null 2>&1; then
    echo "Ollama is not running. Starting it..."
    ollama serve &
    sleep 3
fi

echo "----------------------------------------"
echo -e "${YELLOW}[1/5]${NC} Qwen2.5 Coder 7B (~4.5GB) - Fast, daily driver"
echo "----------------------------------------"
ollama pull qwen2.5-coder:7b
echo -e "${GREEN}Done!${NC}"
echo ""

echo "----------------------------------------"
echo -e "${YELLOW}[2/5]${NC} Qwen2.5 Coder 14B (~9GB) - Better quality"
echo "----------------------------------------"
ollama pull qwen2.5-coder:14b
echo -e "${GREEN}Done!${NC}"
echo ""

echo "----------------------------------------"
echo -e "${YELLOW}[3/5]${NC} DeepSeek Coder V2 16B (~10GB) - Complex reasoning"
echo "----------------------------------------"
ollama pull deepseek-coder-v2:16b
echo -e "${GREEN}Done!${NC}"
echo ""

echo "----------------------------------------"
echo -e "${YELLOW}[4/5]${NC} Codestral 22B (~13GB) - Mistral's coding model"
echo "----------------------------------------"
ollama pull codestral:22b
echo -e "${GREEN}Done!${NC}"
echo ""

echo "----------------------------------------"
echo -e "${YELLOW}[5/5]${NC} Llama 3.2 8B (~4.5GB) - General purpose"
echo "----------------------------------------"
ollama pull llama3.2:8b
echo -e "${GREEN}Done!${NC}"
echo ""

echo "=========================================="
echo "All models downloaded!"
echo "=========================================="
echo ""
echo "Installed models:"
ollama list
echo ""
echo "Quick test commands:"
echo "  ollama run qwen2.5-coder:7b 'Write a hello world in Python'"
echo "  ollama run qwen2.5-coder:14b 'Explain binary search'"
echo ""

# Optional: Download larger model
echo "=========================================="
echo "Optional: Download Qwen2.5 Coder 32B?"
echo "=========================================="
echo "This is the highest quality model but uses ~20GB RAM and is slower."
read -p "Download qwen2.5-coder:32b? (y/N): " response
if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Downloading qwen2.5-coder:32b (~20GB)..."
    ollama pull qwen2.5-coder:32b
    echo -e "${GREEN}Done!${NC}"
fi

echo ""
echo "Setup complete! Start coding with: aider --model ollama/qwen2.5-coder:14b"
