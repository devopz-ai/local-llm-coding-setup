# Troubleshooting Guide

Common issues and solutions for the local LLM coding setup.

## Table of Contents

1. [Ollama Issues](#ollama-issues)
2. [Model Issues](#model-issues)
3. [Performance Issues](#performance-issues)
4. [Aider Issues](#aider-issues)
5. [Web UI Issues](#web-ui-issues)
6. [IDE Integration Issues](#ide-integration-issues)

---

## Ollama Issues

### Ollama Won't Start

**Symptoms**: `ollama serve` fails or `curl localhost:11434` times out

**Solutions**:

```bash
# Check if another instance is running
pgrep -l ollama
pkill ollama

# Check port availability
lsof -i :11434

# Start fresh
ollama serve

# Check logs
tail -f ~/.ollama/logs/server.log
```

### "Connection Refused" Errors

**Symptoms**: Tools can't connect to Ollama

**Solutions**:

```bash
# Verify Ollama is running
curl http://localhost:11434/

# If using Docker, ensure host.docker.internal is accessible
# In Docker run command, add:
# --add-host=host.docker.internal:host-gateway

# Check firewall settings
sudo pfctl -s all | grep 11434
```

### Ollama Crashes During Model Load

**Symptoms**: Ollama dies when loading large models

**Solutions**:

1. Check available memory in Activity Monitor
2. Close other memory-intensive apps
3. Try a smaller model first
4. Restart your Mac to free memory

```bash
# Free up memory
ollama stop --all
```

---

## Model Issues

### Model Download Stuck

**Symptoms**: `ollama pull` hangs or shows no progress

**Solutions**:

```bash
# Cancel and retry
# Press Ctrl+C, then:
ollama pull qwen2.5-coder:14b

# Check network connectivity
curl -I https://registry.ollama.ai

# Use a different DNS
# In System Settings > Network > Advanced > DNS
# Add 8.8.8.8 or 1.1.1.1
```

### Model Corrupted

**Symptoms**: Model loads but produces garbage output

**Solutions**:

```bash
# Remove and re-download
ollama rm qwen2.5-coder:14b
ollama pull qwen2.5-coder:14b

# Clear Ollama cache
rm -rf ~/.ollama/models/blobs/*
ollama pull qwen2.5-coder:14b
```

### Wrong Model Responses

**Symptoms**: Model gives generic or unrelated answers

**Solutions**:

1. Verify correct model is loaded: `ollama ps`
2. Check prompt formatting
3. Try lowering temperature
4. Ensure system prompt is applied

```bash
# Test model directly
ollama run qwen2.5-coder:14b "Write a Python hello world"
```

---

## Performance Issues

### Slow Generation Speed

**Symptoms**: Model generates text very slowly

**Solutions**:

```bash
# Check what's loaded
ollama ps

# Unload unused models
ollama stop qwen2.5-coder:32b

# Use smaller model
ollama run qwen2.5-coder:7b
```

**System optimizations**:

1. Close Chrome/Firefox (heavy memory users)
2. Close Docker Desktop if not needed
3. Disable Spotlight indexing temporarily
4. Check Activity Monitor for memory pressure

### High Memory Usage

**Symptoms**: System becomes sluggish, swap usage high

**Solutions**:

```bash
# Check memory usage
ollama ps

# Set auto-unload timer
export OLLAMA_KEEP_ALIVE="5m"

# Manually unload models
ollama stop qwen2.5-coder:32b
ollama stop qwen2.5-coder:14b
```

### First Query Very Slow

**Symptoms**: First request takes 30+ seconds

**Explanation**: This is normal - model needs to load into memory

**Solutions**:

1. Keep model loaded with higher `OLLAMA_KEEP_ALIVE`
2. Pre-warm model with a simple query
3. Use smaller models for quick tasks

```bash
# Pre-warm a model
echo "hi" | ollama run qwen2.5-coder:14b
```

---

## Aider Issues

### Aider Can't Find Model

**Symptoms**: "Model not found" error

**Solutions**:

```bash
# Verify model name format
aider --model ollama/qwen2.5-coder:14b
# Note: needs "ollama/" prefix

# Check model is installed
ollama list

# Set environment variable
export OLLAMA_API_BASE=http://localhost:11434
```

### Aider Hangs

**Symptoms**: Aider freezes after input

**Solutions**:

1. Check Ollama is running
2. Try a smaller model
3. Reduce context with fewer files

```bash
# Start with minimal context
aider --model ollama/qwen2.5-coder:7b --no-auto-commits
```

### Git Commit Errors in Aider

**Symptoms**: Aider fails to commit changes

**Solutions**:

```bash
# Initialize git if needed
git init
git add -A
git commit -m "Initial commit"

# Or disable auto-commits
aider --model ollama/qwen2.5-coder:14b --no-auto-commits
```

### Aider Makes Wrong Changes

**Symptoms**: Aider modifies wrong files or breaks code

**Solutions**:

1. Be more specific in your prompts
2. Only `/add` files that need changes
3. Review with `/diff` before `/commit`
4. Use `/undo` to revert bad changes

---

## Web UI Issues

### Open WebUI Won't Start (Docker)

**Symptoms**: Container fails to start

**Solutions**:

```bash
# Check Docker is running
docker info

# Check for port conflicts
lsof -i :3000

# View container logs
docker logs open-webui

# Recreate container
docker rm -f open-webui
docker run -d -p 3000:8080 \
  --add-host=host.docker.internal:host-gateway \
  -v open-webui:/app/backend/data \
  --name open-webui \
  ghcr.io/open-webui/open-webui:main
```

### Open WebUI Can't See Models

**Symptoms**: No models appear in dropdown

**Solutions**:

1. Verify Ollama is running
2. Check connection settings in Open WebUI
3. Ensure Docker can reach host

```bash
# Test from Docker container
docker exec open-webui curl http://host.docker.internal:11434/api/tags
```

### Open WebUI (pip) Errors

**Symptoms**: `open-webui serve` fails

**Solutions**:

```bash
# Upgrade
pip install --upgrade open-webui

# Check Python version (needs 3.10+)
python3 --version

# Try with Python 3.11
brew install python@3.11
python3.11 -m pip install open-webui
```

---

## IDE Integration Issues

### Continue Extension Not Working

**Symptoms**: No completions, chat doesn't respond

**Solutions**:

1. Check Ollama is running
2. Verify config file location: `~/.continue/config.json`
3. Restart VS Code after config changes

```json
// Minimal working config
{
  "models": [{
    "title": "Qwen Coder",
    "provider": "ollama",
    "model": "qwen2.5-coder:14b"
  }]
}
```

### Slow Autocomplete

**Symptoms**: Tab completion takes several seconds

**Solutions**:

1. Use 7B model for autocomplete
2. Reduce context in settings
3. Disable autocomplete, use on-demand only

```json
{
  "tabAutocompleteModel": {
    "provider": "ollama",
    "model": "qwen2.5-coder:7b"
  }
}
```

---

## General Debugging Steps

### Step 1: Verify Ollama

```bash
# Is it running?
curl http://localhost:11434/

# What models are loaded?
ollama ps

# What models are installed?
ollama list
```

### Step 2: Test Model Directly

```bash
# Simple test
ollama run qwen2.5-coder:7b "Say hello"

# Check API
curl http://localhost:11434/api/generate -d '{
  "model": "qwen2.5-coder:7b",
  "prompt": "Hello",
  "stream": false
}'
```

### Step 3: Check Logs

```bash
# Ollama logs
tail -f ~/.ollama/logs/server.log

# System logs
log show --predicate 'process == "ollama"' --last 1h
```

### Step 4: Reset Everything

```bash
# Stop all
pkill ollama

# Clear state (WARNING: removes downloaded models)
# rm -rf ~/.ollama

# Fresh start
ollama serve
ollama pull qwen2.5-coder:7b
```

---

## Getting Help

If issues persist:

1. Check [Ollama GitHub Issues](https://github.com/ollama/ollama/issues)
2. Check [Aider GitHub Issues](https://github.com/paul-gauthier/aider/issues)
3. Check [Open WebUI GitHub Issues](https://github.com/open-webui/open-webui/issues)
4. Include system info when reporting:
   - macOS version
   - Ollama version (`ollama --version`)
   - Model being used
   - Full error message
