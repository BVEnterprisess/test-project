# Auto-Merge Git Repository Script
# This script automatically merges branches and handles conflicts

param(
    [Parameter(Mandatory=$true)]
    [string]$SourceBranch,
    [string]$TargetBranch = "main",
    [switch]$Force = $false,
    [switch]$DeleteSource = $false,
    [switch]$Verbose = $false
)

Write-Host "🔄 Starting Auto-Merge Process..." -ForegroundColor Magenta

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

# Function to check if branch exists
function Test-BranchExists {
    param([string]$BranchName)
    $branches = git branch --list $BranchName
    return $branches -ne ""
}

# Function to check if there are uncommitted changes
function Test-UncommittedChanges {
    $status = git status --porcelain
    return $status -ne ""
}

# Function to check if merge is needed
function Test-MergeNeeded {
    param([string]$Source, [string]$Target)
    git fetch origin
    $mergeBase = git merge-base origin/$Source origin/$Target
    $sourceHead = git rev-parse origin/$Source
    $targetHead = git rev-parse origin/$Target
    
    return $mergeBase -ne $sourceHead
}

try {
    # Step 1: Check current status
    Write-Log "Checking repository status..."
    $currentBranch = git branch --show-current
    Write-Log "Current branch: $currentBranch"
    
    # Step 2: Check for uncommitted changes
    if (Test-UncommittedChanges) {
        Write-Log "Uncommitted changes detected. Stashing changes..." "WARNING"
        git stash push -m "Auto-stash before merge: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    }
    
    # Step 3: Fetch latest changes
    Write-Log "Fetching latest changes from remote..."
    git fetch origin
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to fetch from remote"
    }
    
    # Step 4: Check if source branch exists
    if (-not (Test-BranchExists $SourceBranch)) {
        throw "Source branch '$SourceBranch' does not exist"
    }
    
    # Step 5: Check if target branch exists
    if (-not (Test-BranchExists $TargetBranch)) {
        throw "Target branch '$TargetBranch' does not exist"
    }
    
    # Step 6: Switch to target branch
    Write-Log "Switching to target branch: $TargetBranch"
    git checkout $TargetBranch
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to switch to target branch"
    }
    
    # Step 7: Pull latest changes on target branch
    Write-Log "Pulling latest changes on target branch..."
    git pull origin $TargetBranch
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to pull target branch"
    }
    
    # Step 8: Check if merge is needed
    if (-not (Test-MergeNeeded $SourceBranch $TargetBranch)) {
        Write-Log "No merge needed - branches are already up to date" "WARNING"
        exit 0
    }
    
    # Step 9: Perform merge
    Write-Log "Merging $SourceBranch into $TargetBranch..."
    if ($Force) {
        git merge origin/$SourceBranch --no-ff
    } else {
        git merge origin/$SourceBranch
    }
    
    if ($LASTEXITCODE -ne 0) {
        Write-Log "Merge conflict detected. Attempting to resolve..." "WARNING"
        
        # Check if it's a simple conflict that can be auto-resolved
        $conflicts = git diff --name-only --diff-filter=U
        if ($conflicts) {
            Write-Log "Conflicts found in: $conflicts" "ERROR"
            Write-Log "Manual resolution required. Aborting merge..." "ERROR"
            git merge --abort
            throw "Merge conflicts require manual resolution"
        }
    }
    
    Write-Log "Successfully merged $SourceBranch into $TargetBranch" "SUCCESS"
    
    # Step 10: Push merged changes
    Write-Log "Pushing merged changes to remote..."
    git push origin $TargetBranch
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push merged changes"
    }
    
    # Step 11: Delete source branch if requested
    if ($DeleteSource) {
        Write-Log "Deleting source branch: $SourceBranch"
        git push origin --delete $SourceBranch
        if ($LASTEXITCODE -eq 0) {
            Write-Log "Successfully deleted source branch" "SUCCESS"
        } else {
            Write-Log "Failed to delete source branch (may not have permission)" "WARNING"
        }
    }
    
    # Step 12: Restore stashed changes if any
    if (git stash list) {
        Write-Log "Restoring stashed changes..." "WARNING"
        git stash pop
    }
    
    Write-Log "✅ Auto-merge completed successfully!" "SUCCESS"
    
} catch {
    Write-Log "❌ Auto-merge failed: $($_.Exception.Message)" "ERROR"
    
    # Restore stashed changes if any
    if (git stash list) {
        Write-Log "Restoring stashed changes after error..." "WARNING"
        git stash pop
    }
    
    exit 1
}
