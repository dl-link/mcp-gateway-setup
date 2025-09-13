#!/bin/bash

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
#   🔧 MCP CONTEXT FORGE - Development Utilities
#   Additional helper functions for development workflow
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Source this file or run individual functions
# Usage: source dev-utils.sh

VENV_DIR="$HOME/.venv/mcpgateway"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Quick server operations
mcp-start() {
    echo -e "${BLUE}🚀 Starting MCP Gateway...${NC}"
    ./setup-mcp-gateway.sh start
}

mcp-stop() {
    echo -e "${RED}🛑 Stopping MCP Gateway...${NC}"
    ./setup-mcp-gateway.sh stop
}

mcp-restart() {
    echo -e "${YELLOW}🔄 Restarting MCP Gateway...${NC}"
    ./setup-mcp-gateway.sh restart
}

mcp-status() {
    ./setup-mcp-gateway.sh status
}

mcp-logs() {
    echo -e "${BLUE}📋 MCP Gateway Logs:${NC}"
    if [ -f "mcp-gateway.log" ]; then
        tail -f mcp-gateway.log
    else
        echo "No log file found. Server may not be running."
    fi
}

mcp-test() {
    echo -e "${BLUE}🧪 Testing MCP Gateway endpoints...${NC}"
    
    local base_url="http://localhost:8000"
    
    echo "Testing health endpoint..."
    if curl -sf "$base_url/health" > /dev/null; then
        echo -e "${GREEN}✅ Health check passed${NC}"
    else
        echo -e "${RED}❌ Health check failed${NC}"
        return 1
    fi
    
    echo "Testing root endpoint..."
    if curl -sf "$base_url/" > /dev/null; then
        echo -e "${GREEN}✅ Root endpoint accessible${NC}"
    else
        echo -e "${YELLOW}⚠️  Root endpoint returned error (may be normal)${NC}"
    fi
    
    echo "Testing API docs..."
    if curl -sf "$base_url/docs" > /dev/null; then
        echo -e "${GREEN}✅ API documentation accessible${NC}"
    else
        echo -e "${YELLOW}⚠️  API docs not accessible${NC}"
    fi
}

mcp-env() {
    echo -e "${BLUE}🔧 Activating MCP Gateway environment...${NC}"
    if [ -d "$VENV_DIR" ]; then
        echo "Run: source $VENV_DIR/bin/activate"
        echo "Or use: $VENV_DIR/bin/python"
    else
        echo -e "${RED}❌ Virtual environment not found. Run setup first.${NC}"
    fi
}

mcp-deps() {
    echo -e "${BLUE}📦 Installing/updating dependencies...${NC}"
    if [ -d "$VENV_DIR" ]; then
        "$VENV_DIR/bin/python" -m uv pip install --upgrade ".[dev]"
        echo -e "${GREEN}✅ Dependencies updated${NC}"
    else
        echo -e "${RED}❌ Virtual environment not found. Run setup first.${NC}"
    fi
}

mcp-clean-logs() {
    echo -e "${YELLOW}🧹 Cleaning log files...${NC}"
    rm -f mcp-gateway.log nohup.out
    echo -e "${GREEN}✅ Log files cleaned${NC}"
}

mcp-backup-config() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_file=".env.backup_$timestamp"
    
    if [ -f ".env" ]; then
        cp ".env" "$backup_file"
        echo -e "${GREEN}✅ Configuration backed up to: $backup_file${NC}"
    else
        echo -e "${RED}❌ No .env file found to backup${NC}"
    fi
}

mcp-reset-config() {
    echo -e "${YELLOW}🔄 Resetting configuration to defaults...${NC}"
    
    if [ -f ".env" ]; then
        mcp-backup-config
    fi
    
    if [ -f ".env.example" ]; then
        cp ".env.example" ".env"
        echo -e "${GREEN}✅ Configuration reset from .env.example${NC}"
    else
        echo -e "${RED}❌ .env.example not found${NC}"
    fi
}

mcp-info() {
    echo -e "${BLUE}ℹ️  MCP Gateway Information:${NC}"
    echo
    echo "🌐 Server: http://localhost:8000"
    echo "🔧 Admin UI: http://localhost:8000 (admin/changeme)"
    echo "📚 API Docs: http://localhost:8000/docs"
    echo "❤️  Health: http://localhost:8000/health"
    echo
    echo "📁 Project: $PROJECT_ROOT"
    echo "🐍 Venv: $VENV_DIR"
    echo "⚙️  Config: $PROJECT_ROOT/.env"
    echo "📋 Logs: $PROJECT_ROOT/mcp-gateway.log"
    echo
    echo "Available commands:"
    echo "  mcp-start, mcp-stop, mcp-restart, mcp-status"
    echo "  mcp-logs, mcp-test, mcp-env, mcp-deps"
    echo "  mcp-clean-logs, mcp-backup-config, mcp-reset-config"
}

# Run function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-info}" in
        "start") mcp-start ;;
        "stop") mcp-stop ;;
        "restart") mcp-restart ;;
        "status") mcp-status ;;
        "logs") mcp-logs ;;
        "test") mcp-test ;;
        "env") mcp-env ;;
        "deps") mcp-deps ;;
        "clean-logs") mcp-clean-logs ;;
        "backup-config") mcp-backup-config ;;
        "reset-config") mcp-reset-config ;;
        "info"|*) mcp-info ;;
    esac
fi