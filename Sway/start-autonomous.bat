@echo off
echo 🤖 Sway Autonomous Agent - Starting...
echo ======================================

REM Check if WSL2 is available
wsl --list --verbose >nul 2>&1
if errorlevel 1 (
    echo ❌ WSL2 not found. Please install WSL2 first.
    pause
    exit /b 1
)

REM Check if Ubuntu is running
wsl --list --verbose | findstr "Ubuntu-24.04" >nul
if errorlevel 1 (
    echo ❌ Ubuntu 24.04 not found. Installing...
    wsl --install -d Ubuntu-24.04
    echo ✅ Ubuntu installed. Please restart this script.
    pause
    exit /b 0
)

echo ✅ WSL2 Ubuntu environment ready

REM Run the setup script in WSL2
echo 📦 Setting up autonomous agent...
wsl -d Ubuntu-24.04 bash /mnt/c/Users/Administrator/Test/Sway/setup/wsl-setup.sh

REM Start the autonomous agent
echo 🚀 Starting autonomous CEO daemon...
wsl -d Ubuntu-24.04 bash -c "cd /mnt/c/Users/Administrator/Test/Sway && ./gemini maintain"

pause