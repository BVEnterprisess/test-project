#!/bin/bash

# Quick start script for Sway Autonomous Agent

echo "🚀 Sway Autonomous Agent - Quick Start"
echo "======================================"

# Check if WSL2 is available
if ! command -v wsl &> /dev/null; then
    echo "❌ WSL2 not found. Please install WSL2 first."
    exit 1
fi

# Check if Ubuntu is installed
if ! wsl -l -v | grep -q "Ubuntu"; then
    echo "❌ Ubuntu not found in WSL2. Installing Ubuntu 24.04..."
    wsl --install -d Ubuntu-24.04
    echo "✅ Ubuntu installed. Please restart your terminal and run this script again."
    exit 0
fi

echo "✅ WSL2 Ubuntu environment ready"

# Navigate to Sway directory
cd /mnt/c/Users/Administrator/Test/Sway

# Install dependencies
echo "📦 Installing dependencies..."
bash setup/install.sh

# Initialize git if not already done
if [ ! -d ".git" ]; then
    echo "🔧 Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: Sway Autonomous Agent"
fi

echo ""
echo "🎉 Sway Autonomous Agent is ready!"
echo ""
echo "🚀 To start the autonomous loop:"
echo "   gemini maintain"
echo ""
echo "🔧 To run individual commands:"
echo "   gemini develop 'your task'"
echo "   gemini debug 'bug description'"
echo "   gemini init 'project description'"
echo ""
echo "💡 The agent will now manage your codebase autonomously!"