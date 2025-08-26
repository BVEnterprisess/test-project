#!/bin/bash

# Sway Autonomous Agent Installation Script
# This script sets up the complete autonomous development environment

set -e

echo "🚀 Installing Sway Autonomous Agent..."

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

# Create configuration directory
mkdir -p ~/.gemini/config

# Set API key
echo "AIzaSyB3BNf3HShFiXyJO9cmhgcsr4Xj1mLcmkU" > ~/.gemini/config/api_key

# Make scripts executable
chmod +x ~/.gemini/commands/*.sh

echo "✅ Sway Autonomous Agent installed successfully!"
echo "🔑 API Key configured"
echo "🚀 Ready to run: gemini maintain"