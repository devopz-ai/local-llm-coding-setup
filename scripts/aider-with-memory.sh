#!/bin/bash
# aider-with-memory.sh - Run Aider with memory context
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${CYAN}Loading memory context...${NC}"

# Get context from memory
CONTEXT=$("$SCRIPT_DIR/memory-helper.py" context 2>/dev/null || echo "")

if [ -n "$CONTEXT" ] && [ "$CONTEXT" != "# No stored context" ]; then
    echo -e "${GREEN}Found previous context:${NC}"
    echo "$CONTEXT" | head -5
    echo "..."
    echo ""

    # Create temp file with context
    CONTEXT_FILE=$(mktemp)
    echo "$CONTEXT" > "$CONTEXT_FILE"

    # Run aider with context
    aider --model ollama/qwen2.5-coder:14b \
          --message-file "$CONTEXT_FILE" \
          "$@"

    rm -f "$CONTEXT_FILE"
else
    echo -e "${YELLOW}No previous context found. Starting fresh.${NC}"
    aider --model ollama/qwen2.5-coder:14b "$@"
fi

echo ""
echo -e "${CYAN}========================================${NC}"
read -p "📝 Save session summary to memory? (y/N): " save_summary

if [[ "$save_summary" =~ ^[Yy]$ ]]; then
    read -p "Enter summary: " summary
    if [ -n "$summary" ]; then
        "$SCRIPT_DIR/memory-helper.py" add "$summary"
        echo -e "${GREEN}✅ Summary saved to memory${NC}"
    fi
fi
