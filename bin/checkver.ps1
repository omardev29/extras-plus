#Requires -Version 5.1
#Requires -Modules @{ ModuleName = 'scoop'; ModuleVersion = '0.3.0' }
param(
    [String] $AppName = $null,
    [Switch] $ForceUpdate = $false,
    [Switch] $Version = $false
)

Set-StrictMode -Version Latest

. "$PSScriptRoot\..\bucket\test.ps1"

Get-ChildItem "$PSScriptRoot\..\bucket" -Filter '*.json' -Recurse | ForEach-Object {
    if ($AppName) {
        if ($_.BaseName -ne $AppName) { return }
    }

    $manifest = parse_json $_.FullName

    if ($manifest.checkver) {
        if ($Version) {
            Write-Host "$($_.BaseName): $($manifest.version)" -ForegroundColor Cyan
            return
        }

        $newVersion = $null
        $errorOccurred = $false

        try {
            $checkverResult = Invoke-Expression "scoop checkver $($_.BaseName) -s" 2>$null
            if ($checkverResult) {
                $newVersion = ($checkverResult | Select-String '(\d+\.\d+\.\d+[^ ]*)' -AllMatches | ForEach-Object { $_.Matches[0].Groups[1].Value } | Select-Object -First 1)
            }
        } catch {
            $errorOccurred = $true
        }

        if ($newVersion -and ($newVersion -ne $manifest.version)) {
            Write-Host "$($_.BaseName): $($manifest.version) -> $newVersion" -ForegroundColor Green
            if ($ForceUpdate) {
                Write-Host "Updating $($_.BaseName) to $newVersion" -ForegroundColor Yellow
            }
        } elseif (-not $errorOccurred) {
            Write-Host "$($_.BaseName): $($manifest.version) (latest)" -ForegroundColor DarkGray
        }
    }
}
