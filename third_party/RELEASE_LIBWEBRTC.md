# Publishing libwebrtc binaries

## Full archive (`libwebrtc.zip`)

Used by Linux, eLinux, and Windows x64. Attached to releases as `libwebrtc.zip`.

1. Build or refresh platform binaries per [webrtc-sdk/libwebrtc](https://github.com/webrtc-sdk/libwebrtc).
2. Lay out under `libwebrtc/lib/` (`win64`, `linux-x64`, `linux-arm64`, etc.).
3. Zip the `libwebrtc/` folder contents.
4. Upload to a GitHub release and set `LIBWEBRTC_RELEASE_VERSION` in [CMakeLists.txt](CMakeLists.txt).

## Windows ARM64 supplement (`libwebrtc-windows-arm64.zip`)

Windows on ARM uses a **separate** zip so the main `libwebrtc.zip` does not need to be rebuilt for every ARM64 refresh.

1. Build on Windows 11 ARM64 — see [BUILD_WINDOWS_ARM64.md](BUILD_WINDOWS_ARM64.md).
2. Package:

```powershell
third_party\scripts\package_libwebrtc_windows_arm64_zip.ps1 `
  -WindowsArm64BuildDir "build\libwebrtc_src\src\out\Windows-arm64"
```

3. Upload `third_party/downloads/libwebrtc-windows-arm64.zip` (+ `.shasum`) to release **v1.4.2** (or newer).

**Automated (recommended):** push this repo and run the GitHub Actions workflow
[Publish libwebrtc Windows ARM64](https://github.com/advforks/flutter-webrtc/actions/workflows/publish-libwebrtc-windows-arm64.yml)
(`workflow_dispatch`, tag `v1.4.2`). It builds on `windows-11-arm` and uploads the assets.

```bash
gh workflow run publish-libwebrtc-windows-arm64.yml -f release_tag=v1.4.2
```

4. Optionally merge into the main zip with [package_libwebrtc_zip.ps1](scripts/package_libwebrtc_zip.ps1) for a single download.
5. To serve all pub.dev users from upstream, mirror the same assets to `flutter-webrtc/flutter-webrtc` release **v1.4.2** and set `LIBWEBRTC_GITHUB_REPO` to `flutter-webrtc/flutter-webrtc`.

CMake downloads the supplement automatically when `FLUTTER_TARGET_PLATFORM` is `windows-arm64` and `lib/windows-arm64/` is missing from the extracted main archive.

## Version tags

| Asset | CMake variable | Default tag |
|-------|----------------|-------------|
| `libwebrtc.zip` | `LIBWEBRTC_RELEASE_VERSION` | `v1.4.0` |
| `libwebrtc-windows-arm64.zip` | `LIBWEBRTC_WINDOWS_ARM64_RELEASE_VERSION` / `LIBWEBRTC_GITHUB_REPO` | `v1.4.2` / `advforks/flutter-webrtc` |

After publishing ARM64 assets, bump defaults in [CMakeLists.txt](CMakeLists.txt) and [windows/CMakeLists.txt](../windows/CMakeLists.txt) if the tag changes.
