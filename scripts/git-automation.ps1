# Git Automation Master Script
# This script provides a unified interface for all Git automation operations

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("sync", "commit", "pull", "merge", "status", "all")]
    [string]$Operation,
    [string]$CommitMessage = "",
    [string]$SourceBranch = "",
    [string]$TargetBranch = "main",
    [switch]$Push = $false,
    [switch]$Force = $false,
    [switch]$Rebase = $true,
    [switch]$DeleteSource = $false
)

Write-Host "🤖 Git Automation Master Script" -ForegroundColor Cyan
Write-Host "Operation: $Operation" -ForegroundColor Yellow

# Get the script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Function to run a script
function Invoke-GitScript {
    param([string]$ScriptName, [string]$Arguments = "")
    
    $scriptPath = Join-Path $ScriptDir $ScriptName
    if (Test-Path $scriptPath) {
        Write-Host "Running $ScriptName..." -ForegroundColor Green
        & $scriptPath $Arguments
        return $LASTEXITCODE
    } else {
        Write-Host "Script not found: $scriptPath" -ForegroundColor Red
        return 1
    }
}

# Function to show status
function Show-Status {
    Write-Host "📊 Repository Status:" -ForegroundColor Cyan
    git status
    Write-Host "`n📈 Recent Commits:" -ForegroundColor Cyan
    git log --oneline -5
    Write-Host "`n🌿 Branches:" -ForegroundColor Cyan
    git branch -a
}

try {
    switch ($Operation.ToLower()) {
        "sync" {
            $args = ""
            if ($CommitMessage) { $args += " -CommitMessage '$CommitMessage'" }
            if ($Force) { $args += " -Force" }
            if ($Verbose) { $args += " -Verbose" }
            
            Invoke-GitScript "auto-sync.ps1" $args
        }
        
        "commit" {
            $args = ""
            if ($CommitMessage) { $args += " -CommitMessage '$CommitMessage'" }
            if ($Push) { $args += " -Push" }
            if ($Force) { $args += " -Force" }
            if ($Verbose) { $args += " -Verbose" }
            
            Invoke-GitScript "auto-commit.ps1" $args
        }
        
        "pull" {
            $args = "-Branch $TargetBranch"
            if (-not $Rebase) { $args += " -Rebase:`$false" }
            if ($Force) { $args += " -Force" }
            if ($Verbose) { $args += " -Verbose" }
            
            Invoke-GitScript "auto-pull.ps1" $args
        }
        
        "merge" {
            if (-not $SourceBranch) {
                throw "SourceBranch is required for merge operation"
            }
            
            $args = "-SourceBranch $SourceBranch -TargetBranch $TargetBranch"
            if ($Force) { $args += " -Force" }
            if ($DeleteSource) { $args += " -DeleteSource" }
            if ($Verbose) { $args += " -Verbose" }
            
            Invoke-GitScript "auto-merge.ps1" $args
        }
        
        "status" {
            Show-Status
        }
        
        "all" {
            Write-Host "🔄 Running full automation sequence..." -ForegroundColor Magenta
            
            # 1. Pull latest changes
            Write-Host "Step 1: Pulling latest changes..." -ForegroundColor Blue
            $pullArgs = "-Branch $TargetBranch"
            if (-not $Rebase) { $pullArgs += " -Rebase:`$false" }
            Invoke-GitScript "auto-pull.ps1" $pullArgs
            
            # 2. Commit any local changes
            Write-Host "Step 2: Committing local changes..." -ForegroundColor Blue
            $commitArgs = ""
            if ($CommitMessage) { $commitArgs += " -CommitMessage '$CommitMessage'" }
            if ($Push) { $commitArgs += " -Push" }
            Invoke-GitScript "auto-commit.ps1" $commitArgs
            
            # 3. Sync everything
            Write-Host "Step 3: Syncing repository..." -ForegroundColor Blue
            $syncArgs = ""
            if ($CommitMessage) { $syncArgs += " -CommitMessage '$CommitMessage'" }
            if ($Force) { $syncArgs += " -Force" }
            Invoke-GitScript "auto-sync.ps1" $syncArgs
            
            Write-Host "✅ Full automation sequence completed!" -ForegroundColor Green
        }
    }
    
} catch {
    Write-Host "❌ Automation failed: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
