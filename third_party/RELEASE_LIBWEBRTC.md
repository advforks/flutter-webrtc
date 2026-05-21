# Publishing libwebrtc binaries

## Full archive (`libwebrtc.zip`)

Used by Linux, eLinux, and Windows x64. Attached to releases as `libwebrtc.zip`.

1. Build or refresh platform binaries per [webrtc-sdk/libwebrtc](https://github.com/webrtc-sdk/libwebrtc).
2. Lay out under `libwebrtc/lib/` (`win64`, `linux-x64`, `linux-arm64`, etc.).
3. Zip the `libwebrtc/` folder contents.
4. Upload to a GitHub release and set `LIBWEBRTC_RELEASE_VERSION` in [CMakeLists.txt](CMakeLists.txt).

## Windows ARM64 (`lib/windows-arm64/`)

Add ARM64 Windows binaries **into the same** `libwebrtc.zip` (recommended), not a separate download URL:

1. Build on Windows 11 ARM64 — see [BUILD_WINDOWS_ARM64.md](BUILD_WINDOWS_ARM64.md).
2. Merge into the main zip:

```powershell
third_party\scripts\package_libwebrtc_zip.ps1 `
  -WindowsArm64BuildDir "build\libwebrtc_src\src\out\Windows-arm64"
```

3. Upload the updated `libwebrtc.zip` to the same GitHub release and bump `LIBWEBRTC_RELEASE_VERSION` if the tag changes.

Optional: [package_libwebrtc_windows_arm64_zip.ps1](scripts/package_libwebrtc_windows_arm64_zip.ps1) builds a standalone zip for manual distribution only; CMake does not download it.

## Download URL (all platforms)

| Variable | Default |
|----------|---------|
| `LIBWEBRTC_DOWNLOAD_URL` | `https://github.com/flutter-webrtc/flutter-webrtc/releases/download/v1.4.0/libwebrtc.zip` |

Platform-specific paths after extract: `lib/win64/`, `lib/windows-arm64/`, `lib/linux-x64/`, `lib/linux-arm64/`, `lib/elinux-arm64/`, etc.
