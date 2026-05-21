cmake_minimum_required(VERSION 3.15)
set(PROJECT_NAME "flutter_webrtc")
project(${PROJECT_NAME} LANGUAGES CXX)

if (CMAKE_VERSION VERSION_GREATER_EQUAL "3.24.0")
  cmake_policy(SET CMP0135 NEW)
endif()

# Add the libwebrtc dependency
include("${CMAKE_CURRENT_SOURCE_DIR}/../third_party/CMakeLists.txt")

# Flutter sets this for Windows x64 and ARM64 builds; older toolchains default to x64.
if(NOT DEFINED FLUTTER_TARGET_PLATFORM)
  set(FLUTTER_TARGET_PLATFORM "windows-x64")
endif()

if(FLUTTER_TARGET_PLATFORM STREQUAL "windows-x64")
  set(LIBWEBRTC_PLATFORM_DIR "win64")
elseif(FLUTTER_TARGET_PLATFORM STREQUAL "windows-arm64")
  set(LIBWEBRTC_PLATFORM_DIR "windows-arm64")
else()
  message(FATAL_ERROR
    "flutter_webrtc: Unsupported FLUTTER_TARGET_PLATFORM '${FLUTTER_TARGET_PLATFORM}'. "
    "Supported: windows-x64, windows-arm64")
endif()

set(LIBWEBRTC_ROOT "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/libwebrtc")
set(LIBWEBRTC_LIB_DIR "${LIBWEBRTC_ROOT}/lib/${LIBWEBRTC_PLATFORM_DIR}")
set(LIBWEBRTC_DLL "${LIBWEBRTC_LIB_DIR}/libwebrtc.dll")
set(LIBWEBRTC_IMPLIB "${LIBWEBRTC_LIB_DIR}/libwebrtc.dll.lib")

if(NOT EXISTS "${LIBWEBRTC_DLL}")
  message(FATAL_ERROR
    "flutter_webrtc: Missing ${LIBWEBRTC_DLL}\n"
    "Downloaded from ${LIBWEBRTC_DOWNLOAD_URL} (see third_party/CMakeLists.txt).\n"
    "Ensure libwebrtc.zip contains lib/${LIBWEBRTC_PLATFORM_DIR}/ for this platform.")
endif()
if(NOT EXISTS "${LIBWEBRTC_IMPLIB}")
  message(FATAL_ERROR
    "flutter_webrtc: Missing ${LIBWEBRTC_IMPLIB}")
endif()

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "flutter_webrtc_plugin")

add_definitions(-DLIB_WEBRTC_API_DLL)
add_definitions(-DRTC_DESKTOP_DEVICE)

add_library(${PLUGIN_NAME} SHARED
  "../common/cpp/src/flutter_common.cc"
  "../common/cpp/src/flutter_data_channel.cc"
  "../common/cpp/src/flutter_data_packet_cryptor.cc"
  "../common/cpp/src/flutter_frame_cryptor.cc"
  "../common/cpp/src/flutter_media_stream.cc"
  "../common/cpp/src/flutter_utf8_sanitize.cc"
  "../common/cpp/src/flutter_peerconnection.cc"
  "../common/cpp/src/flutter_frame_capturer.cc"
  "../common/cpp/src/flutter_video_renderer.cc"
  "../common/cpp/src/flutter_screen_capture.cc"
  "../common/cpp/src/flutter_webrtc.cc"
  "../common/cpp/src/flutter_webrtc_base.cc"
  "flutter_webrtc_plugin.cc"
  "task_runner_windows.cc"
)

include_directories(
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../common/cpp/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/svpng"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/libwebrtc/include"
)

apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}"
  "${CMAKE_CURRENT_SOURCE_DIR}/../common/cpp/include"
  "${CMAKE_CURRENT_SOURCE_DIR}/../third_party/libwebrtc/include"
)
target_link_libraries(${PLUGIN_NAME} PRIVATE
  flutter
  flutter_wrapper_plugin
  "${LIBWEBRTC_IMPLIB}"
)

# List of absolute paths to libraries that should be bundled with the plugin
set(flutter_webrtc_bundled_libraries
  "${LIBWEBRTC_DLL}"
  PARENT_SCOPE
)
