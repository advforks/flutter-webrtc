# Sync webrtc-sdk/webrtc (m144) + libwebrtc wrapper for Windows builds.
param(
    [string]$RootDir = "$PSScriptRoot\..\..\build\libwebrtc_src"
)

$ErrorActionPreference = "Stop"

New-Item -ItemType Directory -Force -Path $RootDir | Out-Null
Set-Location $RootDir

if (-not (Test-Path ".gclient")) {
    @"
solutions = [
  {
    "name": "src",
    "url": "https://github.com/webrtc-sdk/webrtc.git@m144_release",
    "deps_file": "DEPS",
    "managed": False,
    "custom_deps": {},
    "custom_vars": {},
  },
]
target_os = ["win"]
"@ | Set-Content -Path ".gclient" -Encoding UTF8
}

if (-not (Get-Command gclient -ErrorAction SilentlyContinue)) {
    throw "gclient not found. Install depot_tools and add it to PATH."
}

Write-Host "Running gclient sync in $RootDir (this may take a long time)..."
gclient sync -D

Set-Location "$RootDir\src"

if (-not (Test-Path "libwebrtc")) {
    git clone https://github.com/webrtc-sdk/libwebrtc
}

git -C libwebrtc fetch --depth 1 origin main 2>$null
git -C libwebrtc checkout main 2>$null

git -C libwebrtc apply --check patchs/custom_audio_source_m144.patch 2>$null
if ($LASTEXITCODE -eq 0) {
    git -C libwebrtc apply patchs/custom_audio_source_m144.patch
}

$buildGn = Get-Content "BUILD.gn" -Raw
if ($buildGn -notmatch '//libwebrtc') {
    if ($buildGn -match 'deps = \[ ":webrtc" \]') {
        $buildGn = $buildGn -replace 'deps = \[ ":webrtc" \]', 'deps = [ ":webrtc","//libwebrtc", ]'
    } else {
        Write-Warning "Could not auto-patch BUILD.gn; add //libwebrtc to group(default) deps manually."
    }
    Set-Content -Path "BUILD.gn" -Value $buildGn -NoNewline
    Write-Host "Patched src/BUILD.gn to include //libwebrtc"
}

Write-Host "WebRTC source ready under $RootDir\src"
