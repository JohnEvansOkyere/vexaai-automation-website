@echo off
REM VexaAI Workflow Sales Platform - Windows Quick Start Script
REM Made with love in Ghana

echo ========================================
echo   VexaAI Workflow Sales Platform
echo ========================================
echo.

REM Check if Python is installed
python --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Python is not installed!
    echo Please install Python 3.9+ from python.org
    pause
    exit /b 1
)

echo [OK] Python found
echo.

REM Check if .env exists
if not exist "backend\.env" (
    echo [WARNING] No .env file found!
    echo Copying .env.example to .env...
    copy backend\.env.example backend\.env
    echo.
    echo Please edit backend\.env with your API keys before continuing
    echo.
    pause
)

REM Check if virtual environment exists
if not exist "backend\venv\" (
    echo [INFO] Creating virtual environment...
    cd backend
    python -m venv venv
    cd ..
    echo [OK] Virtual environment created
)

REM Activate virtual environment and install dependencies
echo [INFO] Installing dependencies...
cd backend
call venv\Scripts\activate.bat
pip install -q -r requirements.txt
if errorlevel 1 (
    echo [ERROR] Failed to install dependencies
    pause
    exit /b 1
)
echo [OK] Dependencies installed
echo.

REM Start backend
echo [INFO] Starting backend server...
start "VexaAI Backend" cmd /k "venv\Scripts\activate.bat && python main.py"

REM Wait for backend to start
timeout /t 3 /nobreak >nul

cd ..

REM Start frontend
echo [INFO] Starting frontend server...
start "VexaAI Frontend" cmd /k "python -m http.server 3000"

REM Wait for frontend to start
timeout /t 2 /nobreak >nul

echo.
echo ========================================
echo   VexaAI Platform is Running!
echo ========================================
echo.
echo Main Website:      http://localhost:3000
echo Admin Dashboard:   http://localhost:3000/admin.html
echo API Docs:          http://localhost:8000/docs
echo API Health:        http://localhost:8000
echo.
echo Press any key to open the website...
pause >nul

start http://localhost:3000

echo.
echo Servers are running in separate windows.
echo Close those windows to stop the servers.
echo.
pause
