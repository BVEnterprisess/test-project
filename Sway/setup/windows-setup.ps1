# Windows PowerShell Setup for Sway Autonomous Agent
Write-Host "🚀 Setting up Sway Autonomous Agent in Windows..." -ForegroundColor Cyan

# Install Python dependencies
Write-Host "📦 Installing Python dependencies..." -ForegroundColor Yellow
py -m pip install google-generativeai requests

# Set API key
$env:GOOGLE_API_KEY = "AIzaSyB3BNf3HShFiXyJO9cmhgcsr4Xj1mLcmkU"

Write-Host "✅ Sway Autonomous Agent setup complete!" -ForegroundColor Green
Write-Host "🚀 Ready to run: python gemini-cli.py maintain" -ForegroundColor Yellow