param (
    [Parameter(Mandatory=$false)]
    [string]$Organization = "OWASP",
    [Parameter(Mandatory=$false)]
    [int]$Limit = 50,
    [string]$TargetDir = "data/raw/repos"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
}

$oneMonthAgo = (Get-Date).AddMonths(-1).ToString("yyyy-MM-dd")
Write-Host "Fetching up to $Limit active repositories from $Organization updated since $oneMonthAgo..." -ForegroundColor Cyan

try {
    # Fetch repos using GitHub CLI
    $reposOutput = gh repo list $Organization --json nameWithOwner,pushedAt -L $Limit
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to fetch repositories using gh CLI"
    }

    $allRepos = $reposOutput | ConvertFrom-Json
    $activeRepos = $allRepos | Where-Object { $_.pushedAt -ge $oneMonthAgo }
    $Repositories = $activeRepos | Select-Object -ExpandProperty nameWithOwner
} catch {
    Write-Error "Error fetching repositories`: $_"
}

if (-not $Repositories) {
    Write-Host "No active repositories found in the last month." -ForegroundColor Yellow
    exit
}

Write-Host "Starting extraction of $($Repositories.Count) repositories..." -ForegroundColor Cyan

foreach ($repo in $Repositories) {
    $repoName = ($repo -split "/")[-1]
    $repoPath = Join-Path $TargetDir $repoName
    
    if (Test-Path $repoPath) {
        Write-Host "Repository $repo already exists at $repoPath. Skipping clone." -ForegroundColor Yellow
        continue
    }

    Write-Host "Cloning $repo into $repoPath..." -ForegroundColor Green
    try {
        gh repo clone $repo $repoPath
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to clone $repo using gh CLI"
        }
    } catch {
        Write-Error "Error during clone of $repo`: $_"
    }
}

Write-Host "Extraction complete." -ForegroundColor Cyan
