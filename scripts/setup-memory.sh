#!/bin/bash
# setup-memory.sh - Install and configure memory management for AI coding tools
set -e

echo "=========================================="
echo "Memory Management Setup"
echo "=========================================="
echo ""
echo "This will install tools for persistent conversation memory:"
echo "  - mem0: Intelligent memory layer for LLMs"
echo "  - ChromaDB: Vector database for semantic search"
echo "  - nomic-embed-text: Local embedding model"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

# Check Python
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}Python3 not found. Please install Python first.${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
echo -e "${GREEN}Python installed: $PYTHON_VERSION${NC}"

# Check Ollama
if ! curl -s http://localhost:11434/ > /dev/null 2>&1; then
    echo -e "${YELLOW}Ollama not running. Starting...${NC}"
    ollama serve &
    sleep 3
fi

echo ""
echo "=========================================="
echo "Installing Python Packages"
echo "=========================================="
echo ""

# Install mem0
echo -e "${YELLOW}Installing mem0...${NC}"
pip3 install mem0ai

# Install ChromaDB
echo -e "${YELLOW}Installing ChromaDB...${NC}"
pip3 install chromadb

# Install additional dependencies
echo -e "${YELLOW}Installing additional dependencies...${NC}"
pip3 install sentence-transformers

echo -e "${GREEN}Python packages installed!${NC}"

echo ""
echo "=========================================="
echo "Pulling Embedding Model"
echo "=========================================="
echo ""

# Pull embedding model
echo -e "${YELLOW}Pulling nomic-embed-text model...${NC}"
ollama pull nomic-embed-text

echo -e "${GREEN}Embedding model ready!${NC}"

echo ""
echo "=========================================="
echo "Creating Configuration"
echo "=========================================="
echo ""

# Create directories
mkdir -p ~/.mem0
mkdir -p ~/.chroma

# Create mem0 config
cat > ~/.mem0/config.yaml << 'EOF'
# mem0 Configuration for Local LLM Coding Setup
# Memory is stored locally using ChromaDB

vector_store:
  provider: chroma
  config:
    collection_name: coding_memory
    path: ~/.mem0/chroma_db

llm:
  provider: ollama
  config:
    model: qwen2.5-coder:7b
    ollama_base_url: http://localhost:11434
    temperature: 0.1
    max_tokens: 1000

embedder:
  provider: ollama
  config:
    model: nomic-embed-text
    ollama_base_url: http://localhost:11434

# History database for conversation tracking
history_db:
  provider: sqlite
  config:
    path: ~/.mem0/history.db
EOF

echo -e "${GREEN}Config created at: ~/.mem0/config.yaml${NC}"

# Create Python helper script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cat > "$SCRIPT_DIR/memory-helper.py" << 'PYTHON_EOF'
#!/usr/bin/env python3
"""
Memory helper for AI coding assistants
Usage:
  ./memory-helper.py add "This project uses FastAPI"
  ./memory-helper.py search "What framework?"
  ./memory-helper.py list
  ./memory-helper.py clear
"""

import sys
import os
from mem0 import Memory

# Initialize memory with local config
config = {
    "vector_store": {
        "provider": "chroma",
        "config": {
            "collection_name": "coding_memory",
            "path": os.path.expanduser("~/.mem0/chroma_db")
        }
    },
    "llm": {
        "provider": "ollama",
        "config": {
            "model": "qwen2.5-coder:7b",
            "ollama_base_url": "http://localhost:11434",
            "temperature": 0.1
        }
    },
    "embedder": {
        "provider": "ollama",
        "config": {
            "model": "nomic-embed-text",
            "ollama_base_url": "http://localhost:11434"
        }
    }
}

def get_user_id():
    """Get user ID based on current project"""
    cwd = os.getcwd()
    project_name = os.path.basename(cwd)
    return f"project:{project_name}"

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]
    memory = Memory.from_config(config)
    user_id = get_user_id()

    if command == "add":
        if len(sys.argv) < 3:
            print("Usage: memory-helper.py add 'memory text'")
            sys.exit(1)
        text = " ".join(sys.argv[2:])
        result = memory.add(text, user_id=user_id)
        print(f"✅ Memory added: {text[:50]}...")

    elif command == "search":
        if len(sys.argv) < 3:
            print("Usage: memory-helper.py search 'query'")
            sys.exit(1)
        query = " ".join(sys.argv[2:])
        results = memory.search(query, user_id=user_id, limit=5)
        if results:
            print("📚 Found memories:")
            for r in results:
                print(f"  - {r['memory']}")
        else:
            print("No memories found.")

    elif command == "list":
        memories = memory.get_all(user_id=user_id)
        if memories:
            print(f"📚 All memories for {user_id}:")
            for m in memories:
                print(f"  [{m['id'][:8]}] {m['memory'][:60]}...")
        else:
            print("No memories stored.")

    elif command == "clear":
        memories = memory.get_all(user_id=user_id)
        for m in memories:
            memory.delete(m['id'])
        print(f"🗑️  Cleared all memories for {user_id}")

    elif command == "context":
        # Get context for current project to use with LLM
        memories = memory.get_all(user_id=user_id)
        if memories:
            print("# Project Context from Memory\n")
            for m in memories:
                print(f"- {m['memory']}")
        else:
            print("# No stored context")

    else:
        print(f"Unknown command: {command}")
        print(__doc__)
        sys.exit(1)

if __name__ == "__main__":
    main()
PYTHON_EOF

chmod +x "$SCRIPT_DIR/memory-helper.py"
echo -e "${GREEN}Created: $SCRIPT_DIR/memory-helper.py${NC}"

# Create aider wrapper with memory
cat > "$SCRIPT_DIR/aider-with-memory.sh" << 'BASH_EOF'
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
BASH_EOF

chmod +x "$SCRIPT_DIR/aider-with-memory.sh"
echo -e "${GREEN}Created: $SCRIPT_DIR/aider-with-memory.sh${NC}"

# Add shell aliases
ZSHRC="$HOME/.zshrc"
if ! grep -q "# Memory management aliases" "$ZSHRC" 2>/dev/null; then
    cat >> "$ZSHRC" << 'EOF'

# ===== Memory management aliases =====
alias mem="memory-helper.py"
alias mem-add="memory-helper.py add"
alias mem-search="memory-helper.py search"
alias mem-list="memory-helper.py list"
alias mem-clear="memory-helper.py clear"
alias aider-mem="aider-with-memory.sh"
# =====================================
EOF
    echo -e "${GREEN}Aliases added to $ZSHRC${NC}"
fi

echo ""
echo "=========================================="
echo -e "${GREEN}Setup Complete!${NC}"
echo "=========================================="
echo ""
echo -e "${CYAN}Memory Commands:${NC}"
echo ""
echo "  mem add 'This project uses FastAPI'   # Add memory"
echo "  mem search 'framework'                 # Search memories"
echo "  mem list                               # List all memories"
echo "  mem clear                              # Clear project memories"
echo "  mem context                            # Get context for LLM"
echo ""
echo -e "${CYAN}Aider with Memory:${NC}"
echo ""
echo "  aider-mem                              # Start Aider with memory"
echo "  ./scripts/aider-with-memory.sh        # Same as above"
echo ""
echo -e "${CYAN}Python Usage:${NC}"
echo ""
echo "  from mem0 import Memory"
echo "  m = Memory()"
echo "  m.add('Project uses React', user_id='my-project')"
echo "  m.search('What framework?', user_id='my-project')"
echo ""
echo -e "${YELLOW}Note: Run 'source ~/.zshrc' to load aliases${NC}"
echo ""
