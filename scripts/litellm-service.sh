#!/bin/bash
#
# Manage LiteLLM as a macOS Launch Agent (auto-start on login)
#
# Usage:
#   ./scripts/litellm-service.sh install   # Install and start
#   ./scripts/litellm-service.sh start     # Start service
#   ./scripts/litellm-service.sh stop      # Stop service
#   ./scripts/litellm-service.sh restart   # Restart service
#   ./scripts/litellm-service.sh status    # Check status
#   ./scripts/litellm-service.sh uninstall # Remove service
#   ./scripts/litellm-service.sh logs      # View logs
#
# Author: Rashed Ahmed <rashed.ahmed@devopz.ai>
#

set -e

# Configuration
SERVICE_NAME="com.devopz.litellm"
PLIST_FILE="$HOME/Library/LaunchAgents/$SERVICE_NAME.plist"
LITELLM_PORT="${LITELLM_PORT:-4000}"
LITELLM_CONFIG="$HOME/.litellm/config.yaml"
LOG_DIR="$HOME/.litellm/logs"
PYTHON_BIN=$(python3 -c "import site; print(site.USER_BASE)")/bin

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }
print_info() { echo -e "${CYAN}ℹ${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }

# Check if litellm is installed
check_litellm() {
    if [[ ! -f "$PYTHON_BIN/litellm" ]]; then
        print_error "LiteLLM not found at $PYTHON_BIN/litellm"
        print_info "Install with: pip3 install --user litellm"
        exit 1
    fi
}

# Check if config exists
check_config() {
    if [[ ! -f "$LITELLM_CONFIG" ]]; then
        print_error "LiteLLM config not found at $LITELLM_CONFIG"
        print_info "Run the master setup script first"
        exit 1
    fi
}

# Create the launchd plist file
create_plist() {
    mkdir -p "$HOME/Library/LaunchAgents"
    mkdir -p "$LOG_DIR"

    cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$SERVICE_NAME</string>

    <key>ProgramArguments</key>
    <array>
        <string>$PYTHON_BIN/litellm</string>
        <string>--config</string>
        <string>$LITELLM_CONFIG</string>
        <string>--port</string>
        <string>$LITELLM_PORT</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <dict>
        <key>SuccessfulExit</key>
        <false/>
    </dict>

    <key>StandardOutPath</key>
    <string>$LOG_DIR/litellm.log</string>

    <key>StandardErrorPath</key>
    <string>$LOG_DIR/litellm-error.log</string>

    <key>WorkingDirectory</key>
    <string>$HOME</string>

    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>/usr/local/bin:/usr/bin:/bin:$PYTHON_BIN</string>
        <key>HOME</key>
        <string>$HOME</string>
    </dict>

    <key>ThrottleInterval</key>
    <integer>10</integer>
</dict>
</plist>
EOF

    print_success "Created launchd plist at $PLIST_FILE"
}

# Install and load the service
install_service() {
    check_litellm
    check_config

    echo ""
    echo "Installing LiteLLM as a macOS Launch Agent..."
    echo ""

    # Stop existing service if running
    if launchctl list | grep -q "$SERVICE_NAME" 2>/dev/null; then
        print_info "Stopping existing service..."
        launchctl unload "$PLIST_FILE" 2>/dev/null || true
    fi

    # Create plist
    create_plist

    # Load the service
    launchctl load "$PLIST_FILE"
    print_success "Service loaded"

    # Wait for startup
    sleep 2

    # Check if running
    if curl -s "http://localhost:$LITELLM_PORT/health" > /dev/null 2>&1; then
        print_success "LiteLLM is running on port $LITELLM_PORT"
    else
        print_warning "Service loaded but may still be starting..."
        print_info "Check logs: tail -f $LOG_DIR/litellm.log"
    fi

    echo ""
    print_success "Installation complete!"
    echo ""
    echo "LiteLLM will now start automatically on login."
    echo ""
    echo "Commands:"
    echo "  $0 start    - Start service"
    echo "  $0 stop     - Stop service"
    echo "  $0 restart  - Restart service"
    echo "  $0 status   - Check status"
    echo "  $0 logs     - View logs"
    echo ""
}

# Start the service
start_service() {
    if launchctl list | grep -q "$SERVICE_NAME" 2>/dev/null; then
        print_warning "Service already running"
    else
        if [[ -f "$PLIST_FILE" ]]; then
            launchctl load "$PLIST_FILE"
            print_success "Service started"
        else
            print_error "Service not installed. Run: $0 install"
            exit 1
        fi
    fi
}

# Stop the service
stop_service() {
    if launchctl list | grep -q "$SERVICE_NAME" 2>/dev/null; then
        launchctl unload "$PLIST_FILE"
        print_success "Service stopped"
    else
        print_info "Service not running"
    fi
}

# Restart the service
restart_service() {
    stop_service
    sleep 2
    start_service
}

# Check service status
check_status() {
    echo ""
    echo "LiteLLM Service Status"
    echo "======================"
    echo ""

    # Check if plist exists
    if [[ -f "$PLIST_FILE" ]]; then
        print_success "Service installed: $PLIST_FILE"
    else
        print_error "Service not installed"
        return 1
    fi

    # Check if loaded
    if launchctl list | grep -q "$SERVICE_NAME" 2>/dev/null; then
        print_success "Service loaded in launchd"

        # Get PID
        local pid=$(launchctl list | grep "$SERVICE_NAME" | awk '{print $1}')
        if [[ "$pid" != "-" && -n "$pid" ]]; then
            print_success "Process running (PID: $pid)"
        fi
    else
        print_warning "Service not loaded"
    fi

    # Check if responding
    echo ""
    if curl -s "http://localhost:$LITELLM_PORT/health" > /dev/null 2>&1; then
        print_success "API responding on port $LITELLM_PORT"

        # Show available models
        echo ""
        echo "Available models:"
        curl -s "http://localhost:$LITELLM_PORT/v1/models" \
            -H "Authorization: Bearer sk-litellm-master-key-change-me" 2>/dev/null | \
            python3 -c "import sys,json; [print(f'  - {m[\"id\"]}') for m in json.load(sys.stdin).get('data',[])]" 2>/dev/null || \
            print_warning "Could not fetch models"
    else
        print_error "API not responding on port $LITELLM_PORT"
        print_info "Check logs: tail -f $LOG_DIR/litellm.log"
    fi

    echo ""
}

# View logs
view_logs() {
    if [[ -f "$LOG_DIR/litellm.log" ]]; then
        echo "Showing LiteLLM logs (Ctrl+C to exit)..."
        echo ""
        tail -f "$LOG_DIR/litellm.log"
    else
        print_error "Log file not found: $LOG_DIR/litellm.log"
        print_info "Service may not be installed or hasn't started yet"
    fi
}

# Uninstall the service
uninstall_service() {
    echo ""
    echo "Uninstalling LiteLLM service..."
    echo ""

    # Stop if running
    if launchctl list | grep -q "$SERVICE_NAME" 2>/dev/null; then
        launchctl unload "$PLIST_FILE" 2>/dev/null || true
        print_success "Service stopped"
    fi

    # Remove plist
    if [[ -f "$PLIST_FILE" ]]; then
        rm "$PLIST_FILE"
        print_success "Removed $PLIST_FILE"
    fi

    print_success "Service uninstalled"
    echo ""
}

# Show usage
usage() {
    echo "LiteLLM Service Manager"
    echo ""
    echo "Usage: $0 <command>"
    echo ""
    echo "Commands:"
    echo "  install   Install and start the service (auto-starts on login)"
    echo "  start     Start the service"
    echo "  stop      Stop the service"
    echo "  restart   Restart the service"
    echo "  status    Check service status"
    echo "  logs      View service logs (tail -f)"
    echo "  uninstall Remove the service"
    echo ""
    echo "Examples:"
    echo "  $0 install    # First time setup"
    echo "  $0 status     # Check if running"
    echo "  $0 restart    # After config changes"
    echo ""
}

# Main
case "${1:-}" in
    install)
        install_service
        ;;
    start)
        start_service
        ;;
    stop)
        stop_service
        ;;
    restart)
        restart_service
        ;;
    status)
        check_status
        ;;
    logs)
        view_logs
        ;;
    uninstall)
        uninstall_service
        ;;
    -h|--help|help|"")
        usage
        ;;
    *)
        print_error "Unknown command: $1"
        usage
        exit 1
        ;;
esac
