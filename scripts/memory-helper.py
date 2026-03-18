#!/usr/bin/env python3
"""
Memory helper for AI coding assistants
Each project's memories are stored in ~/.mem0/projects/<project_name>/

Usage:
  ./memory-helper.py add "This project uses FastAPI"
  ./memory-helper.py search "What framework?"
  ./memory-helper.py list
  ./memory-helper.py context
  ./memory-helper.py clear
  ./memory-helper.py projects   # List all projects with memories
"""

import sys
import os
from mem0 import Memory

def get_project_name():
    """Get project name based on current directory"""
    cwd = os.getcwd()
    return os.path.basename(cwd)

def get_config(project_name):
    """Get mem0 config with project-specific storage path"""
    project_path = os.path.expanduser(f"~/.mem0/projects/{project_name}")
    os.makedirs(project_path, exist_ok=True)

    return {
        "vector_store": {
            "provider": "chroma",
            "config": {
                "collection_name": f"memory_{project_name}",
                "path": project_path
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

def get_user_id(project_name):
    """Get user ID based on project"""
    return f"project:{project_name}"

def list_projects():
    """List all projects with stored memories"""
    projects_dir = os.path.expanduser("~/.mem0/projects")
    if not os.path.exists(projects_dir):
        print("No projects with memories found.")
        return

    projects = [d for d in os.listdir(projects_dir)
                if os.path.isdir(os.path.join(projects_dir, d))]

    if projects:
        print("📁 Projects with memories:")
        for p in sorted(projects):
            project_path = os.path.join(projects_dir, p)
            # Get size of project memory
            size = sum(os.path.getsize(os.path.join(dirpath, filename))
                      for dirpath, dirnames, filenames in os.walk(project_path)
                      for filename in filenames)
            size_kb = size / 1024
            print(f"  - {p} ({size_kb:.1f} KB)")
        print(f"\nMemory location: {projects_dir}/")
    else:
        print("No projects with memories found.")

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    command = sys.argv[1]

    # Special command that doesn't need project context
    if command == "projects":
        list_projects()
        return

    project_name = get_project_name()
    config = get_config(project_name)
    memory = Memory.from_config(config)
    user_id = get_user_id(project_name)

    if command == "add":
        if len(sys.argv) < 3:
            print("Usage: memory-helper.py add 'memory text'")
            sys.exit(1)
        text = " ".join(sys.argv[2:])
        result = memory.add(text, user_id=user_id)
        print(f"✅ Memory added to [{project_name}]: {text[:50]}...")
        print(f"   Stored in: ~/.mem0/projects/{project_name}/")

    elif command == "search":
        if len(sys.argv) < 3:
            print("Usage: memory-helper.py search 'query'")
            sys.exit(1)
        query = " ".join(sys.argv[2:])
        results = memory.search(query, user_id=user_id, limit=5)
        memories = results.get('results', []) if isinstance(results, dict) else results
        if memories:
            print(f"📚 Found memories in [{project_name}]:")
            for r in memories:
                print(f"  - {r.get('memory', str(r))}")
        else:
            print(f"No memories found in [{project_name}].")

    elif command == "list":
        result = memory.get_all(user_id=user_id)
        memories = result.get('results', []) if isinstance(result, dict) else result
        if memories:
            print(f"📚 All memories for [{project_name}]:")
            for m in memories:
                mem_text = m.get('memory', str(m))[:60]
                mem_id = m.get('id', 'unknown')[:8]
                print(f"  [{mem_id}] {mem_text}...")
            print(f"\n   Stored in: ~/.mem0/projects/{project_name}/")
        else:
            print(f"No memories stored for [{project_name}].")

    elif command == "clear":
        result = memory.get_all(user_id=user_id)
        memories = result.get('results', []) if isinstance(result, dict) else result
        count = len(memories)
        for m in memories:
            memory.delete(m.get('id'))
        print(f"🗑️  Cleared {count} memories for [{project_name}]")

    elif command == "context":
        # Get context for current project to use with LLM
        result = memory.get_all(user_id=user_id)
        memories = result.get('results', []) if isinstance(result, dict) else result
        if memories:
            print(f"# Project Context for [{project_name}]\n")
            for m in memories:
                print(f"- {m.get('memory', str(m))}")
        else:
            print(f"# No stored context for [{project_name}]")

    else:
        print(f"Unknown command: {command}")
        print(__doc__)
        sys.exit(1)

if __name__ == "__main__":
    main()
