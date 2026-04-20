param (
    [Parameter(Mandatory=$false)]
    [string[]]$Repositories = @(
        "OWASP/NodeGoat",
        "OWASP/DevSlop"
    ),
    [string]$TargetDir = "data/repos"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null
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