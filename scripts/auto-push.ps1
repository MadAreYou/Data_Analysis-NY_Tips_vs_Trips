param(
    [string]$Message
)

$ErrorActionPreference = 'Stop'

# Default commit message if none provided
if (-not $Message -or $Message.Trim().Length -eq 0) {
    $Message = "chore: auto-push $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')"
}

# Ensure we're in a git repo
$null = git rev-parse --is-inside-work-tree 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "Not a git repository." -ForegroundColor Red
    exit 1
}

# Stage everything, commit if there are changes, then push to dev
# Note: will no-op if nothing changed

git add -A

# Check if there is anything to commit
$diff = git diff --cached --name-only
if ([string]::IsNullOrWhiteSpace($diff)) {
    Write-Host "No staged changes to commit." -ForegroundColor Yellow
    exit 0
}

# Commit and push
Write-Host "Committing with message: $Message" -ForegroundColor Cyan
git commit -m $Message | Write-Host

# Ensure dev branch exists locally and push
$currentBranch = (git rev-parse --abbrev-ref HEAD).Trim()
if ($currentBranch -ne 'dev') {
    Write-Host "Current branch is '$currentBranch'. Switching to 'dev'..." -ForegroundColor Yellow
    git checkout dev 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Creating local 'dev' branch..." -ForegroundColor Yellow
        git checkout -b dev | Out-Null
    }
}

Write-Host "Pushing to origin/dev..." -ForegroundColor Green
git push -u origin dev
