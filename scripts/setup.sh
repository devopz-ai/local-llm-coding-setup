#!/bin/bash
# setup.sh - Initial setup for local LLM coding environment
set -e

echo "=========================================="
echo "Local LLM Coding Setup for Mac Mini M4"
echo "=========================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to print status
print_status() {
    if [ "$2" = "ok" ]; then
        echo -e "${GREEN}[OK]${NC} $1"
    elif [ "$2" = "missing" ]; then
        echo -e "${RED}[MISSING]${NC} $1"
    else
        echo -e "${YELLOW}[INFO]${NC} $1"
    fi
}

echo "Checking prerequisites..."
echo ""

# Check Homebrew
if command_exists brew; then
    print_status "Homebrew installed" "ok"
else
    print_status "Homebrew not found - installing..." "missing"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check Ollama
if command_exists ollama; then
    OLLAMA_VERSION=$(ollama --version 2>/dev/null | awk '{print $NF}')
    print_status "Ollama installed (version $OLLAMA_VERSION)" "ok"
else
    print_status "Ollama not found - please install from https://ollama.com/download" "missing"
    echo "  Opening download page..."
    open "https://ollama.com/download/mac"
    exit 1
fi

# Check if Ollama is running
if curl -s http://localhost:11434/ >/dev/null 2>&1; then
    print_status "Ollama server is running" "ok"
else
    print_status "Starting Ollama server..." "info"
    ollama serve &
    sleep 3
    if curl -s http://localhost:11434/ >/dev/null 2>&1; then
        print_status "Ollama server started successfully" "ok"
    else
        print_status "Failed to start Ollama server" "missing"
        echo "  Please start Ollama manually: ollama serve"
    fi
fi

# Check Python
if command_exists python3; then
    PYTHON_VERSION=$(python3 --version 2>&1 | awk '{print $2}')
    print_status "Python installed (version $PYTHON_VERSION)" "ok"
else
    print_status "Python not found - installing..." "missing"
    brew install python@3.11
fi

# Check pip
if command_exists pip3; then
    print_status "pip installed" "ok"
else
    print_status "pip not found - installing..." "missing"
    python3 -m ensurepip --upgrade
fi

# Check Docker (optional for Open WebUI)
if command_exists docker; then
    print_status "Docker installed (optional)" "ok"
else
    print_status "Docker not installed (optional - needed for Open WebUI via Docker)" "info"
fi

echo ""
echo "=========================================="
echo "Installing Python packages..."
echo "=========================================="
echo ""

# Install Aider
if command_exists aider; then
    print_status "Aider already installed" "ok"
else
    print_status "Installing Aider..." "info"
    pip3 install aider-chat
fi

# Install llm CLI (optional)
if pip3 show llm >/dev/null 2>&1; then
    print_status "llm CLI already installed" "ok"
else
    print_status "Installing llm CLI..." "info"
    pip3 install llm
    pip3 install llm-ollama
fi

# Install Open WebUI (pip version)
if pip3 show open-webui >/dev/null 2>&1; then
    print_status "Open WebUI (pip) already installed" "ok"
else
    print_status "Installing Open WebUI..." "info"
    pip3 install open-webui
fi

echo ""
echo "=========================================="
echo "Setting up shell configuration..."
echo "=========================================="
echo ""

# Add environment variables to .zshrc
ZSHRC="$HOME/.zshrc"
if ! grep -q "OLLAMA_API_BASE" "$ZSHRC" 2>/dev/null; then
    print_status "Adding Ollama environment variables to $ZSHRC" "info"
    cat >> "$ZSHRC" << 'EOF'

# ===== Local LLM Configuration =====
export OLLAMA_API_BASE=http://localhost:11434
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=2
export OLLAMA_KEEP_ALIVE="5m"

# Aider aliases
alias aider-local="aider --model ollama/qwen2.5-coder:14b"
alias aider-fast="aider --model ollama/qwen2.5-coder:7b"
alias aider-best="aider --model ollama/qwen2.5-coder:32b"

# Ollama shortcuts
alias llm-chat="ollama run qwen2.5-coder:14b"
alias llm-fast="ollama run qwen2.5-coder:7b"
# ===================================
EOF
    print_status "Shell configuration updated" "ok"
else
    print_status "Shell configuration already exists" "ok"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: source ~/.zshrc"
echo "  2. Pull models: ./scripts/pull-models.sh"
echo "  3. Start coding: aider-local"
echo ""
echo "Quick commands after setup:"
echo "  - aider-local    : Start Aider with 14B model"
echo "  - aider-fast     : Start Aider with 7B model (faster)"
echo "  - llm-chat       : Quick chat with coding model"
echo "  - open-webui serve : Start web interface"
echo ""
