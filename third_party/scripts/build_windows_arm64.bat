@echo off
REM Build libwebrtc.dll for Windows ARM64 (WebRTC m144 / webrtc-sdk).
REM Run on Windows 11 ARM64 with Visual Studio 2022 and depot_tools installed.
REM See BUILD_WINDOWS_ARM64.md for full setup.

setlocal enabledelayedexpansion

if /I not "%PROCESSOR_ARCHITECTURE%"=="ARM64" (
  echo WARNING: Building on %PROCESSOR_ARCHITECTURE%. Native ARM64 builds are recommended on ARM64 Windows.
)

set DEPOT_TOOLS_WIN_TOOLCHAIN=0
set GYP_MSVS_VERSION=2022
set GYP_GENERATORS=ninja,msvs-ninja
set GYP_MSVS_OVERRIDE_PATH=C:\Program Files\Microsoft Visual Studio\2022\Community

if not exist "%~dp0..\..\build\libwebrtc_src\src" (
  echo ERROR: WebRTC source not found at build\libwebrtc_src\src
  echo Follow third_party/BUILD_WINDOWS_ARM64.md to sync webrtc-sdk/webrtc @ m144_release.
  exit /b 1
)

cd /d "%~dp0..\..\build\libwebrtc_src\src"

gn gen out/Windows-arm64 --args="target_os=\"win\" target_cpu=\"arm64\" is_component_build=false is_clang=true is_debug=false rtc_use_h264=true ffmpeg_branding=\"Chrome\" rtc_include_tests=false rtc_build_examples=false libwebrtc_desktop_capture=true"
if errorlevel 1 exit /b 1

ninja -C out/Windows-arm64 libwebrtc
if errorlevel 1 exit /b 1

echo.
echo Build succeeded. Copy artifacts with:
echo   third_party\scripts\package_libwebrtc_zip.ps1 -WindowsArm64BuildDir "%CD%\out\Windows-arm64"

endlocal
