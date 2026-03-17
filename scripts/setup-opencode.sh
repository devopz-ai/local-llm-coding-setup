#!/bin/bash
# setup-opencode.sh - Install OpenCode CLI coding assistant
set -e

echo "=========================================="
echo "OpenCode Setup"
echo "=========================================="
echo ""
echo "OpenCode is a terminal-based AI coding assistant"
echo "similar to Claude Code, works with local and cloud models."
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check for Node.js
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js not found. Installing...${NC}"
    brew install node
fi

NODE_VERSION=$(node --version)
echo -e "${GREEN}Node.js installed: $NODE_VERSION${NC}"

# Check for npm
if ! command -v npm &> /dev/null; then
    echo -e "${RED}npm not found. Please reinstall Node.js.${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}Installing OpenCode...${NC}"

# Install OpenCode globally
npm install -g @anthropics/opencode 2>/dev/null || npm install -g opencode-ai 2>/dev/null || {
    echo ""
    echo -e "${YELLOW}Note: OpenCode package name may vary.${NC}"
    echo "Trying alternative installation methods..."

    # Try pipx for Python-based alternatives
    if command -v pipx &> /dev/null; then
        pipx install opencode 2>/dev/null || true
    fi
}

# Verify installation
if command -v opencode &> /dev/null; then
    echo ""
    echo -e "${GREEN}OpenCode installed successfully!${NC}"
    OPENCODE_VERSION=$(opencode --version 2>/dev/null || echo "installed")
    echo "Version: $OPENCODE_VERSION"
else
    echo ""
    echo -e "${YELLOW}OpenCode CLI not found in PATH.${NC}"
    echo ""
    echo "Alternative options:"
    echo "1. Use Aider (already configured): aider-local"
    echo "2. Install manually: npm install -g @opencode/cli"
    echo "3. Check: https://github.com/anthropics/opencode"
    echo ""
fi

# Create config directory
CONFIG_DIR="$HOME/.opencode"
mkdir -p "$CONFIG_DIR"

# Create config if OpenCode is installed
if command -v opencode &> /dev/null; then
    echo ""
    echo "Creating OpenCode configuration..."

    cat > "$CONFIG_DIR/config.json" << 'EOF'
{
  "provider": "openai-compatible",
  "apiBase": "http://localhost:4000",
  "apiKey": "sk-1234",
  "model": "qwen-coder",
  "models": {
    "fast": "qwen-coder-fast",
    "default": "qwen-coder",
    "best": "claude-sonnet"
  },
  "editor": {
    "command": "code",
    "args": ["--wait"]
  },
  "git": {
    "autoCommit": false,
    "signCommits": false
  }
}
EOF

    echo -e "${GREEN}Config created at: $CONFIG_DIR/config.json${NC}"
fi

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "To use OpenCode with local models:"
echo "  1. Start LiteLLM: ./scripts/start-litellm.sh"
echo "  2. Run: opencode"
echo ""
echo "Or use Aider (recommended, already configured):"
echo "  aider-local"
echo ""
