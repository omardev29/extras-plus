$dir = Split-Path $PSScriptRoot
$root = Split-Path $dir -Parent

$wc = New-Object Net.WebClient
$wc.Headers.Add('User-Agent', 'Scoop-Bucket-CI')
$schema = ($wc.DownloadString('https://raw.githubusercontent.com/ScoopInstaller/Scoop/master/schema.json') | ConvertFrom-Json)

$validates = $true

Get-ChildItem "$dir\bucket" -Filter '*.json' -Recurse | ForEach-Object {
    $manifest = $_ | Get-Content -Raw | ConvertFrom-Json

    $errors = @()

    if (-not $manifest.version) { $errors += 'Missing version' }
    if (-not $manifest.homepage) { $errors += 'Missing homepage' }
    if (-not $manifest.license) { $errors += 'Missing license' }

    if ($manifest.architecture) {
        foreach ($arch in @('64bit', '32bit', 'arm64')) {
            $archObj = $manifest.architecture.PSObject.Properties[$arch]
            if ($archObj) {
                if (-not $archObj.Value.url) { $errors += "Missing url for architecture $arch" }
            }
        }
    } elseif (-not $manifest.url) {
        $errors += 'Missing url (no architecture or top-level url)'
    }

    if ($errors.Count -gt 0) {
        Write-Host "FAILED: $($_.Name)" -ForegroundColor Red
        foreach ($err in $errors) {
            Write-Host "  - $err" -ForegroundColor Red
        }
        $validates = $false
    } else {
        Write-Host "PASSED: $($_.Name)" -ForegroundColor Green
    }
}

if (-not $validates) {
    throw "One or more manifests failed validation"
}
