#Requires -Version 5.1
Set-StrictMode -Version Latest

$Path = $PSScriptRoot
$Root = Split-Path $Path -Parent
$Repo = Get-Item $Root

$Bucket = [PSCustomObject]@{
    path = $Root
    name = $Repo.Name
    manifest = "$($Root)\bucket"
    description = 'Custom scoop bucket for GUI and CLI apps'
    homepage = 'https://github.com/omardev29/extras-plus'
}

Write-Host "Bucket: $($Bucket.name)" -ForegroundColor Cyan

$app = $Args[0]

if (-not $app) {
    Write-Host "Usage: .\auto-pr.ps1 <app> [<rest>]" -ForegroundColor Yellow
    exit 1
}

$rest = $Args[1..($Args.Length)] -join ' '

bin\checkver.ps1 $app $rest
bin\checkurls.ps1 $app $rest
scoop hold $app

bin\checkver.ps1 $app -u

if ($LASTEXITCODE -ne 0) {
    exit 1
}

git status

if ($LASTEXITCODE -ne 0) {
    Write-Host "No changes detected." -ForegroundColor Yellow
    exit 0
}

git add .
git commit -m "chore(bucket): update $app"
git push origin HEAD
