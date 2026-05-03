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

Get-ChildItem "$PSScriptRoot\..\bucket" -Filter '*.json' -Recurse | ForEach-Object {
    if ($Args[0]) {
        if ($_.BaseName -ne $Args[0]) { return }
    }

    $manifest = parse_json $_.FullName
    $hasError = $false

    $urls = @()
    if ($manifest.url) { $urls += $manifest.url }
    if ($manifest.architecture) {
        $manifest.architecture.PSObject.Properties | ForEach-Object {
            if ($_.Value.url) { $urls += $_.Value.url }
        }
    }

    if ($urls.Count -eq 0) {
        Write-Host "$($_.BaseName): no URLs found" -ForegroundColor Yellow
        return
    }

    foreach ($url in $urls) {
        Write-Host "Checking: $($_.BaseName) -> $url" -ForegroundColor Cyan
        try {
            $response = Invoke-WebRequest -Uri $url -Method Head -UseBasicParsing -TimeoutSec 30
            if ($response.StatusCode -eq 200) {
                Write-Host "  OK ($($response.ContentLength) bytes)" -ForegroundColor Green
            } else {
                Write-Host "  FAILED (HTTP $($response.StatusCode))" -ForegroundColor Red
                $hasError = $true
            }
        } catch {
            Write-Host "  FAILED ($($_.Exception.Message))" -ForegroundColor Red
            $hasError = $true
        }
    }

    if (-not $hasError) {
        Write-Host "$($_.BaseName): all URLs valid" -ForegroundColor Green
    }
}
