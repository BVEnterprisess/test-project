# Auto-Pull Git Repository Script
# This script automatically pulls latest changes from remote

param(
    [string]$Branch = "main",
    [switch]$Rebase = $true,
    [switch]$Force = $false,
    [switch]$Verbose = $false
)

Write-Host "⬇️ Starting Auto-Pull Process..." -ForegroundColor Blue

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

# Function to check if there are remote changes
function Test-RemoteChanges {
    param([string]$BranchName)
    git fetch origin
    $behind = git rev-list HEAD..origin/$BranchName --count
    return [int]$behind -gt 0
}

# Function to check if there are local commits ahead of remote
function Test-LocalAhead {
    param([string]$BranchName)
    git fetch origin
    $ahead = git rev-list origin/$BranchName..HEAD --count
    return [int]$ahead -gt 0
}

try {
    # Step 1: Check current status
    Write-Log "Checking repository status..."
    $currentBranch = git branch --show-current
    Write-Log "Current branch: $currentBranch"
    
    # Step 2: Check for uncommitted changes
    if (Test-UncommittedChanges) {
        Write-Log "Uncommitted changes detected. Stashing changes..." "WARNING"
        git stash push -m "Auto-stash before pull: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }
    
    # Step 3: Fetch latest changes
    Write-Log "Fetching latest changes from remote..."
    git fetch origin
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to fetch from remote"
    }
    
    # Step 4: Check if we're on the correct branch
    if ($currentBranch -ne $Branch) {
        Write-Log "Switching to branch: $Branch"
        git checkout $Branch
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to switch to branch $Branch"
        }
    }
    
    # Step 5: Check if there are remote changes
    if (-not (Test-RemoteChanges $Branch)) {
        Write-Log "No remote changes detected" "WARNING"
        exit 0
    }
    
    # Step 6: Check if we have local commits ahead of remote
    $hasLocalAhead = Test-LocalAhead $Branch
    if ($hasLocalAhead) {
        Write-Log "Local commits detected ahead of remote" "WARNING"
        
        if ($Rebase) {
            Write-Log "Performing rebase to maintain clean history..."
            git pull --rebase origin $Branch
        } else {
            Write-Log "Performing merge pull..."
            git pull origin $Branch
        }
    } else {
        Write-Log "Performing fast-forward pull..."
        git pull origin $Branch
    }
    
    if ($LASTEXITCODE -ne 0) {
        if ($Rebase) {
            Write-Log "Rebase conflict detected. Attempting to resolve..." "WARNING"
            
            # Check if it's a simple conflict that can be auto-resolved
            $conflicts = git diff --name-only --diff-filter=U
            if ($conflicts) {
                Write-Log "Conflicts found in: $conflicts" "ERROR"
                Write-Log "Manual resolution required. Aborting rebase..." "ERROR"
                git rebase --abort
                throw "Rebase conflicts require manual resolution"
            }
        } else {
            throw "Failed to pull changes from remote"
        }
    }
    
    Write-Log "Successfully pulled latest changes from remote" "SUCCESS"
    
    # Step 7: Restore stashed changes if any
    if (git stash list) {
        Write-Log "Restoring stashed changes..." "WARNING"
        git stash pop
    }
    
    # Step 8: Show final status
    Write-Log "Final repository status:"
    git status --short
    
    Write-Log "✅ Auto-pull completed successfully!" "SUCCESS"
    
} catch {
    Write-Log "❌ Auto-pull failed: $($_.Exception.Message)" "ERROR"
    
    # Restore stashed changes if any
    if (git stash list) {
        Write-Log "Restoring stashed changes after error..." "WARNING"
        git stash pop
    }
    
    exit 1
}
