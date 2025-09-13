#!/bin/bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   🐍 MCP CONTEXT FORGE - Automated Setup Script
#   (An enterprise-ready Model Context Protocol Gateway)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#
# Description: Automated setup script for MCP Gateway project
# Usage: ./setup-mcp-gateway.sh [command]
# Commands: setup, start, stop, restart, status, clean, help
#
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

set -euo pipefail

# Configuration
PROJECT_NAME="mcpgateway"
VENV_DIR="$HOME/.venv/$PROJECT_NAME"
SERVER_HOST="0.0.0.0"
SERVER_PORT="8000"
REQUIRED_PYTHON_VERSION="3.11"
PIDFILE="/tmp/mcp-gateway.pid"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${PURPLE}🔸 $1${NC}"
}

log_header() {
    echo -e "${CYAN}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${NC}"
}

# Utility functions
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

version_compare() {
    printf '%s\n%s\n' "$2" "$1" | sort -V -C
}

get_python_version() {
    local python_cmd="$1"
    if command_exists "$python_cmd"; then
        "$python_cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')"
    else
        echo "0.0.0"
    fi
}

find_suitable_python() {
    local python_candidates=("python3.13" "python3.12" "python3.11" "python3")
    
    for python_cmd in "${python_candidates[@]}"; do
        if command_exists "$python_cmd"; then
            local version=$(get_python_version "$python_cmd")
            if version_compare "$version" "$REQUIRED_PYTHON_VERSION"; then
                echo "$python_cmd"
                return 0
            fi
        fi
    done
    
    return 1
}

check_dependencies() {
    log_step "Checking system dependencies..."
    
    local missing_deps=()
    
    # Check for required commands
    if ! command_exists "make"; then
        missing_deps+=("make")
    fi
    
    if ! command_exists "curl"; then
        missing_deps+=("curl")
    fi
    
    # Check Python version
    if ! PYTHON_CMD=$(find_suitable_python); then
        log_error "Python $REQUIRED_PYTHON_VERSION+ is required but not found"
        log_info "Please install Python $REQUIRED_PYTHON_VERSION or higher"
        exit 1
    fi
    
    local python_version=$(get_python_version "$PYTHON_CMD")
    log_success "Found suitable Python: $PYTHON_CMD (version $python_version)"
    
    # Check for UV
    if ! command_exists "uv"; then
        log_warning "UV package manager not found. Will install it."
        install_uv
    else
        log_success "UV package manager found"
    fi
    
    if [ ${#missing_deps[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing_deps[*]}"
        log_info "Please install the missing dependencies and run the script again"
        exit 1
    fi
    
    log_success "All dependencies satisfied"
}

install_uv() {
    log_step "Installing UV package manager..."
    if command_exists "curl"; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
    else
        log_error "curl is required to install UV"
        exit 1
    fi
}

setup_virtual_environment() {
    log_step "Setting up virtual environment..."
    
    if [ -d "$VENV_DIR" ]; then
        log_warning "Virtual environment already exists at $VENV_DIR"
        read -p "Do you want to recreate it? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            log_step "Removing existing virtual environment..."
            rm -rf "$VENV_DIR"
        else
            log_info "Using existing virtual environment"
            return 0
        fi
    fi
    
    log_step "Creating virtual environment with $PYTHON_CMD..."
    "$PYTHON_CMD" -m venv "$VENV_DIR"
    
    # Verify the virtual environment has the correct Python version
    local venv_python_version=$("$VENV_DIR/bin/python" --version 2>&1 | awk '{print $2}')
    log_success "Virtual environment created with Python $venv_python_version"
}

install_dependencies() {
    log_step "Installing project dependencies..."
    
    # Upgrade pip, setuptools, and install uv in the virtual environment
    "$VENV_DIR/bin/python" -m pip install --upgrade pip setuptools uv
    
    # Install the project with development dependencies
    log_step "Installing MCP Gateway with development dependencies..."
    "$VENV_DIR/bin/python" -m uv pip install ".[dev]"
    
    log_success "Dependencies installed successfully"
}

setup_configuration() {
    log_step "Setting up configuration..."
    
    if [ ! -f ".env" ]; then
        if [ -f ".env.example" ]; then
            cp .env.example .env
            log_success "Created .env file from .env.example"
        else
            log_error ".env.example file not found"
            exit 1
        fi
    else
        log_info ".env file already exists"
    fi
    
    # Display current configuration
    log_info "Current configuration:"
    echo "  - Host: $SERVER_HOST"
    echo "  - Port: $SERVER_PORT"
    echo "  - Environment: development"
    echo "  - Database: SQLite (./mcp.db)"
    echo "  - Auth: admin/changeme"
}

start_server() {
    if is_server_running; then
        log_warning "Server is already running (PID: $(cat $PIDFILE))"
        return 0
    fi
    
    log_step "Starting MCP Gateway server..."
    
    # Start the server in the background
    nohup "$VENV_DIR/bin/uvicorn" mcpgateway.main:app \
        --host "$SERVER_HOST" \
        --port "$SERVER_PORT" \
        --reload > mcp-gateway.log 2>&1 &
    
    local server_pid=$!
    echo $server_pid > "$PIDFILE"
    
    # Wait for server to start
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -sf "http://localhost:$SERVER_PORT/health" >/dev/null 2>&1; then
            log_success "Server started successfully (PID: $server_pid)"
            log_info "Server is running at: http://localhost:$SERVER_PORT"
            log_info "Admin UI: http://localhost:$SERVER_PORT (admin/changeme)"
            log_info "API Documentation: http://localhost:$SERVER_PORT/docs"
            log_info "Logs: $(pwd)/mcp-gateway.log"
            return 0
        fi
        
        sleep 1
        ((attempt++))
    done
    
    log_error "Server failed to start within 30 seconds"
    stop_server
    exit 1
}

stop_server() {
    if [ -f "$PIDFILE" ]; then
        local pid=$(cat "$PIDFILE")
        if kill -0 "$pid" 2>/dev/null; then
            log_step "Stopping server (PID: $pid)..."
            kill "$pid"
            
            # Wait for graceful shutdown
            local attempt=0
            while [ $attempt -lt 10 ] && kill -0 "$pid" 2>/dev/null; do
                sleep 1
                ((attempt++))
            done
            
            # Force kill if still running
            if kill -0 "$pid" 2>/dev/null; then
                log_warning "Force killing server..."
                kill -9 "$pid"
            fi
            
            log_success "Server stopped"
        fi
        rm -f "$PIDFILE"
    else
        log_info "Server is not running"
    fi
}

is_server_running() {
    if [ -f "$PIDFILE" ]; then
        local pid=$(cat "$PIDFILE")
        kill -0 "$pid" 2>/dev/null
    else
        false
    fi
}

restart_server() {
    log_step "Restarting server..."
    stop_server
    sleep 2
    start_server
}

show_status() {
    log_header "MCP Gateway Status"
    
    if is_server_running; then
        local pid=$(cat "$PIDFILE")
        log_success "Server is running (PID: $pid)"
        
        # Check if server is responding
        if curl -sf "http://localhost:$SERVER_PORT/health" >/dev/null 2>&1; then
            log_success "Server is responding to health checks"
        else
            log_warning "Server process exists but not responding"
        fi
        
        echo
        log_info "Access URLs:"
        echo "  🌐 Main Server: http://localhost:$SERVER_PORT"
        echo "  🔧 Admin UI: http://localhost:$SERVER_PORT (admin/changeme)"
        echo "  📚 API Docs: http://localhost:$SERVER_PORT/docs"
        echo "  ❤️  Health Check: http://localhost:$SERVER_PORT/health"
        
    else
        log_info "Server is not running"
    fi
    
    echo
    log_info "Environment Info:"
    echo "  📁 Project Directory: $(pwd)"
    echo "  🐍 Virtual Environment: $VENV_DIR"
    echo "  📄 Log File: $(pwd)/mcp-gateway.log"
    echo "  ⚙️  Configuration: $(pwd)/.env"
}

clean_environment() {
    log_step "Cleaning up environment..."
    
    # Stop server if running
    stop_server
    
    # Ask for confirmation
    log_warning "This will remove:"
    echo "  - Virtual environment ($VENV_DIR)"
    echo "  - Database files (*.db, *.sqlite*)"
    echo "  - Log files"
    echo "  - PID files"
    echo
    read -p "Are you sure? (y/N): " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # Remove virtual environment
        if [ -d "$VENV_DIR" ]; then
            rm -rf "$VENV_DIR"
            log_success "Removed virtual environment"
        fi
        
        # Remove database files
        find . -name "*.db" -o -name "*.sqlite*" | xargs rm -f 2>/dev/null || true
        log_success "Removed database files"
        
        # Remove log files
        rm -f mcp-gateway.log nohup.out
        log_success "Removed log files"
        
        # Remove PID file
        rm -f "$PIDFILE"
        
        log_success "Environment cleaned successfully"
    else
        log_info "Clean operation cancelled"
    fi
}

show_help() {
    cat << EOF
🐍 MCP Context Forge - Automated Setup Script

USAGE:
    ./setup-mcp-gateway.sh [COMMAND]

COMMANDS:
    setup      Complete setup: dependencies, venv, config, and start server
    start      Start the MCP Gateway server
    stop       Stop the MCP Gateway server  
    restart    Restart the MCP Gateway server
    status     Show server status and connection info
    clean      Clean up virtual environment and generated files
    help       Show this help message

EXAMPLES:
    ./setup-mcp-gateway.sh setup     # Full setup and start
    ./setup-mcp-gateway.sh start     # Start server
    ./setup-mcp-gateway.sh status    # Check status
    ./setup-mcp-gateway.sh stop      # Stop server

CONFIGURATION:
    Default server: http://localhost:8000
    Admin credentials: admin/changeme
    Configuration file: .env

For more information, visit: https://github.com/IBM/mcp-context-forge

EOF
}

main() {
    local command="${1:-setup}"
    
    case "$command" in
        "setup")
            log_header "🚀 MCP Gateway Complete Setup"
            check_dependencies
            setup_virtual_environment
            install_dependencies
            setup_configuration
            start_server
            echo
            show_status
            ;;
        "start")
            log_header "🚀 Starting MCP Gateway"
            start_server
            ;;
        "stop")
            log_header "🛑 Stopping MCP Gateway"
            stop_server
            ;;
        "restart")
            log_header "🔄 Restarting MCP Gateway"
            restart_server
            ;;
        "status")
            show_status
            ;;
        "clean")
            log_header "🧹 Cleaning Environment"
            clean_environment
            ;;
        "help"|"-h"|"--help")
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            echo
            show_help
            exit 1
            ;;
    esac
}

# Change to script directory
cd "$(dirname "$0")"

# Run main function
main "$@"