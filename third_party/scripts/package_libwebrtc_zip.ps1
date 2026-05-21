# Adds Windows ARM64 libwebrtc artifacts to libwebrtc.zip for GitHub release.
param(
    [string]$ZipPath = "$PSScriptRoot\..\downloads\libwebrtc.zip",
    [Parameter(Mandatory = $true)]
    [string]$WindowsArm64BuildDir,
    [string]$OutputZipPath = ""
)

$ErrorActionPreference = "Stop"

$dll = Join-Path $WindowsArm64BuildDir "libwebrtc.dll"
$lib = Join-Path $WindowsArm64BuildDir "libwebrtc.dll.lib"

if (-not (Test-Path $dll)) { throw "Missing $dll" }
if (-not (Test-Path $lib)) { throw "Missing $lib" }
if (-not (Test-Path $ZipPath)) { throw "Missing zip: $ZipPath" }

$staging = Join-Path $env:TEMP "libwebrtc_zip_staging_$(New-Guid)"
New-Item -ItemType Directory -Path $staging -Force | Out-Null

try {
    Expand-Archive -Path $ZipPath -DestinationPath $staging -Force

    $targetDir = Join-Path $staging "libwebrtc\lib\windows-arm64"
    New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
    Copy-Item $dll $targetDir -Force
    Copy-Item $lib $targetDir -Force

    if ([string]::IsNullOrEmpty($OutputZipPath)) {
        $OutputZipPath = $ZipPath
    }

    if ($OutputZipPath -eq $ZipPath) {
        Remove-Item $ZipPath -Force
    }

    Compress-Archive -Path (Join-Path $staging "libwebrtc") -DestinationPath $OutputZipPath -Force

    $hash = Get-FileHash -Path $OutputZipPath -Algorithm SHA256
    $shasumPath = "$OutputZipPath.shasum"
    Set-Content -Path $shasumPath -Value "$($hash.Hash)  $(Split-Path -Leaf $OutputZipPath)" -NoNewline

    Write-Host "Updated: $OutputZipPath"
    Write-Host "SHA256: $($hash.Hash)"
    Write-Host "Wrote: $shasumPath"
}
finally {
    Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
}
