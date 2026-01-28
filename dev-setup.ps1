# ==================================================
# Full-Stack Development Environment Setup Script (PowerShell)
# ==================================================
# This script sets up and runs the Vue.js + Flask application
# with all dependencies and development servers

param(
    [switch]$SkipConfirmation
)

# Set execution policy for this session if needed
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Color functions
function Write-Header {
    param([string]$Message)
    Write-Host "`n==================================================" -ForegroundColor Magenta
    Write-Host $Message -ForegroundColor Magenta
    Write-Host "==================================================" -ForegroundColor Magenta
}

function Write-Step {
    param([string]$Message)
    Write-Host "[STEP] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = Join-Path $ScriptDir "backend"
$FrontendDir = Join-Path $ScriptDir "frontend"

# Check if we're in the right directory
if (-not (Test-Path $BackendDir) -or -not (Test-Path $FrontendDir)) {
    Write-Error-Custom "Backend or frontend directories not found!"
    Write-Error-Custom "Please run this script from the project root directory."
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Header "Full-Stack Development Setup"
Write-Host "This script will:"
Write-Host "1. Check system requirements"
Write-Host "2. Set up Python virtual environment for backend"
Write-Host "3. Install Python dependencies"
Write-Host "4. Set up Node.js environment for frontend"
Write-Host "5. Install npm dependencies"
Write-Host "6. Initialize database with sample data"
Write-Host "7. Start both development servers"
Write-Host ""

# Ask for confirmation
if (-not $SkipConfirmation) {
    $reply = Read-Host "Continue with setup? (y/N)"
    if ($reply -ne 'y' -and $reply -ne 'Y') {
        Write-Info "Setup cancelled."
        Read-Host "Press Enter to exit"
        exit 0
    }
}

# ==================================================
# SYSTEM REQUIREMENTS CHECK
# ==================================================
Write-Header "Checking System Requirements"

# Check Python
Write-Step "Checking Python installation..."
try {
    $pythonVersion = & python --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Found: $pythonVersion"
    } else {
        throw "Python not found"
    }
} catch {
    Write-Error-Custom "Python is not installed or not in PATH. Please install Python 3.9+ from https://python.org"
    Read-Host "Press Enter to exit"
    exit 1
}

# Check pip
Write-Step "Checking pip installation..."
try {
    $null = & pip --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "pip is available"
    } else {
        throw "pip not found"
    }
} catch {
    Write-Error-Custom "pip is not installed or not in PATH."
    Read-Host "Press Enter to exit"
    exit 1
}

# Check Node.js
Write-Step "Checking Node.js installation..."
try {
    $nodeVersion = & node --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Found: Node.js $nodeVersion"
       
        # Check Node version (should be 18+)
        $nodeMajorVersion = [int]($nodeVersion -replace '^v(\d+).*', '$1')
        if ($nodeMajorVersion -lt 18) {
            Write-Warning "Node.js version $nodeVersion detected. Recommended: v18+"
        }
    } else {
        throw "Node.js not found"
    }
} catch {
    Write-Error-Custom "Node.js is not installed or not in PATH. Please install Node.js 18+ from https://nodejs.org"
    Read-Host "Press Enter to exit"
    exit 1
}

# Check npm
Write-Step "Checking npm installation..."
try {
    $npmVersion = & npm --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Found: npm v$npmVersion"
    } else {
        throw "npm not found"
    }
} catch {
    Write-Error-Custom "npm is not installed or not in PATH."
    Read-Host "Press Enter to exit"
    exit 1
}

# ==================================================
# BACKEND SETUP
# ==================================================
Write-Header "Setting up Backend (Python Flask)"

Set-Location $BackendDir

# Create virtual environment if it doesn't exist
Write-Step "Setting up Python virtual environment..."
if (-not (Test-Path "venv")) {
    Write-Info "Creating virtual environment..."
    & python -m venv venv
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to create virtual environment"
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Success "Virtual environment created"
} else {
    Write-Info "Virtual environment already exists"
}

# Activate virtual environment and install dependencies
Write-Step "Installing Python dependencies..."
& ".\venv\Scripts\Activate.ps1"

# Upgrade pip first
& python -m pip install --upgrade pip

# Install requirements
if (Test-Path "requirements.txt") {
    & pip install -r requirements.txt
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to install Python dependencies"
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Success "Python dependencies installed"
} else {
    Write-Error-Custom "requirements.txt not found in backend directory"
    Read-Host "Press Enter to exit"
    exit 1
}

# ==================================================
# FRONTEND SETUP
# ==================================================
Write-Header "Setting up Frontend (Vue.js)"

Set-Location $FrontendDir

# Install Node.js dependencies
Write-Step "Installing Node.js dependencies..."
if (Test-Path "package.json") {
    cmd /c "npm install"
    if ($LASTEXITCODE -ne 0) {
        Write-Error-Custom "Failed to install Node.js dependencies"
        Read-Host "Press Enter to exit"
        exit 1
    }
    Write-Success "Node.js dependencies installed"
} else {
    Write-Error-Custom "package.json not found in frontend directory"
    Read-Host "Press Enter to exit"
    exit 1
}

# ==================================================
# DATABASE INITIALIZATION
# ==================================================
Write-Header "Initializing Database"

Set-Location $BackendDir
& ".\venv\Scripts\Activate.ps1"

Write-Step "Initializing SQLite database with sample data..."
$dbScript = @"
from app import app, db, create_sample_data
with app.app_context():
    db.create_all()
    create_sample_data()
    print('Database initialized successfully!')
"@

& python -c $dbScript
if ($LASTEXITCODE -ne 0) {
    Write-Error-Custom "Failed to initialize database"
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Success "Database initialized with sample data"

# ==================================================
# START DEVELOPMENT SERVERS
# ==================================================
Write-Header "Starting Development Servers"

# Start backend server
Write-Step "Starting Flask backend server..."
Set-Location $BackendDir
& ".\venv\Scripts\Activate.ps1"

$backendJob = Start-Job -ScriptBlock {
    Set-Location $using:BackendDir
    & ".\venv\Scripts\Activate.ps1"
    & python app.py *>&1 | Out-File -FilePath "..\backend.log" -Encoding UTF8
}

# Wait for backend to start
Start-Sleep -Seconds 3

# Check if backend job is running
if ($backendJob.State -eq "Running") {
    Write-Success "Backend server started (Job ID: $($backendJob.Id))"
    Write-Info "Backend running at: http://127.0.0.1:5000"
    Write-Info "Backend logs: backend.log"
} else {
    Write-Error-Custom "Failed to start backend server"
    Write-Error-Custom "Check backend.log for details"
    Read-Host "Press Enter to exit"
    exit 1
}

# Start frontend server
Write-Step "Starting Vue.js frontend server..."
Set-Location $FrontendDir

$frontendJob = Start-Job -ScriptBlock {
    Set-Location $using:FrontendDir
    cmd /c "npm run dev" *>&1 | Out-File -FilePath "..\frontend.log" -Encoding UTF8
}

# Wait for frontend to start
Start-Sleep -Seconds 5

# Check if frontend job is running
if ($frontendJob.State -eq "Running") {
    Write-Success "Frontend server started (Job ID: $($frontendJob.Id))"
   
    # Try to determine the frontend port from logs
    Start-Sleep -Seconds 2
    $frontendUrl = "http://127.0.0.1:5173"
    if (Test-Path "..\frontend.log") {
        $logContent = Get-Content "..\frontend.log" -Raw
        if ($logContent -match "http://127\.0\.0\.1:\d+") {
            $frontendUrl = $matches[0]
        }
    }
    Write-Info "Frontend running at: $frontendUrl"
    Write-Info "Frontend logs: frontend.log"
} else {
    Write-Error-Custom "Failed to start frontend server"
    Write-Error-Custom "Check frontend.log for details"
    Stop-Job $backendJob
    Remove-Job $backendJob
    Read-Host "Press Enter to exit"
    exit 1
}

# ==================================================
# SUCCESS MESSAGE
# ==================================================
Write-Header "Setup Complete!"

Write-Host "Both development servers are running!" -ForegroundColor Green
Write-Host ""
Write-Host "   Frontend: $frontendUrl"
Write-Host "   Backend:  http://127.0.0.1:5000"
Write-Host ""
Write-Host "   Demo Accounts:"
Write-Host "   Admin: username='admin', password='admin123'"
Write-Host "   User:  username='demo', password='demo123'"
Write-Host ""
Write-Host "   Log Files:"
Write-Host "   Backend: backend.log"
Write-Host "   Frontend: frontend.log"
Write-Host ""
Write-Host "   Available Commands:"
Write-Host "   View backend logs: Get-Content backend.log -Wait"
Write-Host "   View frontend logs: Get-Content frontend.log -Wait"
Write-Host "   Stop servers: Press Ctrl+C"
Write-Host ""

# Open browser (optional)
$reply = Read-Host "Open application in browser? (y/N)"
if ($reply -eq 'y' -or $reply -eq 'Y') {
    Start-Process $frontendUrl
}

Write-Info "Press Ctrl+C to stop both servers"

# Cleanup function
function Cleanup {
    Write-Info "Shutting down development servers..."
    if ($backendJob) {
        Stop-Job $backendJob -ErrorAction SilentlyContinue
        Remove-Job $backendJob -ErrorAction SilentlyContinue
    }
    if ($frontendJob) {
        Stop-Job $frontendJob -ErrorAction SilentlyContinue
        Remove-Job $frontendJob -ErrorAction SilentlyContinue
    }
   
    # Kill any remaining processes
    Get-Process | Where-Object { $_.ProcessName -eq "python" -and $_.CommandLine -like "*app.py*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-Process | Where-Object { $_.ProcessName -eq "node" -and $_.CommandLine -like "*vite*" } | Stop-Process -Force -ErrorAction SilentlyContinue
   
    Write-Success "Development servers stopped"
    exit 0
}

# Register cleanup for Ctrl+C
$null = Register-EngineEvent PowerShell.Exiting -Action { Cleanup }

# Wait for user interrupt
try {
    while ($backendJob.State -eq "Running" -and $frontendJob.State -eq "Running") {
        Start-Sleep -Seconds 1
    }
    Write-Warning "One or both servers have stopped"
} finally {
    Cleanup
}
