# Git Automation System

A comprehensive PowerShell-based automation system for Git operations including sync, commit, pull, merge, and more.

## 🚀 Quick Start

### Using the Batch File (Recommended)
```bash
# Show help
git-auto.bat

# Sync repository (pull, commit, push)
git-auto.bat sync "Update feature"

# Commit changes
git-auto.bat commit "Fix bug" --push

# Pull latest changes
git-auto.bat pull

# Show status
git-auto.bat status

# Run full automation sequence
git-auto.bat all "Daily sync"
```

### Using PowerShell Directly
```powershell
# Sync repository
.\scripts\git-automation.ps1 -Operation sync -CommitMessage "Update feature"

# Commit with push
.\scripts\git-automation.ps1 -Operation commit -CommitMessage "Fix bug" -Push

# Pull with rebase
.\scripts\git-automation.ps1 -Operation pull -Rebase

# Merge branch
.\scripts\git-automation.ps1 -Operation merge -SourceBranch "feature" -TargetBranch "main"

# Full automation
.\scripts\git-automation.ps1 -Operation all -CommitMessage "Daily sync"
```

## 📁 Scripts Overview

### 1. `auto-sync.ps1`
**Purpose**: Complete repository synchronization
- Fetches latest changes from remote
- Pulls with rebase to avoid merge commits
- Commits local changes with timestamp
- Pushes changes to remote
- Handles conflicts gracefully

**Usage**:
```powershell
.\scripts\auto-sync.ps1 -CommitMessage "Custom message" -Force
```

### 2. `auto-commit.ps1`
**Purpose**: Automated commit operations
- Stages all changes or specific files
- Commits with custom or timestamped message
- Optionally pushes after commit
- Shows detailed change summary

**Usage**:
```powershell
.\scripts\auto-commit.ps1 -CommitMessage "Fix bug" -Push -Files "src/"
```

### 3. `auto-pull.ps1`
**Purpose**: Smart pull operations
- Fetches latest changes
- Uses rebase by default (clean history)
- Handles local commits ahead of remote
- Stashes changes if needed

**Usage**:
```powershell
.\scripts\auto-pull.ps1 -Branch "main" -Rebase:$false
```

### 4. `auto-merge.ps1`
**Purpose**: Automated branch merging
- Merges source branch into target
- Handles conflicts detection
- Optionally deletes source branch
- Stashes changes during merge

**Usage**:
```powershell
.\scripts\auto-merge.ps1 -SourceBranch "feature" -TargetBranch "main" -DeleteSource
```

### 5. `git-automation.ps1`
**Purpose**: Master orchestration script
- Unified interface for all operations
- Parameter validation
- Error handling
- Status reporting

## 🔧 Configuration

### Git Configuration
Ensure your Git is configured:
```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### SSH Setup
The automation system works best with SSH keys:
```bash
# Generate SSH key (if not already done)
ssh-keygen -t ed25519 -C "your.email@example.com"

# Add to GitHub
# Copy ~/.ssh/id_ed25519.pub to GitHub SSH keys
```

## 🎯 Use Cases

### Daily Development Workflow
```bash
# Start of day - pull latest changes
git-auto.bat pull

# During development - commit frequently
git-auto.bat commit "Add new feature" --push

# End of day - full sync
git-auto.bat all "End of day sync"
```

### Feature Branch Workflow
```bash
# Create and work on feature branch
git checkout -b feature/new-feature

# ... make changes ...

# Commit and push feature
git-auto.bat commit "Implement new feature" --push

# Merge to main
git-auto.bat merge feature/new-feature --delete-source
```

### Emergency Fixes
```bash
# Quick fix with force push
git-auto.bat commit "Emergency fix" --push --force
```

## 🛡️ Safety Features

### Conflict Handling
- Automatic conflict detection
- Stash changes before operations
- Restore stashed changes after errors
- Clear error messages

### Force Protection
- `--force-with-lease` for safe force pushes
- Confirmation prompts for destructive operations
- Backup of local changes

### Error Recovery
- Automatic rollback on failures
- Detailed error logging
- Status reporting after operations

## 📊 Monitoring

### Status Commands
```bash
# Quick status
git-auto.bat status

# Detailed status with PowerShell
.\scripts\git-automation.ps1 -Operation status
```

### Logging
All scripts provide detailed logging with:
- Timestamps
- Color-coded messages
- Error details
- Success confirmations

## 🔄 Automation Examples

### Scheduled Sync (Windows Task Scheduler)
```powershell
# Create scheduled task for hourly sync
schtasks /create /tn "Git Auto Sync" /tr "powershell -File C:\path\to\scripts\git-automation.ps1 -Operation sync" /sc hourly
```

### CI/CD Integration
```yaml
# GitHub Actions example
- name: Auto Sync
  run: |
    powershell -File scripts/git-automation.ps1 -Operation sync -CommitMessage "CI sync"
```

## 🚨 Troubleshooting

### Common Issues

1. **Permission Denied**
   ```bash
   # Run PowerShell as Administrator
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **SSH Key Issues**
   ```bash
   # Test SSH connection
   ssh -T git@github.com
   
   # Start SSH agent
   Start-Service ssh-agent
   ssh-add ~/.ssh/id_ed25519
   ```

3. **Merge Conflicts**
   - Scripts will abort and show conflict files
   - Resolve manually, then re-run automation

### Debug Mode
```bash
# Enable verbose logging
git-auto.bat sync "Debug message" --verbose
```

## 📝 Contributing

To extend the automation system:

1. Add new scripts to `scripts/` directory
2. Update `git-automation.ps1` to include new operations
3. Update `git-auto.bat` for batch file support
4. Update this README with documentation

## 📄 License

This automation system is part of your project and follows the same license terms.
