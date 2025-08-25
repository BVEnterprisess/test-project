# Auto-Commit Git Repository Script
# This script automatically stages and commits changes

param(
    [string]$CommitMessage = "Auto-commit: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')",
    [switch]$Push = $false,
    [switch]$Force = $false,
    [string]$Files = ".",
    [switch]$Verbose = $false
)

Write-Host "📝 Starting Auto-Commit Process..." -ForegroundColor Cyan

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

# Function to check if there are changes to commit
function Test-ChangesToCommit {
    $status = git status --porcelain
    return $status -ne ""
}

# Function to get list of changed files
function Get-ChangedFiles {
    $status = git status --porcelain
    $files = @()
    foreach ($line in $status -split "`n") {
        if ($line -match '^..\s+(.+)$') {
            $files += $matches[1]
        }
    }
    return $files
}

try {
    # Step 1: Check current status
    Write-Log "Checking repository status..."
    $currentBranch = git branch --show-current
    Write-Log "Current branch: $currentBranch"
    
    # Step 2: Check for changes
    if (-not (Test-ChangesToCommit)) {
        Write-Log "No changes detected to commit" "WARNING"
        exit 0
    }
    
    # Step 3: Show what will be committed
    Write-Log "Changes detected:"
    $changedFiles = Get-ChangedFiles
    foreach ($file in $changedFiles) {
        Write-Log "  - $file"
    }
    
    # Step 4: Stage files
    Write-Log "Staging files..."
    if ($Files -eq ".") {
        git add .
    } else {
        git add $Files
    }
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to stage files"
    }
    
    # Step 5: Commit changes
    Write-Log "Committing changes with message: $CommitMessage"
    git commit -m $CommitMessage
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to commit changes"
    }
    
    Write-Log "Successfully committed changes" "SUCCESS"
    
    # Step 6: Push if requested
    if ($Push) {
        Write-Log "Pushing changes to remote..."
        if ($Force) {
            git push --force-with-lease origin main
        } else {
            git push origin main
        }
        if ($LASTEXITCODE -ne 0) {
            throw "Failed to push changes to remote"
        }
        Write-Log "Successfully pushed changes to remote" "SUCCESS"
    }
    
    # Step 7: Show commit info
    $lastCommit = git log --oneline -1
    Write-Log "Last commit: $lastCommit" "SUCCESS"
    
    Write-Log "✅ Auto-commit completed successfully!" "SUCCESS"
    
} catch {
    Write-Log "❌ Auto-commit failed: $($_.Exception.Message)" "ERROR"
    exit 1
}
