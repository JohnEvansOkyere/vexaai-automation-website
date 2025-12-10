#!/bin/bash

# VexaAI Workflow Sales Platform - Quick Start Script
# Made with ❤️ in Ghana 🇬🇭

echo "🚀 VexaAI Workflow Sales Platform"
echo "=================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ Python 3 is not installed!${NC}"
    echo "Please install Python 3.9+ and try again"
    exit 1
fi

echo -e "${GREEN}✓ Python 3 found${NC}"

# Check if backend/.env exists
if [ ! -f "backend/.env" ]; then
    echo -e "${YELLOW}⚠️  No .env file found!${NC}"
    echo "Copying .env.example to .env..."
    cp backend/.env.example backend/.env
    echo -e "${YELLOW}⚠️  Please edit backend/.env with your API keys before continuing${NC}"
    echo ""
    read -p "Press Enter when you've updated backend/.env..."
fi

# Check if virtual environment exists
if [ ! -d "backend/venv" ]; then
    echo -e "${BLUE}📦 Creating virtual environment...${NC}"
    cd backend
    python3 -m venv venv
    cd ..
    echo -e "${GREEN}✓ Virtual environment created${NC}"
fi

# Activate virtual environment and install dependencies
echo -e "${BLUE}📦 Installing/updating dependencies...${NC}"
cd backend
source venv/bin/activate

if ! pip install -q -r requirements.txt; then
    echo -e "${RED}❌ Failed to install dependencies${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Dependencies installed${NC}"
echo ""

# Start backend in background
echo -e "${BLUE}🔧 Starting backend server...${NC}"
python main.py &
BACKEND_PID=$!

# Wait for backend to start
sleep 3

# Check if backend is running
if ! kill -0 $BACKEND_PID 2>/dev/null; then
    echo -e "${RED}❌ Backend failed to start${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Backend running on http://localhost:8000${NC}"
cd ..

# Start frontend
echo -e "${BLUE}🌐 Starting frontend server...${NC}"
python3 -m http.server 3000 &
FRONTEND_PID=$!

# Wait for frontend to start
sleep 2

echo ""
echo -e "${GREEN}=================================="
echo "✅ VexaAI Platform is Running!"
echo "==================================${NC}"
echo ""
echo -e "${BLUE}📱 Main Website:${NC}       http://localhost:3000"
echo -e "${BLUE}🔧 Admin Dashboard:${NC}    http://localhost:3000/admin.html"
echo -e "${BLUE}📊 API Docs:${NC}           http://localhost:8000/docs"
echo -e "${BLUE}🔥 API Health:${NC}         http://localhost:8000"
echo ""
echo -e "${YELLOW}Press Ctrl+C to stop all servers${NC}"
echo ""

# Function to cleanup on exit
cleanup() {
    echo ""
    echo -e "${YELLOW}🛑 Shutting down servers...${NC}"
    kill $BACKEND_PID 2>/dev/null
    kill $FRONTEND_PID 2>/dev/null
    echo -e "${GREEN}✓ Servers stopped${NC}"
    exit 0
}

# Trap Ctrl+C
trap cleanup INT

# Wait for user to stop
wait
