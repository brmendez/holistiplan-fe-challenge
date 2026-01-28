# ==================================================
# Quick Development Server Start Script (PowerShell)
# ==================================================
# Use this script when dependencies are already installed
# For first-time setup, use dev-setup.ps1 instead

# Set execution policy for this session if needed
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# Color functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Error-Custom {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$BackendDir = Join-Path $ScriptDir "backend"
$FrontendDir = Join-Path $ScriptDir "frontend"

Write-Host "Starting Development Servers..." -ForegroundColor Blue
Write-Host ""

# Function to cleanup on exit
function Cleanup {
    Write-Host "`n" -NoNewline
    Write-Warning "Shutting down servers..."
   
    # Stop background jobs
    if ($script:BackendJob) {
        Stop-Job $script:BackendJob -ErrorAction SilentlyContinue
        Remove-Job $script:BackendJob -ErrorAction SilentlyContinue
    }
    if ($script:FrontendJob) {
        Stop-Job $script:FrontendJob -ErrorAction SilentlyContinue
        Remove-Job $script:FrontendJob -ErrorAction SilentlyContinue
    }
   
    # Kill any remaining processes
    Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*app.py*" } | Stop-Process -Force -ErrorAction SilentlyContinue
    Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*vite*" } | Stop-Process -Force -ErrorAction SilentlyContinue
   
    Write-Success "Development servers stopped"
    exit 0
}

# Register cleanup for Ctrl+C
$null = Register-EngineEvent PowerShell.Exiting -Action { Cleanup }

# Kill any existing servers first
Write-Info "Stopping any existing servers..."
Get-Process -Name "python" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*app.py*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Get-Process -Name "node" -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -like "*vite*" } | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1

# Start backend
Write-Info "Starting Flask backend..."
Set-Location $BackendDir

# Check if virtual environment exists
if (-not (Test-Path "venv")) {
    Write-Error-Custom "Virtual environment not found. Please run dev-setup.ps1 first."
    Read-Host "Press Enter to exit"
    exit 1
}

# Start backend as background job
$script:BackendJob = Start-Job -ScriptBlock {
    Set-Location $using:BackendDir
    & ".\venv\Scripts\Activate.ps1"
    & python app.py *>&1 | Out-File -FilePath "..\backend.log" -Encoding UTF8
}

Start-Sleep -Seconds 2

# Check if backend started
if ($script:BackendJob.State -eq "Running") {
    Write-Success "Backend started on http://127.0.0.1:5000"
} else {
    Write-Error-Custom "Failed to start backend. Check backend.log"
    Read-Host "Press Enter to exit"
    exit 1
}

# Start frontend
Write-Info "Starting Vue.js frontend..."
Set-Location $FrontendDir

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Error-Custom "Node modules not found. Please run dev-setup.ps1 first."
    Stop-Job $script:BackendJob -ErrorAction SilentlyContinue
    Remove-Job $script:BackendJob -ErrorAction SilentlyContinue
    Read-Host "Press Enter to exit"
    exit 1
}

# Start frontend as background job
$script:FrontendJob = Start-Job -ScriptBlock {
    Set-Location $using:FrontendDir
    & npm run dev *>&1 | Out-File -FilePath "..\frontend.log" -Encoding UTF8
}

Start-Sleep -Seconds 3

# Try to get frontend URL from logs
$frontendUrl = "http://127.0.0.1:5173"
$logPath = Join-Path $ScriptDir "frontend.log"
if (Test-Path $logPath) {
    Start-Sleep -Seconds 2
    $logContent = Get-Content $logPath -Raw -ErrorAction SilentlyContinue
    if ($logContent -match "http://127\.0\.0\.1:\d+") {
        $frontendUrl = $matches[0]
    }
}

# Check if frontend started
if ($script:FrontendJob.State -eq "Running") {
    Write-Success "Frontend started on $frontendUrl"
} else {
    Write-Error-Custom "Failed to start frontend. Check frontend.log"
    Stop-Job $script:BackendJob -ErrorAction SilentlyContinue
    Remove-Job $script:BackendJob -ErrorAction SilentlyContinue
    Read-Host "Press Enter to exit"
    exit 1
}

Write-Host ""
Write-Host "   Both servers are running!" -ForegroundColor Green
Write-Host ""
Write-Host "   Frontend: $frontendUrl"
Write-Host "   Backend:  http://127.0.0.1:5000"
Write-Host ""
Write-Host "   Login with: admin/admin123 or demo/demo123"
Write-Host ""
Write-Host "   Logs: backend.log, frontend.log"
Write-Host "   Press Ctrl+C to stop both servers"
Write-Host ""

# Wait for user interrupt or job failure
try {
    while ($script:BackendJob.State -eq "Running" -and $script:FrontendJob.State -eq "Running") {
        Start-Sleep -Seconds 1
    }
    Write-Warning "One or both servers have stopped"
} finally {
    Cleanup
}