#!/bin/bash
# setup-opencode.sh - Install OpenCode CLI coding assistant
set -e

echo "=========================================="
echo "OpenCode Setup"
echo "=========================================="
echo ""
echo "OpenCode is an AI coding agent built for the terminal,"
echo "similar to Claude Code. Works with local and cloud models."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check for Homebrew
if ! command -v brew &> /dev/null; then
    echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check if OpenCode is already installed
if command -v opencode &> /dev/null; then
    CURRENT_VERSION=$(opencode --version 2>/dev/null || echo "unknown")
    echo -e "${GREEN}OpenCode is already installed (version: $CURRENT_VERSION)${NC}"
    read -p "Reinstall/upgrade? (y/N): " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Skipping installation."
    else
        echo -e "${YELLOW}Upgrading OpenCode...${NC}"
        brew upgrade opencode 2>/dev/null || brew install opencode
    fi
else
    echo -e "${YELLOW}Installing OpenCode via Homebrew...${NC}"
    brew install opencode
fi

# Verify installation
if command -v opencode &> /dev/null; then
    echo ""
    echo -e "${GREEN}OpenCode installed successfully!${NC}"
    OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "installed")
    echo "Version: $OPENCODE_VERSION"
else
    echo ""
    echo -e "${RED}OpenCode installation failed.${NC}"
    echo ""
    echo "Try manual installation:"
    echo "  brew install opencode"
    echo ""
    exit 1
fi

# Create config directory
CONFIG_DIR="$HOME/.opencode"
mkdir -p "$CONFIG_DIR"

echo ""
echo "=========================================="
echo "Configuring OpenCode for Local LLMs"
echo "=========================================="
echo ""

# Check for existing config
if [ -f "$CONFIG_DIR/config.json" ]; then
    echo -e "${YELLOW}Existing config found at $CONFIG_DIR/config.json${NC}"
    read -p "Overwrite with local LLM config? (y/N): " response
    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        echo "Keeping existing config."
    else
        CREATE_CONFIG=true
    fi
else
    CREATE_CONFIG=true
fi

if [ "$CREATE_CONFIG" = true ]; then
    cat > "$CONFIG_DIR/config.json" << 'EOF'
{
  "provider": "openai-compatible",
  "apiBase": "http://localhost:4000",
  "apiKey": "sk-1234",
  "model": "qwen-coder",

  "options": {
    "temperature": 0.3,
    "maxTokens": 4096
  },

  "editor": {
    "command": "code",
    "args": ["--wait"]
  },

  "git": {
    "autoCommit": false,
    "signCommits": false
  },

  "context": {
    "maxFiles": 50,
    "ignorePatterns": ["node_modules", ".git", "dist", "__pycache__", "*.pyc"]
  }
}
EOF
    echo -e "${GREEN}Config created at: $CONFIG_DIR/config.json${NC}"
fi

# Add shell aliases
echo ""
echo "=========================================="
echo "Adding Shell Aliases"
echo "=========================================="
echo ""

ZSHRC="$HOME/.zshrc"
if ! grep -q "# OpenCode aliases" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" << 'EOF'

# ===== OpenCode aliases =====
alias oc="opencode"
alias oc-fast="OPENCODE_MODEL=qwen-coder-fast opencode"
alias oc-best="OPENCODE_MODEL=qwen-coder-best opencode"
alias oc-claude="OPENCODE_MODEL=claude-sonnet opencode"

# OpenCode with LiteLLM auto-start
function opencode-local() {
    if ! curl -s http://localhost:4000/health > /dev/null 2>&1; then
        echo "Starting LiteLLM proxy..."
        litellm --config ~/.litellm/config.yaml --port 4000 > /dev/null 2>&1 &
        sleep 3
    fi
    opencode "$@"
}
alias ocl="opencode-local"
# =============================
EOF
    echo -e "${GREEN}Aliases added to $ZSHRC${NC}"
else
    echo "Aliases already exist in $ZSHRC"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo -e "${CYAN}Quick Start:${NC}"
echo ""
echo "1. Start LiteLLM (required for local models):"
echo "   ./scripts/start-litellm.sh"
echo ""
echo "2. Run OpenCode:"
echo "   opencode"
echo ""
echo -e "${CYAN}Available Aliases (after restarting terminal):${NC}"
echo ""
echo "  oc          - Start OpenCode"
echo "  oc-fast     - Use fast 7B model"
echo "  oc-best     - Use best 32B model"
echo "  oc-claude   - Use Bedrock Claude"
echo "  ocl         - Auto-start LiteLLM + OpenCode"
echo ""
echo -e "${CYAN}Available Models via LiteLLM:${NC}"
echo ""
echo "  LOCAL (FREE):"
echo "    qwen-coder-fast  - 7B, fastest"
echo "    qwen-coder       - 14B, balanced (default)"
echo "    qwen-coder-best  - 32B, best quality"
echo "    deepseek-coder   - 16B, algorithms"
echo ""
echo "  ENTERPRISE (Bedrock):"
echo "    claude-sonnet    - Claude 3.5 Sonnet"
echo "    claude-opus      - Claude 3 Opus"
echo "    claude-haiku     - Claude 3.5 Haiku"
echo ""
echo "To switch models in OpenCode:"
echo "  OPENCODE_MODEL=qwen-coder-best opencode"
echo ""
echo -e "${YELLOW}Note: Run 'source ~/.zshrc' to load aliases now${NC}"
echo ""
