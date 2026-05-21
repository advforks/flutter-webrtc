# Creates libwebrtc-windows-arm64.zip for GitHub release (ARM64-only supplement).
param(
    [Parameter(Mandatory = $true)]
    [string]$WindowsArm64BuildDir,
    [string]$OutputZipPath = "$PSScriptRoot\..\downloads\libwebrtc-windows-arm64.zip"
)

$ErrorActionPreference = "Stop"

$dll = Join-Path $WindowsArm64BuildDir "libwebrtc.dll"
$lib = Join-Path $WindowsArm64BuildDir "libwebrtc.dll.lib"

if (-not (Test-Path $dll)) { throw "Missing $dll" }
if (-not (Test-Path $lib)) { throw "Missing $lib" }

$staging = Join-Path $env:TEMP "libwebrtc_arm64_zip_$(New-Guid)"
$targetDir = Join-Path $staging "libwebrtc\lib\windows-arm64"
New-Item -ItemType Directory -Path $targetDir -Force | Out-Null

try {
    Copy-Item $dll $targetDir -Force
    Copy-Item $lib $targetDir -Force

    if (Test-Path $OutputZipPath) {
        Remove-Item $OutputZipPath -Force
    }

    # Zip must contain top-level libwebrtc/ so CMake extract into third_party/ is correct.
    Compress-Archive -Path (Join-Path $staging "libwebrtc") -DestinationPath $OutputZipPath -Force

    $hash = Get-FileHash -Path $OutputZipPath -Algorithm SHA256
    $shasumPath = "$OutputZipPath.shasum"
    Set-Content -Path $shasumPath -Value "$($hash.Hash)  $(Split-Path -Leaf $OutputZipPath)" -NoNewline

    Write-Host "Created: $OutputZipPath"
    Write-Host "SHA256: $($hash.Hash)"
    Write-Host "Upload to GitHub release ${LIBWEBRTC_WINDOWS_ARM64_RELEASE_VERSION:-v1.4.2} as libwebrtc-windows-arm64.zip"
}
finally {
    Remove-Item $staging -Recurse -Force -ErrorAction SilentlyContinue
}
