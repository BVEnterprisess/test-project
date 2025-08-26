#!/bin/bash

# WSL2 Setup Script for Sway Autonomous Agent
echo "🚀 Setting up Sway Autonomous Agent in WSL2..."

# Update system
sudo apt update && sudo apt upgrade -y

# Install essential tools
sudo apt install -y curl wget git python3 python3-pip nodejs npm

# Install Google Gemini CLI
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Gemini CLI globally
npm install -g @google/generative-ai

# Set up Python environment
python3 -m pip install --upgrade pip
python3 -m pip install google-generativeai requests

# Navigate to Sway directory
cd /mnt/c/Users/Administrator/Test/Sway

# Make scripts executable
chmod +x setup/*.sh
chmod +x gemini

# Set API key
mkdir -p ~/.gemini/config
echo "AIzaSyB3BNf3HShFiXyJO9cmhgcsr4Xj1mLcmkU" > ~/.gemini/config/api_key

echo "✅ Sway Autonomous Agent setup complete!"
echo "🚀 Ready to run: ./gemini maintain"