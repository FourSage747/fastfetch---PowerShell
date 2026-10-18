$ErrorActionPreference = "Stop"

Write-Host "Starting custom terminal installation..." -ForegroundColor Cyan

# 1. Check and install fastfetch
if (!(Get-Command fastfetch -ErrorAction SilentlyContinue)) {
    Write-Host "fastfetch not found. Installing via winget..." -ForegroundColor Yellow
    winget install fastfetch --accept-package-agreements --accept-source-agreements
} else {
    Write-Host "[OK] fastfetch is already installed." -ForegroundColor Green
}

# 2. Create config directories
$ConfigDir = "$env:USERPROFILE\.config\fastfetch"
if (!(Test-Path $ConfigDir)) {
    New-Item -Path $ConfigDir -ItemType Directory -Force | Out-Null
    Write-Host "[OK] Created directory $ConfigDir" -ForegroundColor Green
}

# 3. Copy logo.txt
$RepoDir = $PSScriptRoot
Copy-Item -Path "$RepoDir\logo.txt" -Destination "$ConfigDir\logo.txt" -Force
Write-Host "[OK] Logo copied." -ForegroundColor Green

# 4. Copy config and replace logo path dynamically
$LogoPath = "$ConfigDir\logo.txt".Replace('\', '\\')
$ConfigContent = Get-Content -Path "$RepoDir\config.jsonc" -Raw
$ConfigContent = $ConfigContent -replace '__LOGO_PATH__', $LogoPath
Set-Content -Path "$ConfigDir\config.jsonc" -Value $ConfigContent
Write-Host "[OK] Configuration applied." -ForegroundColor Green

# 5. Add fastfetch to profile
$ProfilePath = $PROFILE
if (!(Test-Path $ProfilePath)) {
    New-Item -Path $ProfilePath -ItemType File -Force | Out-Null
}

$ProfileContent = Get-Content $ProfilePath -Raw
if ($ProfileContent -notmatch "\bfastfetch\b") {
    Add-Content -Path $ProfilePath -Value "`nfastfetch"
    Write-Host "[OK] fastfetch added to autorun." -ForegroundColor Green
} else {
    Write-Host "[OK] fastfetch is already in autorun." -ForegroundColor Green
}

Write-Host "Installation complete! Restart PowerShell or open a new tab." -ForegroundColor Cyan