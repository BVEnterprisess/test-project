# Auto-Sync Git Repository Script
# This script automatically pulls, merges, and pushes changes

param(
    [string]$CommitMessage = "Auto-sync: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    [switch]$Force = $false,
    [switch]$Verbose = $false
)

Write-Host "🚀 Starting Auto-Sync Process..." -ForegroundColor Green

# Function to log messages
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $color = switch ($Level) {
        "ERROR" { "Red" }
        "WARNING" { "Yellow" }
        "SUCCESS" { "Green" }
        default { "White" }
    }
    Write-Host "[$timestamp] [$Level] $Message" -ForegroundColor $color
}

# Function to check if there are uncommitted changes
function Test-UncommittedChanges {
    $status = git status --porcelain
    return $status -ne ""
}

# Function to check if there are unpushed commits
function Test-UnpushedCommits {
    $unpushed = git log --oneline origin/main..HEAD
    return $unpushed -ne ""
}

# Function to check if there are remote changes
function Test-RemoteChanges {
    git fetch origin
    $behind = git rev-list HEAD..origin/main --count
    return [int]$behind -gt 0
}

try {
    # Step 1: Check current status
    Write-Log "Checking repository status..."
    $currentBranch = git branch --show-current
    Write-Log "Current branch: $currentBranch"
    
    # Step 2: Fetch latest changes
    Write-Log "Fetching latest changes from remote..."
    git fetch origin
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to fetch from remote"
    }
    
    # Step 3: Check for remote changes
    $hasRemoteChanges = Test-RemoteChanges
    if ($hasRemoteChanges) {
        Write-Log "Remote changes detected, pulling latest changes..." "WARNING"
        
        # Check for conflicts before pulling
        if (Test-UncommittedChanges) {
            Write-Log "Local changes detected. Stashing changes..." "WARNING"
            git stash push -m "Auto-stash before pull: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
        }
        
        # Pull with rebase to avoid merge commits
        git pull --rebase origin main
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to pull changes from remote"
        }
        
        # Pop stashed changes if any
        if (git stash list) {
            Write-Log "Restoring stashed changes..." "WARNING"
            git stash pop
        }
        
        Write-Log "Successfully pulled remote changes" "SUCCESS"
    } else {
        Write-Log "No remote changes detected"
    }
    
    # Step 4: Check for local changes to commit
    if (Test-UncommittedChanges) {
        Write-Log "Local changes detected, staging and committing..."
        git add .
        git commit -m $CommitMessage
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to commit changes"
        }
        Write-Log "Successfully committed changes: $CommitMessage" "SUCCESS"
    } else {
        Write-Log "No local changes to commit"
    }
    
    # Step 5: Push changes if any
    if (Test-UnpushedCommits) {
        Write-Log "Pushing local commits to remote..."
        if ($Force) {
            git push --force-with-lease origin main
        } else {
            git push origin main
        }
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to push changes to remote"
        }
        Write-Log "Successfully pushed changes to remote" "SUCCESS"
    } else {
        Write-Log "No unpushed commits"
    }
    
    # Step 6: Final status check
    Write-Log "Final repository status:"
    git status --short
    
    Write-Log "✅ Auto-sync completed successfully!" "SUCCESS"
    
} catch {
    Write-Log "❌ Auto-sync failed: $($_.Exception.Message)" "ERROR"
    exit 1
}
