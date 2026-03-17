# System Architecture

Complete architecture overview of the Local LLM Coding Setup.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                                                                  │
│                              DEVELOPER INTERFACE                                 │
│                                                                                  │
│   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐        │
│   │   Aider     │   │  OpenCode   │   │ Claude Code │   │  Open WebUI │        │
│   │   (CLI)     │   │   (CLI)     │   │   (CLI)     │   │   (Web)     │        │
│   │             │   │             │   │             │   │             │        │
│   │ • Pair prog │   │ • Terminal  │   │ • Anthropic │   │ • Chat UI   │        │
│   │ • Git integ │   │ • Coding    │   │ • Bedrock   │   │ • Multi-    │        │
│   │ • Multi-file│   │ • Simple UI │   │ • Official  │   │   model     │        │
│   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘   └──────┬──────┘        │
│          │                 │                 │                 │               │
│   ┌──────┴─────────────────┴─────────────────┴─────────────────┴──────┐        │
│   │                                                                    │        │
│   │                        VS Code / Cursor                            │        │
│   │                     ┌─────────────────┐                           │        │
│   │                     │    Continue     │                           │        │
│   │                     │   Extension     │                           │        │
│   │                     │ • Autocomplete  │                           │        │
│   │                     │ • Chat panel    │                           │        │
│   │                     │ • Inline edit   │                           │        │
│   │                     └────────┬────────┘                           │        │
│   │                              │                                     │        │
│   └──────────────────────────────┼─────────────────────────────────────┘        │
│                                  │                                              │
└──────────────────────────────────┼──────────────────────────────────────────────┘
                                   │
                                   ▼
┌──────────────────────────────────────────────────────────────────────────────────┐
│                                                                                   │
│                            MEMORY & CONTEXT LAYER                                 │
│                                                                                   │
│   ┌───────────────────────────────────────────────────────────────────────────┐  │
│   │                              mem0                                          │  │
│   │                     (Intelligent Memory Layer)                             │  │
│   │                                                                            │  │
│   │  • Automatic fact extraction from conversations                            │  │
│   │  • Semantic search for relevant context                                    │  │
│   │  • Per-project memory isolation                                            │  │
│   │  • Persistent across sessions                                              │  │
│   └────────────────────────────────┬──────────────────────────────────────────┘  │
│                                    │                                              │
│   ┌────────────────────────────────┼────────────────────────────────────────┐    │
│   │                                │                                         │    │
│   │    ┌───────────────┐    ┌──────▼──────┐    ┌───────────────┐           │    │
│   │    │   SQLite      │    │  ChromaDB   │    │ nomic-embed   │           │    │
│   │    │  (History)    │    │  (Vectors)  │    │  (Embeddings) │           │    │
│   │    │               │    │             │    │               │           │    │
│   │    │ Chat logs     │    │ Semantic    │    │ Local model   │           │    │
│   │    │ Sessions      │    │ search      │    │ 768-dim       │           │    │
│   │    └───────────────┘    └─────────────┘    └───────────────┘           │    │
│   │                                                                         │    │
│   └─────────────────────────────────────────────────────────────────────────┘    │
│                                                                                   │
└───────────────────────────────────┬───────────────────────────────────────────────┘
                                    │
                                    ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│                                                                                    │
│                              API GATEWAY LAYER                                     │
│                                                                                    │
│   ┌────────────────────────────────────────────────────────────────────────────┐  │
│   │                                                                             │  │
│   │                            LiteLLM Proxy                                    │  │
│   │                         http://localhost:4000                               │  │
│   │                                                                             │  │
│   │   ┌─────────────────────────────────────────────────────────────────────┐  │  │
│   │   │                        OpenAI-Compatible API                         │  │  │
│   │   │                                                                      │  │  │
│   │   │  POST /v1/chat/completions    GET /v1/models                        │  │  │
│   │   │  POST /v1/completions         GET /health                           │  │  │
│   │   │  POST /v1/embeddings          GET /spend/logs                       │  │  │
│   │   │                                                                      │  │  │
│   │   └─────────────────────────────────────────────────────────────────────┘  │  │
│   │                                                                             │  │
│   │   Features:                                                                 │  │
│   │   • Unified API for all providers                                          │  │
│   │   • Automatic model routing                                                 │  │
│   │   • Fallback configuration                                                  │  │
│   │   • Cost tracking                                                           │  │
│   │   • Request caching                                                         │  │
│   │                                                                             │  │
│   └────────────────────────────────────────────────────────────────────────────┘  │
│                                                                                    │
└─────────────────────────────────────┬──────────────────────────────────────────────┘
                                      │
                 ┌────────────────────┼────────────────────┐
                 │                    │                    │
                 ▼                    ▼                    ▼
┌────────────────────────┐ ┌────────────────────┐ ┌────────────────────────┐
│                        │ │                    │ │                        │
│    LOCAL MODELS        │ │  ENTERPRISE CLOUD  │ │    OTHER PROVIDERS     │
│       (FREE)           │ │   (AWS Bedrock)    │ │                        │
│                        │ │                    │ │                        │
│ ┌────────────────────┐ │ │ ┌────────────────┐ │ │ ┌────────────────────┐ │
│ │      Ollama        │ │ │ │   AWS Bedrock  │ │ │ │     OpenAI         │ │
│ │  localhost:11434   │ │ │ │                │ │ │ │                    │ │
│ │                    │ │ │ │ ┌────────────┐ │ │ │ │  • GPT-4           │ │
│ │ ┌────────────────┐ │ │ │ │ │  Claude    │ │ │ │ │  • GPT-3.5         │ │
│ │ │ qwen2.5-coder  │ │ │ │ │ │  3.5       │ │ │ │ │                    │ │
│ │ │ • 7B  (fast)   │ │ │ │ │ │  Sonnet    │ │ │ │ └────────────────────┘ │
│ │ │ • 14B (balanced│ │ │ │ │ └────────────┘ │ │ │                        │
│ │ │ • 32B (best)   │ │ │ │ │                │ │ │ ┌────────────────────┐ │
│ │ └────────────────┘ │ │ │ │ ┌────────────┐ │ │ │ │    Anthropic       │ │
│ │                    │ │ │ │ │  Claude    │ │ │ │ │                    │ │
│ │ ┌────────────────┐ │ │ │ │ │  3 Opus    │ │ │ │ │  • Claude API      │ │
│ │ │ deepseek-coder │ │ │ │ │ └────────────┘ │ │ │ │                    │ │
│ │ │ v2:16b         │ │ │ │ │                │ │ │ └────────────────────┘ │
│ │ └────────────────┘ │ │ │ │ ┌────────────┐ │ │ │                        │
│ │                    │ │ │ │ │  Claude    │ │ │ │ ┌────────────────────┐ │
│ │ ┌────────────────┐ │ │ │ │ │  3.5       │ │ │ │ │     Groq           │ │
│ │ │ codestral:22b  │ │ │ │ │ │  Haiku     │ │ │ │ │                    │ │
│ │ └────────────────┘ │ │ │ │ └────────────┘ │ │ │ │  • Llama 3         │ │
│ │                    │ │ │ │                │ │ │ │  • Mixtral         │ │
│ │ ┌────────────────┐ │ │ │ │ ┌────────────┐ │ │ │ └────────────────────┘ │
│ │ │ llama3.2:8b    │ │ │ │ │ │  Llama 3.1 │ │ │ │                        │
│ │ └────────────────┘ │ │ │ │ │  70B       │ │ │ │                        │
│ │                    │ │ │ │ └────────────┘ │ │ │                        │
│ └────────────────────┘ │ │ │                │ │ │                        │
│                        │ │ │ ┌────────────┐ │ │ │                        │
│ Cost: FREE             │ │ │ │  Amazon    │ │ │ │ Cost: Per token        │
│ Speed: Fast (local)    │ │ │ │  Titan     │ │ │ │ Speed: Fast (cloud)    │
│ Privacy: 100% local    │ │ │ └────────────┘ │ │ │ Privacy: API terms     │
│                        │ │ └────────────────┘ │ │                        │
│                        │ │                    │ │                        │
│                        │ │ Cost: $$ per token │ │                        │
│                        │ │ Speed: Fast        │ │                        │
│                        │ │ Privacy: Your AWS  │ │                        │
│                        │ │          account   │ │                        │
└────────────────────────┘ └────────────────────┘ └────────────────────────┘
```

## Data Flow

### 1. User Request Flow

```
User Input (code question/edit request)
         │
         ▼
┌─────────────────┐
│  CLI/IDE Tool   │  (Aider, OpenCode, Continue)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Memory Layer   │  (mem0 searches for relevant context)
│  (Optional)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ LiteLLM Proxy   │  (Routes to appropriate model)
└────────┬────────┘
         │
    ┌────┴────┐
    ▼         ▼
┌───────┐ ┌───────┐
│Ollama │ │Bedrock│
│(local)│ │(cloud)│
└───┬───┘ └───┬───┘
    │         │
    └────┬────┘
         │
         ▼
┌─────────────────┐
│   Response      │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Memory Update   │  (mem0 stores relevant facts)
└────────┬────────┘
         │
         ▼
    User Output
```

### 2. Model Selection Logic

```
┌─────────────────────────────────────────────────────┐
│                  Request Received                    │
└─────────────────────────┬───────────────────────────┘
                          │
                          ▼
              ┌───────────────────────┐
              │  Check Model in       │
              │  Request              │
              └───────────┬───────────┘
                          │
          ┌───────────────┼───────────────┐
          ▼               ▼               ▼
    ┌───────────┐   ┌───────────┐   ┌───────────┐
    │ qwen-coder│   │ claude-*  │   │ gpt-4     │
    │ deepseek  │   │           │   │ gpt-3.5   │
    │ codestral │   │           │   │ (alias)   │
    └─────┬─────┘   └─────┬─────┘   └─────┬─────┘
          │               │               │
          ▼               ▼               ▼
    ┌───────────┐   ┌───────────┐   ┌───────────┐
    │  Ollama   │   │  Bedrock  │   │  Ollama   │
    │  (FREE)   │   │  ($$)     │   │  (alias)  │
    └───────────┘   └───────────┘   └───────────┘
```

## Component Details

### Ollama (Local Model Server)

| Property | Value |
|----------|-------|
| Port | 11434 |
| Protocol | HTTP REST |
| GPU | Apple Metal (unified memory) |
| Models Path | ~/.ollama/models |

### LiteLLM (API Gateway)

| Property | Value |
|----------|-------|
| Port | 4000 |
| Protocol | OpenAI-compatible REST |
| Config | ~/.litellm/config.yaml |
| Features | Routing, fallback, caching |

### mem0 (Memory Layer)

| Property | Value |
|----------|-------|
| Vector Store | ChromaDB |
| Embeddings | nomic-embed-text (768-dim) |
| History | SQLite |
| Config | ~/.mem0/config.yaml |

### AWS Bedrock

| Property | Value |
|----------|-------|
| Region | us-west-2 |
| Auth | AWS CLI / IAM |
| Models | Claude 3.5, Llama 3.1, Titan |

## Port Reference

| Service | Port | Protocol |
|---------|------|----------|
| Ollama | 11434 | HTTP |
| LiteLLM | 4000 | HTTP |
| Open WebUI | 3000 | HTTP |
| ChromaDB | 8000 | HTTP (if standalone) |

## File Locations

| Component | Location |
|-----------|----------|
| Ollama Config | ~/.ollama/ |
| Ollama Models | ~/.ollama/models/ |
| LiteLLM Config | ~/.litellm/config.yaml |
| mem0 Config | ~/.mem0/config.yaml |
| mem0 Data | ~/.mem0/chroma_db/ |
| Continue Config | ~/.continue/config.json |
| Aider Config | ~/.aider.conf.yml |
| AWS Credentials | ~/.aws/credentials |

## Security Considerations

### Local Models (Ollama)
- All processing on-device
- No data leaves your machine
- No API keys required

### Enterprise Models (Bedrock)
- Data stays in your AWS account
- VPC endpoints available
- IAM-based access control
- CloudTrail audit logging

### Memory Layer
- Stored locally in ChromaDB
- No external transmission
- Per-project isolation available
