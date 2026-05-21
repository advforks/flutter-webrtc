# Building libwebrtc for Windows ARM64

Prebuilt `libwebrtc.dll` for **windows-arm64** is shipped inside the release asset
[`libwebrtc.zip`](https://github.com/flutter-webrtc/flutter-webrtc/releases).
This document describes how maintainers produce that binary with the
[webrtc-sdk/libwebrtc](https://github.com/webrtc-sdk/libwebrtc) wrapper and WebRTC **m144**
(aligned with plugin release `144.7559.04` on mobile).

## Requirements

- Windows 11 **ARM64** host (recommended) or a working cross-compile toolchain
- [Visual Studio 2022](https://visualstudio.microsoft.com/) with **Desktop development with C++** and **Windows 11 SDK**
- [depot_tools](https://commondatastorage.googleapis.com/chrome-infra-docs/flat/depot_tools/docs/html/depot_tools_tutorial.html) on `PATH` (`gn`, `ninja`, `gclient`)

## Sync WebRTC + libwebrtc (one-time)

From the repository root:

```bat
mkdir build\libwebrtc_src
cd build\libwebrtc_src
```

Create `.gclient`:

```python
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
```

Then:

```bat
gclient sync
cd src
git clone https://github.com/webrtc-sdk/libwebrtc
git apply libwebrtc/patchs/custom_audio_source_m144.patch
```

Add `//libwebrtc` to `group("default")` deps in `BUILD.gn` (see
[libwebrtc README](https://github.com/webrtc-sdk/libwebrtc/blob/main/README.md)).

Keep **`libwebrtc_intel_media_sdk = false`** (Intel Media SDK is x64-only).

## Build

```bat
third_party\scripts\build_windows_arm64.bat
```

Or manually:

```bat
gn gen out/Windows-arm64 --args="target_os=\"win\" target_cpu=\"arm64\" is_component_build=false is_clang=true is_debug=false rtc_use_h264=true ffmpeg_branding=\"Chrome\" rtc_include_tests=false rtc_build_examples=false libwebrtc_desktop_capture=true"
ninja -C out/Windows-arm64 libwebrtc
```

Artifacts (typical paths under `out/Windows-arm64`):

- `libwebrtc.dll`
- `libwebrtc.dll.lib`

## Package for release

After a successful build, create the **Windows ARM64 supplement** (recommended):

```powershell
third_party\scripts\package_libwebrtc_windows_arm64_zip.ps1 `
  -WindowsArm64BuildDir "build\libwebrtc_src\src\out\Windows-arm64"
```

Upload `third_party/downloads/libwebrtc-windows-arm64.zip` to GitHub release **v1.4.2**
(see [RELEASE_LIBWEBRTC.md](RELEASE_LIBWEBRTC.md)). The plugin downloads this automatically on
`windows-arm64` builds when `lib/windows-arm64/` is not in the main `libwebrtc.zip`.

To merge ARM64 into the full archive instead:

```powershell
third_party\scripts\package_libwebrtc_zip.ps1 `
  -WindowsArm64BuildDir "build\libwebrtc_src\src\out\Windows-arm64"
```

Upload the updated `libwebrtc.zip` and bump `LIBWEBRTC_RELEASE_VERSION` in [CMakeLists.txt](CMakeLists.txt).

## Local development without a new release

Place ARM64 binaries manually:

```
third_party/libwebrtc/lib/windows-arm64/libwebrtc.dll
third_party/libwebrtc/lib/windows-arm64/libwebrtc.dll.lib
```

Then build with Flutter on Windows ARM64 (`FLUTTER_TARGET_PLATFORM=windows-arm64`).
