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
