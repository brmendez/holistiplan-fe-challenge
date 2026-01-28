#!/bin/bash

# ==================================================
# Full-Stack Development Environment Setup Script
# ==================================================
# This script sets up and runs the Vue.js + Flask application
# with all dependencies and development servers

set -e  # Exit on any error

# Color codes for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to print colored output
print_header() {
    echo -e "\n${PURPLE}=================================================="
    echo -e "$1"
    echo -e "==================================================${NC}\n"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[INFO]${NC} $1"
}

# Get the script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BACKEND_DIR="$SCRIPT_DIR/backend"
FRONTEND_DIR="$SCRIPT_DIR/frontend"

# Check if we're in the right directory
if [[ ! -d "$BACKEND_DIR" ]] || [[ ! -d "$FRONTEND_DIR" ]]; then
    print_error "Backend or frontend directories not found!"
    print_error "Please run this script from the project root directory."
    exit 1
fi

print_header "🚀 Full-Stack Development Setup"
echo "This script will:"
echo "1. Check system requirements"
echo "2. Set up Python virtual environment for backend"
echo "3. Install Python dependencies"
echo "4. Set up Node.js environment for frontend"
echo "5. Install npm dependencies"
echo "6. Initialize database with sample data"
echo "7. Start both development servers"
echo ""

# Ask for confirmation
read -p "Continue with setup? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    print_info "Setup cancelled."
    exit 0
fi

# ==================================================
# SYSTEM REQUIREMENTS CHECK
# ==================================================
print_header "🔍 Checking System Requirements"

# Check Python
print_step "Checking Python installation..."
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    print_success "Found: $PYTHON_VERSION"
else
    print_error "Python 3 is not installed. Please install Python 3.9+ from https://python.org"
    exit 1
fi

# Check pip
print_step "Checking pip installation..."
if command -v pip3 &> /dev/null || python3 -m pip --version &> /dev/null; then
    print_success "pip is available"
else
    print_error "pip is not installed. Please install pip first."
    exit 1
fi

# Check Node.js
print_step "Checking Node.js installation..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Found: Node.js $NODE_VERSION"
    
    # Check Node version (should be 18+)
    NODE_MAJOR_VERSION=$(node --version | cut -d'.' -f1 | sed 's/v//')
    if [ "$NODE_MAJOR_VERSION" -lt 18 ]; then
        print_warning "Node.js version $NODE_VERSION detected. Recommended: v18+"
    fi
else
    print_error "Node.js is not installed. Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi

# Check npm
print_step "Checking npm installation..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_success "Found: npm v$NPM_VERSION"
else
    print_error "npm is not installed. Please install npm."
    exit 1
fi

# ==================================================
# BACKEND SETUP
# ==================================================
print_header "🐍 Setting up Backend (Python Flask)"

cd "$BACKEND_DIR"

# Create virtual environment if it doesn't exist
print_step "Setting up Python virtual environment..."
if [ ! -d "venv" ]; then
    print_info "Creating virtual environment..."
    python3 -m venv venv
    print_success "Virtual environment created"
else
    print_info "Virtual environment already exists"
fi

# Activate virtual environment and install dependencies
print_step "Installing Python dependencies..."
source venv/bin/activate

# Upgrade pip first
pip install --upgrade pip

# Install requirements
if [ -f "requirements.txt" ]; then
    pip install -r requirements.txt
    print_success "Python dependencies installed"
else
    print_error "requirements.txt not found in backend directory"
    exit 1
fi

# ==================================================
# FRONTEND SETUP  
# ==================================================
print_header "🌐 Setting up Frontend (Vue.js)"

cd "$FRONTEND_DIR"

# Install Node.js dependencies
print_step "Installing Node.js dependencies..."
if [ -f "package.json" ]; then
    npm install
    print_success "Node.js dependencies installed"
else
    print_error "package.json not found in frontend directory"
    exit 1
fi

# ==================================================
# DATABASE INITIALIZATION
# ==================================================
print_header "🗄️ Initializing Database"

cd "$BACKEND_DIR"
source venv/bin/activate

print_step "Initializing SQLite database with sample data..."
python -c "
from app import app, db, create_sample_data
with app.app_context():
    db.create_all()
    create_sample_data()
    print('Database initialized successfully!')
"
print_success "Database initialized with sample data"

# ==================================================
# START DEVELOPMENT SERVERS
# ==================================================
print_header "🚀 Starting Development Servers"

# Function to cleanup on exit
cleanup() {
    print_info "Shutting down development servers..."
    if [ ! -z "$BACKEND_PID" ]; then
        kill $BACKEND_PID 2>/dev/null || true
    fi
    if [ ! -z "$FRONTEND_PID" ]; then
        kill $FRONTEND_PID 2>/dev/null || true
    fi
    print_success "Development servers stopped"
    exit 0
}

# Setup trap for cleanup
trap cleanup EXIT INT TERM

# Start backend server
print_step "Starting Flask backend server..."
cd "$BACKEND_DIR"
source venv/bin/activate
python app.py > ../backend.log 2>&1 &
BACKEND_PID=$!

# Wait a moment for backend to start
sleep 3

# Check if backend started successfully
if ps -p $BACKEND_PID > /dev/null 2>&1; then
    print_success "Backend server started (PID: $BACKEND_PID)"
    print_info "Backend running at: http://127.0.0.1:5000"
    print_info "Backend logs: backend.log"
else
    print_error "Failed to start backend server"
    print_error "Check backend.log for details"
    exit 1
fi

# Start frontend server
print_step "Starting Vue.js frontend server..."
cd "$FRONTEND_DIR"
npm run dev > ../frontend.log 2>&1 &
FRONTEND_PID=$!

# Wait a moment for frontend to start
sleep 5

# Check if frontend started successfully
if ps -p $FRONTEND_PID > /dev/null 2>&1; then
    print_success "Frontend server started (PID: $FRONTEND_PID)"
    
    # Try to determine the frontend port from logs
    sleep 2
    FRONTEND_URL=$(grep -o "http://127.0.0.1:[0-9]*" ../frontend.log | head -1 2>/dev/null || echo "http://127.0.0.1:5173")
    print_info "Frontend running at: $FRONTEND_URL"
    print_info "Frontend logs: frontend.log"
else
    print_error "Failed to start frontend server"
    print_error "Check frontend.log for details"
    kill $BACKEND_PID 2>/dev/null || true
    exit 1
fi

# ==================================================
# SUCCESS MESSAGE
# ==================================================
print_header "🎉 Setup Complete!"

echo -e "${GREEN}Both development servers are running!${NC}"
echo ""
echo "📱 Frontend: $FRONTEND_URL"
echo "🔧 Backend:  http://127.0.0.1:5000"
echo ""
echo "👤 Demo Accounts:"
echo "   Admin: username='admin', password='admin123'"
echo "   User:  username='demo', password='demo123'"
echo ""
echo "📄 Log Files:"
echo "   Backend: backend.log"
echo "   Frontend: frontend.log"
echo ""
echo "🛠️  Available Commands:"
echo "   View backend logs: tail -f backend.log"
echo "   View frontend logs: tail -f frontend.log"
echo "   Stop servers: Press Ctrl+C"
echo ""

# Open browser (optional)
read -p "Open application in browser? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    if command -v open &> /dev/null; then  # macOS
        open "$FRONTEND_URL"
    elif command -v xdg-open &> /dev/null; then  # Linux
        xdg-open "$FRONTEND_URL"
    elif command -v start &> /dev/null; then  # Windows
        start "$FRONTEND_URL"
    else
        print_info "Please open $FRONTEND_URL in your browser"
    fi
fi

print_info "Press Ctrl+C to stop both servers"

# Wait for servers to run
while ps -p $BACKEND_PID > /dev/null 2>&1 && ps -p $FRONTEND_PID > /dev/null 2>&1; do
    sleep 1
done

print_warning "One or both servers have stopped"
