#!/bin/bash
#
# Master Setup Script for Local LLM Coding Environment
# =====================================================
#
# This script automates the complete setup of a local LLM coding environment
# on Mac with Apple Silicon (M1/M2/M3/M4).
#
# Components installed:
#   - Ollama (local model server)
#   - LiteLLM (unified API proxy)
#   - OpenCode (CLI coding assistant)
#   - mem0 (memory/context persistence)
#   - Coding models (Qwen, DeepSeek, etc.)
#
# Usage:
#   ./scripts/master-setup.sh
#
# Author: Rashed Ahmed <rashed.ahmed@devopz.ai>
# Repository: https://github.com/devopz-ai/local-llm-coding-setup
#

set -e

# ============================================
# CONFIGURATION
# ============================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="/tmp/llm-setup-$(date +%Y%m%d-%H%M%S).log"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Default values
DEFAULT_MODEL="qwen2.5-coder:7b"
DEFAULT_LITELLM_PORT="4000"
DEFAULT_API_KEY="sk-local-llm-key"

# User selections (will be set by prompts)
SELECTED_MODELS=()
INSTALL_OPENCODE=true
INSTALL_MEM0=true
INSTALL_AIDER=true
LITELLM_PORT=""
API_KEY=""

# ============================================
# HELPER FUNCTIONS
# ============================================

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

print_header() {
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${NC}${BOLD}  $1${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    log "=== $1 ==="
}

print_step() {
    echo -e "${CYAN}▶${NC} $1"
    log "Step: $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
    log "Success: $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
    log "Warning: $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
    log "Error: $1"
}

print_info() {
    echo -e "${MAGENTA}ℹ${NC} $1"
    log "Info: $1"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# ============================================
# BANNER
# ============================================

show_banner() {
    clear
    echo -e "${CYAN}"
    cat << 'EOF'

    ╔═══════════════════════════════════════════════════════════════════╗
    ║                                                                   ║
    ║     _                    _   _     _     __  __                   ║
    ║    | |    ___   ___ __ _| | | |   | |   |  \/  |                  ║
    ║    | |   / _ \ / __/ _` | | | |   | |   | |\/| |                  ║
    ║    | |__| (_) | (_| (_| | | | |___| |___| |  | |                  ║
    ║    |_____\___/ \___\__,_|_| |_____|_____|_|  |_|                  ║
    ║                                                                   ║
    ║           Coding Setup for Mac Apple Silicon                      ║
    ║                                                                   ║
    ╠═══════════════════════════════════════════════════════════════════╣
    ║                                                                   ║
    ║   This script will set up a complete local LLM coding             ║
    ║   environment with:                                               ║
    ║                                                                   ║
    ║   • Ollama - Local model server                                   ║
    ║   • LiteLLM - Unified API gateway                                 ║
    ║   • OpenCode - AI coding assistant                                ║
    ║   • mem0 - Memory persistence                                     ║
    ║   • Coding models (Qwen, DeepSeek, etc.)                          ║
    ║                                                                   ║
    ╚═══════════════════════════════════════════════════════════════════╝

EOF
    echo -e "${NC}"
    echo -e "    ${BOLD}Repository:${NC} https://github.com/devopz-ai/local-llm-coding-setup"
    echo -e "    ${BOLD}Author:${NC} Rashed Ahmed <rashed.ahmed@devopz.ai>"
    echo ""
    echo -e "    ${YELLOW}Log file:${NC} $LOG_FILE"
    echo ""
}

# ============================================
# SYSTEM CHECKS
# ============================================

check_system() {
    print_header "System Check"

    # Check macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only."
        exit 1
    fi
    print_success "macOS detected"

    # Check Apple Silicon
    if [[ "$(uname -m)" != "arm64" ]]; then
        print_warning "Not running on Apple Silicon. Performance may vary."
    else
        print_success "Apple Silicon detected"
    fi

    # Get system info
    local chip=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
    local ram=$(sysctl -n hw.memsize 2>/dev/null | awk '{printf "%.0f", $1/1024/1024/1024}')
    local macos_version=$(sw_vers -productVersion)

    echo ""
    echo -e "    ${BOLD}Chip:${NC} $chip"
    echo -e "    ${BOLD}RAM:${NC} ${ram}GB"
    echo -e "    ${BOLD}macOS:${NC} $macos_version"
    echo ""

    # RAM recommendation
    if [[ $ram -lt 16 ]]; then
        print_warning "Less than 16GB RAM. Only small models (7B) recommended."
    elif [[ $ram -lt 32 ]]; then
        print_info "16-32GB RAM. Models up to 14B recommended."
    else
        print_success "${ram}GB RAM. Can run larger models (32B+)."
    fi

    # Check Homebrew
    if ! command_exists brew; then
        print_warning "Homebrew not installed. Will install it."
    else
        print_success "Homebrew installed"
    fi

    # Check Python
    if command_exists python3; then
        local python_version=$(python3 --version 2>&1 | awk '{print $2}')
        print_success "Python $python_version installed"
    else
        print_warning "Python3 not found. Will install it."
    fi

    echo ""
    read -p "Press Enter to continue or Ctrl+C to cancel..."
}

# ============================================
# USER CONFIGURATION
# ============================================

get_user_config() {
    print_header "Configuration"

    echo -e "${BOLD}Select components to install:${NC}"
    echo ""

    # Model selection
    echo -e "${CYAN}1. Select coding models to download:${NC}"
    echo ""
    echo "   Available models:"
    echo "   [1] qwen2.5-coder:7b    (~4.5GB)  - Fast, daily driver"
    echo "   [2] qwen2.5-coder:14b   (~9GB)    - Better quality"
    echo "   [3] qwen2.5-coder:32b   (~20GB)   - Best quality (slower)"
    echo "   [4] deepseek-coder-v2:16b (~10GB) - Great for algorithms"
    echo "   [5] codestral:22b       (~13GB)   - Good for IDE/autocomplete"
    echo ""
    read -p "   Enter model numbers (e.g., 1,2 or 1-3) [default: 1]: " model_selection
    model_selection=${model_selection:-1}

    # Parse model selection
    SELECTED_MODELS=()
    if [[ "$model_selection" == *"-"* ]]; then
        # Range selection (e.g., 1-3)
        start=$(echo "$model_selection" | cut -d'-' -f1)
        end=$(echo "$model_selection" | cut -d'-' -f2)
        for i in $(seq $start $end); do
            case $i in
                1) SELECTED_MODELS+=("qwen2.5-coder:7b") ;;
                2) SELECTED_MODELS+=("qwen2.5-coder:14b") ;;
                3) SELECTED_MODELS+=("qwen2.5-coder:32b") ;;
                4) SELECTED_MODELS+=("deepseek-coder-v2:16b") ;;
                5) SELECTED_MODELS+=("codestral:22b") ;;
            esac
        done
    else
        # Comma-separated selection (e.g., 1,2,4)
        IFS=',' read -ra nums <<< "$model_selection"
        for i in "${nums[@]}"; do
            case $i in
                1) SELECTED_MODELS+=("qwen2.5-coder:7b") ;;
                2) SELECTED_MODELS+=("qwen2.5-coder:14b") ;;
                3) SELECTED_MODELS+=("qwen2.5-coder:32b") ;;
                4) SELECTED_MODELS+=("deepseek-coder-v2:16b") ;;
                5) SELECTED_MODELS+=("codestral:22b") ;;
            esac
        done
    fi

    if [[ ${#SELECTED_MODELS[@]} -eq 0 ]]; then
        SELECTED_MODELS=("qwen2.5-coder:7b")
    fi

    echo ""
    echo -e "   ${GREEN}Selected models:${NC} ${SELECTED_MODELS[*]}"
    echo ""

    # Tool selection
    echo -e "${CYAN}2. Select tools to install:${NC}"
    echo ""
    read -p "   Install OpenCode (CLI coding assistant)? [Y/n]: " install_oc
    INSTALL_OPENCODE=$([[ "$install_oc" =~ ^[Nn]$ ]] && echo false || echo true)

    read -p "   Install Aider (AI pair programming)? [Y/n]: " install_aider
    INSTALL_AIDER=$([[ "$install_aider" =~ ^[Nn]$ ]] && echo false || echo true)

    read -p "   Install mem0 (memory persistence)? [Y/n]: " install_mem0
    INSTALL_MEM0=$([[ "$install_mem0" =~ ^[Nn]$ ]] && echo false || echo true)

    echo ""

    # LiteLLM configuration
    echo -e "${CYAN}3. LiteLLM Configuration:${NC}"
    echo ""
    read -p "   LiteLLM port [default: $DEFAULT_LITELLM_PORT]: " litellm_port
    LITELLM_PORT=${litellm_port:-$DEFAULT_LITELLM_PORT}

    read -p "   API Key [default: $DEFAULT_API_KEY]: " api_key
    API_KEY=${api_key:-$DEFAULT_API_KEY}

    echo ""

    # Confirmation
    print_header "Configuration Summary"
    echo -e "   ${BOLD}Models:${NC} ${SELECTED_MODELS[*]}"
    echo -e "   ${BOLD}OpenCode:${NC} $INSTALL_OPENCODE"
    echo -e "   ${BOLD}Aider:${NC} $INSTALL_AIDER"
    echo -e "   ${BOLD}mem0:${NC} $INSTALL_MEM0"
    echo -e "   ${BOLD}LiteLLM Port:${NC} $LITELLM_PORT"
    echo -e "   ${BOLD}API Key:${NC} $API_KEY"
    echo ""

    read -p "Proceed with installation? [Y/n]: " confirm
    if [[ "$confirm" =~ ^[Nn]$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
}

# ============================================
# INSTALLATION FUNCTIONS
# ============================================

install_homebrew() {
    print_step "Checking Homebrew..."

    if command_exists brew; then
        print_success "Homebrew already installed"
        return
    fi

    print_step "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to PATH for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    print_success "Homebrew installed"
}

install_ollama() {
    print_step "Checking Ollama..."

    if command_exists ollama; then
        local version=$(ollama --version 2>/dev/null | awk '{print $NF}')
        print_success "Ollama already installed (v$version)"
    else
        print_step "Installing Ollama..."
        brew install ollama
        print_success "Ollama installed"
    fi

    # Start Ollama if not running
    if ! curl -s http://localhost:11434/ >/dev/null 2>&1; then
        print_step "Starting Ollama service..."
        ollama serve > /tmp/ollama.log 2>&1 &
        sleep 3
    fi

    if curl -s http://localhost:11434/ >/dev/null 2>&1; then
        print_success "Ollama is running on localhost:11434"
    else
        print_error "Failed to start Ollama"
        exit 1
    fi
}

pull_models() {
    print_header "Downloading Models"

    local total=${#SELECTED_MODELS[@]}
    local count=0

    for model in "${SELECTED_MODELS[@]}"; do
        count=$((count + 1))
        print_step "[$count/$total] Pulling $model..."

        if ollama list 2>/dev/null | grep -q "$model"; then
            print_success "$model already downloaded"
        else
            ollama pull "$model"
            print_success "$model downloaded"
        fi
    done
}

install_python_packages() {
    print_header "Installing Python Packages"

    # Ensure pip is available
    if ! command_exists pip3; then
        print_step "Installing pip..."
        python3 -m ensurepip --upgrade
    fi

    # Get Python user bin path
    PYTHON_BIN=$(python3 -c "import site; print(site.USER_BASE)")/bin
    export PATH="$PATH:$PYTHON_BIN"

    # Install LiteLLM
    print_step "Installing LiteLLM..."
    pip3 install 'litellm[proxy]' -q
    print_success "LiteLLM installed"

    # Install Aider if selected
    if [[ "$INSTALL_AIDER" == "true" ]]; then
        print_step "Installing Aider..."
        pip3 install aider-chat -q 2>/dev/null || print_warning "Aider installation had warnings (may still work)"
        print_success "Aider installed"
    fi

    # Install mem0 if selected
    if [[ "$INSTALL_MEM0" == "true" ]]; then
        print_step "Installing mem0..."
        pip3 install mem0ai chromadb -q
        print_success "mem0 installed"

        # Pull embedding model
        print_step "Pulling embedding model..."
        ollama pull nomic-embed-text 2>/dev/null || true
        print_success "Embedding model ready"
    fi
}

install_opencode() {
    if [[ "$INSTALL_OPENCODE" != "true" ]]; then
        return
    fi

    print_step "Checking OpenCode..."

    if command_exists opencode; then
        local version=$(opencode --version 2>/dev/null || echo "installed")
        print_success "OpenCode already installed ($version)"
    else
        print_step "Installing OpenCode..."
        brew install opencode
        print_success "OpenCode installed"
    fi
}

# ============================================
# CONFIGURATION
# ============================================

configure_litellm() {
    print_header "Configuring LiteLLM"

    local config_dir="$HOME/.litellm"
    mkdir -p "$config_dir"

    print_step "Creating LiteLLM configuration..."

    # Build model list dynamically
    local model_config=""
    for model in "${SELECTED_MODELS[@]}"; do
        local model_name=$(echo "$model" | sed 's/:/-/g' | sed 's/\./-/g')
        model_config+="
  - model_name: $model_name
    litellm_params:
      model: ollama/$model
      api_base: http://localhost:11434
"
    done

    cat > "$config_dir/config.yaml" << EOF
# LiteLLM Configuration
# Generated by master-setup.sh on $(date)
# API Base: http://localhost:$LITELLM_PORT
# API Key: $API_KEY

model_list:
$model_config
  # Aliases for compatibility
  - model_name: gpt-4
    litellm_params:
      model: ollama/${SELECTED_MODELS[0]}
      api_base: http://localhost:11434

  - model_name: gpt-3.5-turbo
    litellm_params:
      model: ollama/${SELECTED_MODELS[0]}
      api_base: http://localhost:11434

litellm_settings:
  cache: false
  request_timeout: 300
  num_retries: 2

general_settings:
  master_key: $API_KEY
EOF

    print_success "LiteLLM config created at $config_dir/config.yaml"
}

configure_opencode() {
    if [[ "$INSTALL_OPENCODE" != "true" ]]; then
        return
    fi

    print_step "Configuring OpenCode..."

    # OpenCode uses ~/.config/opencode for configuration
    local config_dir="$HOME/.config/opencode"
    mkdir -p "$config_dir"

    # Build model entries for selected models
    local litellm_models=""
    local ollama_models=""
    for model in "${SELECTED_MODELS[@]}"; do
        local litellm_name=$(echo "$model" | sed 's/:/-/g' | sed 's/\./-/g')
        local display_name=$(echo "$model" | sed 's/:/ /g' | sed 's/\./ /g')

        # Add to LiteLLM models
        if [[ -n "$litellm_models" ]]; then
            litellm_models="$litellm_models,"
        fi
        litellm_models="$litellm_models
        \"$litellm_name\": {
          \"name\": \"$display_name (FREE via LiteLLM)\",
          \"limit\": { \"context\": 32768, \"output\": 8192 }
        }"

        # Add to Ollama models (direct)
        if [[ -n "$ollama_models" ]]; then
            ollama_models="$ollama_models,"
        fi
        ollama_models="$ollama_models
        \"$model\": {
          \"name\": \"$display_name (FREE direct)\",
          \"limit\": { \"context\": 32768, \"output\": 8192 }
        }"
    done

    # Create OpenCode config with custom providers
    cat > "$config_dir/opencode.json" << EOF
{
  "\$schema": "https://opencode.ai/config.json",
  "provider": {
    "litellm": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "LiteLLM (Local)",
      "options": {
        "baseURL": "http://localhost:$LITELLM_PORT/v1",
        "apiKey": "{env:LITELLM_API_KEY}"
      },
      "models": {$litellm_models,
        "claude-sonnet": {
          "name": "Claude 3.5 Sonnet (Bedrock)",
          "limit": { "context": 200000, "output": 8192 }
        },
        "claude-haiku": {
          "name": "Claude 3.5 Haiku (Bedrock)",
          "limit": { "context": 200000, "output": 8192 }
        }
      }
    },
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama (Direct)",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {$ollama_models
      }
    }
  }
}
EOF

    print_success "OpenCode config created at $config_dir/opencode.json"
}

configure_mem0() {
    if [[ "$INSTALL_MEM0" != "true" ]]; then
        return
    fi

    print_step "Configuring mem0..."

    local config_dir="$HOME/.mem0"
    mkdir -p "$config_dir"

    cat > "$config_dir/config.yaml" << EOF
# mem0 Configuration
# Generated by master-setup.sh

vector_store:
  provider: chroma
  config:
    collection_name: coding_memory
    path: ~/.mem0/chroma_db

llm:
  provider: ollama
  config:
    model: ${SELECTED_MODELS[0]}
    ollama_base_url: http://localhost:11434
    temperature: 0.1

embedder:
  provider: ollama
  config:
    model: nomic-embed-text
    ollama_base_url: http://localhost:11434
EOF

    print_success "mem0 config created"
}

configure_shell() {
    print_step "Configuring shell aliases..."

    local shell_rc="$HOME/.zshrc"
    local python_bin=$(python3 -c "import site; print(site.USER_BASE)")/bin

    # Check if already configured
    if grep -q "# Local LLM Setup" "$shell_rc" 2>/dev/null; then
        print_info "Shell already configured"
        return
    fi

    # Get the first model name formatted for LiteLLM
    local first_model_name=$(echo "${SELECTED_MODELS[0]}" | sed 's/:/-/g' | sed 's/\./-/g')

    cat >> "$shell_rc" << EOF

# ===== Local LLM Setup (Generated by master-setup.sh) =====
export PATH="\$PATH:$python_bin"

# Ollama
export OLLAMA_API_BASE=http://localhost:11434
export OLLAMA_NUM_PARALLEL=2
export OLLAMA_MAX_LOADED_MODELS=2

# LiteLLM API key (for OpenCode and other tools)
export LITELLM_API_KEY=$API_KEY

# Aliases
alias llm-start="$python_bin/litellm --config ~/.litellm/config.yaml --port $LITELLM_PORT"
alias llm-test="curl -s http://localhost:$LITELLM_PORT/v1/models -H 'Authorization: Bearer $API_KEY'"
EOF

    if [[ "$INSTALL_OPENCODE" == "true" ]]; then
        cat >> "$shell_rc" << EOF

# OpenCode - uses litellm provider with local models
# Usage: opencode -m litellm/<model> or opencode -m ollama/<model>
alias oc="opencode -m litellm/$first_model_name"
alias oc-fast="opencode -m litellm/$first_model_name"
alias oc-ollama="opencode -m ollama/${SELECTED_MODELS[0]}"
alias oc-claude="opencode -m litellm/claude-sonnet"
EOF
    fi

    if [[ "$INSTALL_AIDER" == "true" ]]; then
        cat >> "$shell_rc" << EOF
alias aider-local="aider --openai-api-base http://localhost:$LITELLM_PORT --openai-api-key $API_KEY --model ${SELECTED_MODELS[0]}"
EOF
    fi

    echo "# ===== End Local LLM Setup =====" >> "$shell_rc"

    print_success "Shell aliases configured in $shell_rc"
}

# ============================================
# TESTING & VALIDATION
# ============================================

start_litellm() {
    print_header "Starting LiteLLM"

    local python_bin=$(python3 -c "import site; print(site.USER_BASE)")/bin
    export PATH="$PATH:$python_bin"

    # Kill any existing LiteLLM process
    pkill -f "litellm" 2>/dev/null || true
    sleep 2

    print_step "Starting LiteLLM proxy on port $LITELLM_PORT..."

    "$python_bin/litellm" --config ~/.litellm/config.yaml --port "$LITELLM_PORT" > /tmp/litellm.log 2>&1 &
    local pid=$!

    # Wait for startup
    local max_wait=30
    local waited=0
    while [[ $waited -lt $max_wait ]]; do
        if curl -s "http://localhost:$LITELLM_PORT/health" >/dev/null 2>&1; then
            break
        fi
        sleep 1
        waited=$((waited + 1))
    done

    if curl -s "http://localhost:$LITELLM_PORT/health" >/dev/null 2>&1; then
        print_success "LiteLLM running on localhost:$LITELLM_PORT (PID: $pid)"
    else
        print_error "Failed to start LiteLLM. Check /tmp/litellm.log"
        cat /tmp/litellm.log | tail -20
        return 1
    fi
}

run_tests() {
    print_header "Testing & Validation"

    local all_passed=true

    # Test 1: Ollama
    print_step "Test 1: Ollama connectivity..."
    if curl -s http://localhost:11434/ >/dev/null 2>&1; then
        print_success "Ollama is responding"
    else
        print_error "Ollama not responding"
        all_passed=false
    fi

    # Test 2: Models installed
    print_step "Test 2: Models installed..."
    for model in "${SELECTED_MODELS[@]}"; do
        if ollama list 2>/dev/null | grep -q "$model"; then
            print_success "Model $model available"
        else
            print_error "Model $model not found"
            all_passed=false
        fi
    done

    # Test 3: LiteLLM
    print_step "Test 3: LiteLLM proxy..."
    if curl -s "http://localhost:$LITELLM_PORT/health" >/dev/null 2>&1; then
        print_success "LiteLLM is responding"
    else
        print_error "LiteLLM not responding"
        all_passed=false
    fi

    # Test 4: Model inference
    print_step "Test 4: Model inference..."
    local first_model=$(echo "${SELECTED_MODELS[0]}" | sed 's/:/-/g' | sed 's/\./-/g')
    local response=$(curl -s "http://localhost:$LITELLM_PORT/v1/chat/completions" \
        -H "Authorization: Bearer $API_KEY" \
        -H "Content-Type: application/json" \
        -d "{\"model\": \"$first_model\", \"messages\": [{\"role\": \"user\", \"content\": \"Say hello\"}], \"max_tokens\": 10}" \
        2>/dev/null)

    if echo "$response" | grep -q "content"; then
        print_success "Model inference working"
        local content=$(echo "$response" | python3 -c "import sys,json; print(json.load(sys.stdin)['choices'][0]['message']['content'][:50])" 2>/dev/null || echo "OK")
        echo -e "      ${CYAN}Response: $content${NC}"
    else
        print_error "Model inference failed"
        all_passed=false
    fi

    # Test 5: OpenCode
    if [[ "$INSTALL_OPENCODE" == "true" ]]; then
        print_step "Test 5: OpenCode..."
        if command_exists opencode; then
            local oc_version=$(opencode --version 2>/dev/null || echo "installed")
            print_success "OpenCode available ($oc_version)"
        else
            print_error "OpenCode not found"
            all_passed=false
        fi
    fi

    # Test 6: mem0
    if [[ "$INSTALL_MEM0" == "true" ]]; then
        print_step "Test 6: mem0..."
        if python3 -c "from mem0 import Memory; print('OK')" 2>/dev/null | grep -q "OK"; then
            print_success "mem0 working"
        else
            print_error "mem0 import failed"
            all_passed=false
        fi
    fi

    echo ""
    if [[ "$all_passed" == "true" ]]; then
        print_success "All tests passed!"
    else
        print_warning "Some tests failed. Check the log for details."
    fi
}

# ============================================
# FINAL SUMMARY
# ============================================

show_summary() {
    print_header "Setup Complete!"

    echo -e "${GREEN}"
    cat << 'EOF'

    ╔═══════════════════════════════════════════════════════════════╗
    ║                                                               ║
    ║                    SETUP SUCCESSFUL!                          ║
    ║                                                               ║
    ╚═══════════════════════════════════════════════════════════════╝

EOF
    echo -e "${NC}"

    echo -e "${BOLD}Your Local LLM Coding Environment is Ready!${NC}"
    echo ""
    echo -e "${CYAN}Services Running:${NC}"
    echo -e "  • Ollama:  http://localhost:11434"
    echo -e "  • LiteLLM: http://localhost:$LITELLM_PORT"
    echo ""
    echo -e "${CYAN}API Configuration:${NC}"
    echo -e "  • API Base: http://localhost:$LITELLM_PORT"
    echo -e "  • API Key:  $API_KEY"
    echo ""
    echo -e "${CYAN}Installed Models:${NC}"
    for model in "${SELECTED_MODELS[@]}"; do
        echo -e "  • $model"
    done
    echo ""
    echo -e "${CYAN}Quick Start Commands:${NC}"
    echo ""
    echo -e "  ${BOLD}# Reload shell configuration${NC}"
    echo -e "  source ~/.zshrc"
    echo ""

    if [[ "$INSTALL_OPENCODE" == "true" ]]; then
        local first_model_name=$(echo "${SELECTED_MODELS[0]}" | sed 's/:/-/g' | sed 's/\./-/g')
        echo -e "  ${BOLD}# Start OpenCode (after source ~/.zshrc)${NC}"
        echo -e "  opencode"
        echo ""
        echo -e "  ${BOLD}# Or run OpenCode with explicit env vars${NC}"
        echo -e "  OPENAI_API_BASE=http://localhost:$LITELLM_PORT \\"
        echo -e "  OPENAI_API_KEY=$API_KEY \\"
        echo -e "  OPENAI_MODEL=$first_model_name \\"
        echo -e "  opencode"
        echo ""
    fi

    if [[ "$INSTALL_AIDER" == "true" ]]; then
        echo -e "  ${BOLD}# Start Aider${NC}"
        echo -e "  aider-local"
        echo ""
    fi

    echo -e "  ${BOLD}# Test the API${NC}"
    echo -e "  curl http://localhost:$LITELLM_PORT/v1/chat/completions \\"
    echo -e "    -H \"Authorization: Bearer $API_KEY\" \\"
    echo -e "    -H \"Content-Type: application/json\" \\"
    echo -e "    -d '{\"model\": \"$(echo "${SELECTED_MODELS[0]}" | sed 's/:/-/g' | sed 's/\./-/g')\", \"messages\": [{\"role\": \"user\", \"content\": \"Hello\"}]}'"
    echo ""
    echo -e "${CYAN}Documentation:${NC}"
    echo -e "  • README: $PROJECT_DIR/README.md"
    echo -e "  • Docs:   $PROJECT_DIR/docs/"
    echo -e "  • Logs:   $LOG_FILE"
    echo ""
    echo -e "${YELLOW}Note: Run 'source ~/.zshrc' to load the new aliases.${NC}"
    echo ""
}

# ============================================
# MAIN
# ============================================

main() {
    # Initialize log
    echo "Local LLM Setup Log - $(date)" > "$LOG_FILE"

    show_banner

    read -p "Press Enter to start setup or Ctrl+C to cancel..."

    check_system
    get_user_config

    print_header "Installing Components"
    install_homebrew
    install_ollama
    pull_models
    install_python_packages
    install_opencode

    print_header "Configuring Components"
    configure_litellm
    configure_opencode
    configure_mem0
    configure_shell

    start_litellm
    run_tests
    show_summary
}

# Run main
main "$@"
