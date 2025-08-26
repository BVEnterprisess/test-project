#!/usr/bin/env python3

import os
import sys
import json
import google.generativeai as genai
from pathlib import Path

# Configure API
API_KEY = "AIzaSyB3BNf3HShFiXyJO9cmhgcsr4Xj1mLcmkU"
genai.configure(api_key=API_KEY)

class SwayAgent:
    def __init__(self):
        self.model = genai.GenerativeModel('gemini-pro')
        self.commands_dir = Path.home() / '.gemini' / 'commands'
        
    def load_command(self, command_name):
        """Load command configuration from TOML file"""
        try:
            import tomllib
        except ImportError:
            import tomli as tomllib
            
        command_file = self.commands_dir / f"{command_name}.toml"
        
        if not command_file.exists():
            return None
            
        with open(command_file, 'rb') as f:
            return tomllib.load(f)
    
    def execute_command(self, command_name, args=""):
        """Execute a command with the given arguments"""
        config = self.load_command(command_name)
        
        if not config:
            print(f"Command '{command_name}' not found")
            return
            
        prompt = config['prompt'].replace('{{args}}', args)
        
        print(f"Executing: {command_name}")
        print(f"Task: {args}")
        print("-" * 50)
        
        try:
            response = self.model.generate_content(prompt)
            print(response.text)
        except Exception as e:
            print(f"Error: {e}")
    
    def maintain_loop(self):
        """Run the autonomous maintenance loop"""
        print("Starting autonomous maintenance loop...")
        print("This will run indefinitely. Press Ctrl+C to stop.")
        
        while True:
            try:
                # Health check
                print("\nRunning health check...")
                self.execute_command("healthcheck")
                
                # Git sync
                print("\nSyncing with git...")
                self.execute_command("git/autosync")
                
                # Deploy if needed
                print("\nChecking deployment...")
                self.execute_command("deploy")
                
                # Optimize periodically
                print("\nRunning optimization...")
                self.execute_command("optimize")
                
                print("\nWaiting 5 minutes before next cycle...")
                import time
                time.sleep(300)
                
            except KeyboardInterrupt:
                print("\nAutonomous loop stopped by user")
                break
            except Exception as e:
                print(f"Error in maintenance loop: {e}")
                continue

def main():
    agent = SwayAgent()
    
    if len(sys.argv) < 2:
        print("Usage: python3 gemini-cli.py <command> [args]")
        print("Commands: develop, debug, init, refactor, secure, document, dependencies, maintain")
        return
    
    command = sys.argv[1]
    args = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else ""
    
    if command == "maintain":
        agent.maintain_loop()
    else:
        agent.execute_command(command, args)

if __name__ == "__main__":
    main()