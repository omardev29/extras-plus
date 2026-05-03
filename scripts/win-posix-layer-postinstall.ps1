# Post-install script for win-posix-layer
# This script adds the Import-Module command to the user's PowerShell profile

$profileDir = "$env:USERPROFILE\Documents\PowerShell"
$null = New-Item $profileDir -ItemType Directory -Force

$profilePath = Join-Path $profileDir "Microsoft.PowerShell_profile.ps1"

# Find the installed module - Scoop installs to $env:USERPROFILE\scoop\apps\<app>\current
$appCurrent = "$env:USERPROFILE\scoop\apps\win-posix-layer\current"
$moduleFile = Get-ChildItem $appCurrent -Filter WinPosixLayer.psd1 -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

if (-not $moduleFile) {
    Write-Error "WinPosixLayer.psd1 not found in $appCurrent"
    exit 1
}

$modulePath = $moduleFile.FullName
$importCmd = "Import-Module ""$modulePath"""

if (Test-Path $profilePath) {
    $content = Get-Content $profilePath -Raw
    if ($content -notlike "*$modulePath*") {
        Add-Content $profilePath ""
        Add-Content $profilePath $importCmd
    }
} else {
    Set-Content $profilePath $importCmd
}

Write-Output "win-posix-layer: Module installed. Run 'Import-Module ""$modulePath""' to load it."
