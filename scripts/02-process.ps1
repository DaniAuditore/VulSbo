param (
    [string]$ReposDir = "data/repos",
    [string]$RawDataDir = "data/raw"
)

$ErrorActionPreference = "Stop"

if (-not (Test-Path $RawDataDir)) {
    New-Item -ItemType Directory -Force -Path $RawDataDir | Out-Null
}

$repos = Get-ChildItem -Path $ReposDir -Directory

if ($repos.Count -eq 0) {
    Write-Warning "No repositories found in $ReposDir. Please run 01-extract.ps1 first."
    exit
}

Write-Host "Starting SBOM generation and vulnerability scanning for $($repos.Count) repositories..." -ForegroundColor Cyan

foreach ($repo in $repos) {
    $repoName = $repo.Name
    $sbomPath = Join-Path $RawDataDir "$repoName-sbom.json"
    $vulnPath = Join-Path $RawDataDir "$repoName-vulns.json"

    Write-Host "Processing repository: $repoName" -ForegroundColor Yellow

    # Generate SBOM using syft
    Write-Host "  -> Generating SBOM..." -ForegroundColor Green
    try {
        syft packages dir:$($repo.FullName) -o json=$sbomPath -q
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to run syft on $($repo.FullName)"
        }
    } catch {
        Write-Error "Error running syft on $repoName`: $_"
        continue
    }

    # Generate Vulnerability Report using grype
    Write-Host "  -> Scanning for vulnerabilities..." -ForegroundColor Green
    try {
        grype sbom:$sbomPath -o json > $vulnPath
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to run grype on $sbomPath"
        }
    } catch {
        Write-Error "Error running grype on $repoName`: $_"
    }
}

Write-Host "Processing complete. Output files saved in $RawDataDir." -ForegroundColor Cyan