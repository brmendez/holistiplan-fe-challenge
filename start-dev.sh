#!/bin/bash

# ==================================================
# Quick Development Server Start Script
# ==================================================
# Use this script when dependencies are already installed
# For first-time setup, use ./dev-setup.sh instead

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

echo -e "${BLUE}🚀 Starting Development Servers...${NC}\n"

# Function to cleanup on exit
cleanup() {
    echo -e "\n${YELLOW}Shutting down servers...${NC}"
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null
    fi
    # Kill any remaining processes
    pkill -f "python.*app.py" 2>/dev/null || true
    pkill -f "vite" 2>/dev/null || true
    
    print_success "Development servers stopped"
    exit 0
}

# Setup trap for cleanup
trap cleanup EXIT INT TERM

# Kill any existing servers first
pkill -f "python.*app.py" 2>/dev/null || true
pkill -f "vite" 2>/dev/null || true
sleep 1

# Start backend
print_info "Starting Flask backend..."
cd "$SCRIPT_DIR/backend"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    print_error "Virtual environment not found. Please run ./dev-setup.sh first."
    exit 1
fi

# Activate venv and start backend
source venv/bin/activate
python app.py > ../backend.log 2>&1 &
BACKEND_PID=$!
sleep 2

# Check if backend started
if ps -p $BACKEND_PID > /dev/null 2>&1; then
    print_success "Backend started on http://127.0.0.1:5000"
else
    print_error "Failed to start backend. Check backend.log"
    exit 1
fi

# Start frontend
print_info "Starting Vue.js frontend..."
cd "$SCRIPT_DIR/frontend"

# Check if node_modules exists
if [ ! -d "node_modules" ]; then
    print_error "Node modules not found. Please run ./dev-setup.sh first."
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!
sleep 3

# Try to get frontend URL from logs
FRONTEND_URL="http://127.0.0.1:5173"
if [ -f "../frontend.log" ]; then
    DETECTED_URL=$(grep -o "http://127.0.0.1:[0-9]*" ../frontend.log | head -1 2>/dev/null)
    if [ ! -z "$DETECTED_URL" ]; then
        FRONTEND_URL="$DETECTED_URL"
    fi
fi

# Check if frontend started
if ps -p $FRONTEND_PID > /dev/null 2>&1; then
    print_success "Frontend started on $FRONTEND_URL"
else
    print_error "Failed to start frontend. Check frontend.log"
    kill $BACKEND_PID 2>/dev/null
    exit 1
fi

echo ""
echo -e "${GREEN}🎉 Both servers are running!${NC}"
echo ""
echo "📱 Frontend: $FRONTEND_URL"
echo "🔧 Backend:  http://127.0.0.1:5000"
echo ""
echo "👤 Login with: admin/admin123 or demo/demo123"
echo ""
echo "📄 Logs: backend.log, frontend.log"
echo "🛑 Press Ctrl+C to stop both servers"
echo ""

# Wait for user interrupt
while ps -p $BACKEND_PID > /dev/null 2>&1 && ps -p $FRONTEND_PID > /dev/null 2>&1; do
    sleep 1
done

print_warning "One or both servers have stopped"
