# Memory Management Guide for AI Coding Assistants

This guide covers solutions for maintaining conversation context and memory across sessions with AI coding tools. Memory management allows your AI assistant to remember previous conversations, project context, and learned preferences.

## Why Memory Management?

Without memory management:
- Each session starts fresh with no context
- You repeat the same explanations about your codebase
- AI doesn't remember your preferences or coding style
- Previous debugging sessions are lost

With memory management:
- AI remembers your project architecture
- Previous conversations inform current responses
- Learned preferences persist across sessions
- Accumulated knowledge improves over time

## Memory Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    AI Coding Assistant                       │
│              (Aider / OpenCode / Claude Code)               │
└─────────────────────────┬───────────────────────────────────┘
                          │
              ┌───────────┴───────────┐
              │    Memory Layer       │
              │  (mem0 / LangChain)   │
              └───────────┬───────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ Short-term    │ │ Long-term     │ │ Semantic      │
│ Memory        │ │ Memory        │ │ Memory        │
│ (session)     │ │ (persistent)  │ │ (vector DB)   │
└───────────────┘ └───────────────┘ └───────────────┘
     Chat            Facts &           Embeddings
     History         Preferences       & Search
```

## Solution 1: mem0 (Recommended)

mem0 is an open-source memory layer for LLM applications that provides intelligent memory management.

### Features
- Automatic memory extraction from conversations
- Semantic search for relevant memories
- User and session-level memory
- Works with any LLM provider

### Installation

```bash
pip install mem0ai
```

### Basic Setup

```python
from mem0 import Memory

# Initialize with local storage
memory = Memory()

# Or with configuration
config = {
    "vector_store": {
        "provider": "chroma",
        "config": {
            "collection_name": "coding_assistant",
            "path": "~/.mem0/chroma"
        }
    },
    "llm": {
        "provider": "ollama",
        "config": {
            "model": "qwen2.5-coder:7b",
            "temperature": 0.1,
            "ollama_base_url": "http://localhost:11434"
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

memory = Memory.from_config(config)
```

### Usage with Coding Assistant

```python
from mem0 import Memory
import subprocess

memory = Memory()
user_id = "developer_1"

def chat_with_memory(user_message):
    # Retrieve relevant memories
    relevant_memories = memory.search(user_message, user_id=user_id)

    # Build context from memories
    memory_context = "\n".join([m["memory"] for m in relevant_memories])

    # Create enhanced prompt
    enhanced_prompt = f"""
Previous context:
{memory_context}

Current request:
{user_message}
"""

    # Call your LLM (example with ollama)
    response = call_llm(enhanced_prompt)

    # Store new memories from conversation
    messages = [
        {"role": "user", "content": user_message},
        {"role": "assistant", "content": response}
    ]
    memory.add(messages, user_id=user_id)

    return response

# Example usage
chat_with_memory("This project uses FastAPI with SQLAlchemy ORM")
chat_with_memory("What database framework does this project use?")
# mem0 will retrieve the FastAPI/SQLAlchemy context
```

### mem0 Configuration File

Create `~/.mem0/config.yaml`:

```yaml
# mem0 Configuration for Local LLM Setup

vector_store:
  provider: chroma
  config:
    collection_name: coding_memory
    path: ~/.mem0/chroma_db

llm:
  provider: litellm
  config:
    model: qwen-coder
    api_base: http://localhost:4000
    api_key: sk-1234
    temperature: 0.1

embedder:
  provider: ollama
  config:
    model: nomic-embed-text
    ollama_base_url: http://localhost:11434

history_db:
  provider: sqlite
  config:
    path: ~/.mem0/history.db
```

### Integration Script for Aider

Create `scripts/aider-with-memory.py`:

```python
#!/usr/bin/env python3
"""
Aider wrapper with mem0 memory management
"""

import os
import sys
import subprocess
from mem0 import Memory

# Initialize memory
memory = Memory.from_config({
    "vector_store": {
        "provider": "chroma",
        "config": {
            "collection_name": "aider_memory",
            "path": os.path.expanduser("~/.mem0/aider")
        }
    },
    "llm": {
        "provider": "ollama",
        "config": {
            "model": "qwen2.5-coder:7b",
            "ollama_base_url": "http://localhost:11434"
        }
    }
})

def get_project_context():
    """Get relevant memories for current project"""
    project_dir = os.getcwd()
    project_name = os.path.basename(project_dir)

    # Search for project-specific memories
    memories = memory.search(
        f"project: {project_name}",
        user_id="aider_user",
        limit=10
    )

    if memories:
        context = "# Previous Context\n\n"
        for m in memories:
            context += f"- {m['memory']}\n"
        return context
    return ""

def save_session_summary(summary):
    """Save session summary to memory"""
    project_dir = os.getcwd()
    project_name = os.path.basename(project_dir)

    memory.add(
        f"Project {project_name}: {summary}",
        user_id="aider_user",
        metadata={"project": project_name, "type": "session_summary"}
    )

def main():
    # Get context from memory
    context = get_project_context()

    if context:
        print("📚 Loaded context from memory:")
        print(context)
        print("-" * 40)

    # Build aider command
    aider_cmd = [
        "aider",
        "--model", "ollama/qwen2.5-coder:14b"
    ]

    # Add message file with context if available
    if context:
        context_file = "/tmp/aider_context.md"
        with open(context_file, "w") as f:
            f.write(context)
        aider_cmd.extend(["--message-file", context_file])

    # Add any additional arguments
    aider_cmd.extend(sys.argv[1:])

    # Run aider
    try:
        subprocess.run(aider_cmd)
    finally:
        # Prompt for session summary
        print("\n" + "=" * 40)
        summary = input("📝 Session summary (or press Enter to skip): ").strip()
        if summary:
            save_session_summary(summary)
            print("✅ Summary saved to memory")

if __name__ == "__main__":
    main()
```

Make it executable:
```bash
chmod +x scripts/aider-with-memory.py
```

## Solution 2: LangChain Memory

LangChain provides various memory types for different use cases.

### Installation

```bash
pip install langchain langchain-community chromadb
```

### Memory Types

#### 1. Conversation Buffer Memory
Stores recent messages:

```python
from langchain.memory import ConversationBufferMemory

memory = ConversationBufferMemory()
memory.save_context(
    {"input": "This is a Python FastAPI project"},
    {"output": "I'll remember that this is a FastAPI project."}
)

# Retrieve
memory.load_memory_variables({})
```

#### 2. Conversation Summary Memory
Summarizes long conversations:

```python
from langchain.memory import ConversationSummaryMemory
from langchain_community.llms import Ollama

llm = Ollama(model="qwen2.5-coder:7b")
memory = ConversationSummaryMemory(llm=llm)
```

#### 3. Vector Store Memory
Semantic search over past conversations:

```python
from langchain.memory import VectorStoreRetrieverMemory
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OllamaEmbeddings

embeddings = OllamaEmbeddings(model="nomic-embed-text")
vectorstore = Chroma(
    collection_name="coding_memory",
    embedding_function=embeddings,
    persist_directory="~/.langchain/memory"
)

retriever = vectorstore.as_retriever(search_kwargs={"k": 5})
memory = VectorStoreRetrieverMemory(retriever=retriever)
```

### Persistent Memory Setup

```python
from langchain.memory import ConversationBufferMemory
from langchain_community.chat_message_histories import SQLChatMessageHistory

# SQLite-backed persistent memory
message_history = SQLChatMessageHistory(
    session_id="coding_session_1",
    connection_string="sqlite:///~/.langchain/chat_history.db"
)

memory = ConversationBufferMemory(
    chat_memory=message_history,
    return_messages=True
)
```

## Solution 3: ChromaDB (Vector Database)

Use ChromaDB directly for semantic memory storage.

### Installation

```bash
pip install chromadb
```

### Setup

```python
import chromadb
from chromadb.config import Settings

# Persistent storage
client = chromadb.Client(Settings(
    chroma_db_impl="duckdb+parquet",
    persist_directory="~/.chroma/coding_memory"
))

# Create collection
collection = client.get_or_create_collection(
    name="coding_context",
    metadata={"hnsw:space": "cosine"}
)
```

### Usage

```python
# Add memories
collection.add(
    documents=[
        "This project uses FastAPI with async/await patterns",
        "Database is PostgreSQL with SQLAlchemy ORM",
        "Authentication uses JWT tokens"
    ],
    metadatas=[
        {"type": "architecture", "project": "my-api"},
        {"type": "database", "project": "my-api"},
        {"type": "security", "project": "my-api"}
    ],
    ids=["arch_1", "db_1", "auth_1"]
)

# Query relevant memories
results = collection.query(
    query_texts=["How does authentication work?"],
    n_results=3
)
print(results["documents"])
```

### Integration with LiteLLM

```python
import chromadb
import requests

client = chromadb.PersistentClient(path="~/.chroma/coding")
collection = client.get_or_create_collection("memories")

def query_with_memory(user_query):
    # Get relevant memories
    results = collection.query(
        query_texts=[user_query],
        n_results=5
    )

    memories = "\n".join(results["documents"][0]) if results["documents"] else ""

    # Call LiteLLM with memory context
    response = requests.post(
        "http://localhost:4000/v1/chat/completions",
        headers={"Authorization": "Bearer sk-1234"},
        json={
            "model": "qwen-coder",
            "messages": [
                {"role": "system", "content": f"Previous context:\n{memories}"},
                {"role": "user", "content": user_query}
            ]
        }
    )

    return response.json()["choices"][0]["message"]["content"]
```

## Solution 4: Qdrant (Production Vector DB)

For larger scale or production use.

### Installation

```bash
# Via Docker
docker run -p 6333:6333 -v ~/.qdrant:/qdrant/storage qdrant/qdrant

# Python client
pip install qdrant-client
```

### Setup

```python
from qdrant_client import QdrantClient
from qdrant_client.models import VectorParams, Distance

client = QdrantClient(host="localhost", port=6333)

# Create collection
client.create_collection(
    collection_name="coding_memory",
    vectors_config=VectorParams(size=768, distance=Distance.COSINE)
)
```

## Solution 5: Built-in Tool Memory

### Aider Chat History

Aider automatically saves chat history:

```bash
# Chat history location
ls ~/.aider.chat.history.md

# Load previous chat
aider --restore-chat-history
```

### Continue.dev Context

Continue stores context in VS Code:

```json
// ~/.continue/config.json
{
  "contextProviders": [
    {
      "name": "codebase",
      "params": {
        "nRetrieve": 25,
        "nFinal": 5,
        "useReranking": true
      }
    },
    {
      "name": "docs",
      "params": {}
    }
  ]
}
```

## Unified Memory Setup Script

Create `scripts/setup-memory.sh`:

```bash
#!/bin/bash
# setup-memory.sh - Install and configure memory management
set -e

echo "=========================================="
echo "Memory Management Setup"
echo "=========================================="

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Install mem0
echo -e "${YELLOW}Installing mem0...${NC}"
pip install mem0ai

# Install ChromaDB
echo -e "${YELLOW}Installing ChromaDB...${NC}"
pip install chromadb

# Install embedding model for Ollama
echo -e "${YELLOW}Pulling embedding model...${NC}"
ollama pull nomic-embed-text

# Create directories
mkdir -p ~/.mem0
mkdir -p ~/.chroma

# Create mem0 config
cat > ~/.mem0/config.yaml << 'EOF'
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

embedder:
  provider: ollama
  config:
    model: nomic-embed-text
    ollama_base_url: http://localhost:11434
EOF

echo -e "${GREEN}Memory management setup complete!${NC}"
echo ""
echo "Usage:"
echo "  Python: from mem0 import Memory; m = Memory()"
echo "  With Aider: python scripts/aider-with-memory.py"
```

## Memory Commands Reference

### mem0 CLI

```bash
# Add memory
mem0 add "This project uses React with TypeScript" --user dev1

# Search memories
mem0 search "What framework does this use?" --user dev1

# List all memories
mem0 list --user dev1

# Delete memory
mem0 delete <memory_id>
```

### Python Quick Reference

```python
from mem0 import Memory

m = Memory()

# Add memory
m.add("Project uses FastAPI", user_id="dev1")

# Search
results = m.search("What framework?", user_id="dev1")

# Get all
all_memories = m.get_all(user_id="dev1")

# Delete
m.delete(memory_id="xxx")

# Update
m.update(memory_id="xxx", data="Updated info")
```

## Best Practices

### 1. Organize by Project

```python
# Use project name as user_id or metadata
memory.add(
    "Authentication uses OAuth2",
    user_id=f"project:{project_name}",
    metadata={"category": "security"}
)
```

### 2. Periodic Cleanup

```python
# Remove old or irrelevant memories
old_memories = memory.get_all(user_id="dev1")
for m in old_memories:
    if is_outdated(m):
        memory.delete(m["id"])
```

### 3. Categorize Memories

```python
# Use metadata for categorization
memory.add(
    "Database schema includes users, orders, products tables",
    user_id="dev1",
    metadata={
        "category": "database",
        "project": "ecommerce",
        "importance": "high"
    }
)
```

### 4. Session Summaries

```python
# At end of each session, save a summary
def save_session():
    summary = generate_summary(conversation_history)
    memory.add(
        f"Session summary: {summary}",
        user_id="dev1",
        metadata={"type": "session_summary", "date": today()}
    )
```

## Troubleshooting

### Memory Not Persisting

```bash
# Check storage directory exists
ls -la ~/.mem0/
ls -la ~/.chroma/

# Verify permissions
chmod -R 755 ~/.mem0
```

### Slow Memory Search

```python
# Reduce number of results
results = memory.search(query, limit=5)  # Instead of default

# Use more specific queries
results = memory.search(
    "FastAPI authentication",  # Specific
    # Instead of just "auth"   # Too broad
)
```

### Embedding Model Issues

```bash
# Ensure embedding model is pulled
ollama pull nomic-embed-text

# Test embedding
curl http://localhost:11434/api/embeddings -d '{
  "model": "nomic-embed-text",
  "prompt": "test"
}'
```

## Memory Helper CLI

This repository includes a convenient CLI tool for managing memories.

### Installation

The memory helper is installed automatically by `master-setup.sh`. After setup, add to `~/.zshrc`:

```bash
alias mem="~/Documents/Projects/LLM/local-llm-coding-setup/scripts/memory-helper.py"
```

### Commands

```bash
# Add memory (stored per-project based on current directory)
mem add "This project uses FastAPI with PostgreSQL"
mem add "Authentication uses JWT tokens stored in Redis"

# Search memories
mem search "what database"
mem search "authentication"

# List all memories for current project
mem list

# Get context for LLM prompt
mem context

# Clear all memories for current project
mem clear
```

### How It Works

- Memories are stored per-project (based on current directory name)
- Uses ChromaDB for vector storage at `~/.mem0/chroma_db/`
- Uses `nomic-embed-text` for local embeddings via Ollama
- Uses `qwen2.5-coder:7b` for memory extraction

### Example Workflow

```bash
cd ~/my-project

# Add context about your project
mem add "This is a Python FastAPI backend"
mem add "Uses SQLAlchemy ORM with PostgreSQL"
mem add "Auth via OAuth2 with JWT tokens"

# Later, search for relevant context
mem search "database setup"
# Returns: Uses SQLAlchemy ORM with PostgreSQL

# Get all context for AI prompt
mem context
# Returns formatted list of all memories
```

## Further Reading

- [mem0 Documentation](https://docs.mem0.ai/)
- [LangChain Memory](https://python.langchain.com/docs/modules/memory/)
- [ChromaDB Documentation](https://docs.trychroma.com/)
- [Qdrant Documentation](https://qdrant.tech/documentation/)
