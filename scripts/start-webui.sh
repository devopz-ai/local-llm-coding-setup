#!/bin/bash
# start-webui.sh - Start Open WebUI for chat interface
set -e

echo "=========================================="
echo "Starting Open WebUI"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Check if Ollama is running
if ! curl -s http://localhost:11434/ >/dev/null 2>&1; then
    echo -e "${YELLOW}Starting Ollama server...${NC}"
    ollama serve &
    sleep 3
fi

# Check which method to use
if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    echo "Docker is available. Checking for Open WebUI container..."

    if docker ps -a --format '{{.Names}}' | grep -q '^open-webui$'; then
        # Container exists
        if docker ps --format '{{.Names}}' | grep -q '^open-webui$'; then
            echo -e "${GREEN}Open WebUI is already running!${NC}"
        else
            echo "Starting existing container..."
            docker start open-webui
        fi
    else
        # Create new container
        echo "Creating Open WebUI container..."
        docker run -d -p 3000:8080 \
            --add-host=host.docker.internal:host-gateway \
            -v open-webui:/app/backend/data \
            --name open-webui \
            --restart always \
            ghcr.io/open-webui/open-webui:main
    fi

    echo ""
    echo -e "${GREEN}Open WebUI is running!${NC}"
    echo ""
    echo "Access at: http://localhost:3000"
    echo ""
    echo "First time? Create an account (stored locally only)"
    echo ""

    # Open in browser
    read -p "Open in browser? (Y/n): " response
    if [[ ! "$response" =~ ^[Nn]$ ]]; then
        open "http://localhost:3000"
    fi

elif pip3 show open-webui >/dev/null 2>&1; then
    echo "Using pip-installed Open WebUI..."
    echo ""
    echo -e "${GREEN}Starting Open WebUI...${NC}"
    echo "Access at: http://localhost:8080"
    echo ""
    echo "Press Ctrl+C to stop"
    echo ""

    # Open in browser after short delay
    (sleep 3 && open "http://localhost:8080") &

    open-webui serve

else
    echo -e "${RED}Open WebUI is not installed.${NC}"
    echo ""
    echo "Install options:"
    echo ""
    echo "Option 1 - Docker (recommended):"
    echo "  brew install --cask docker"
    echo "  # Start Docker Desktop, then re-run this script"
    echo ""
    echo "Option 2 - pip:"
    echo "  pip3 install open-webui"
    echo "  open-webui serve"
    echo ""
    exit 1
fi
