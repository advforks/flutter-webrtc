include(ExternalProject)

# Single prebuilt archive for all desktop/embedded platforms (linux-*, win64, windows-arm64, elinux-*, etc.).
set(LIBWEBRTC_RELEASE_VERSION "v1.4.0" CACHE STRING
  "GitHub release tag for libwebrtc.zip")

set(LIBWEBRTC_DOWNLOAD_URL
  "https://github.com/flutter-webrtc/flutter-webrtc/releases/download/${LIBWEBRTC_RELEASE_VERSION}/libwebrtc.zip"
  CACHE STRING "URL for libwebrtc prebuilt binaries")

set(ZIPFILE "${CMAKE_CURRENT_LIST_DIR}/downloads/libwebrtc.zip")
set(DOWNLOAD_URL "${LIBWEBRTC_DOWNLOAD_URL}")

if(NOT EXISTS "${ZIPFILE}")
  message(NOTICE "download: ${DOWNLOAD_URL}")
  file(DOWNLOAD "${DOWNLOAD_URL}"
    ${ZIPFILE}
    STATUS download_status
    LOG download_log)

  if(NOT download_status EQUAL 0)
    message(FATAL_ERROR "Failed to download dependency: ${download_log}")
  endif()

  file(ARCHIVE_EXTRACT INPUT ${ZIPFILE} DESTINATION "${CMAKE_CURRENT_LIST_DIR}")
else()
  if(NOT EXISTS "${CMAKE_CURRENT_LIST_DIR}/libwebrtc")
    message(NOTICE "libwebrtc directory does not exist after extraction.")
    file(ARCHIVE_EXTRACT INPUT ${ZIPFILE} DESTINATION "${CMAKE_CURRENT_LIST_DIR}")
  endif()
  message(TRACE "libwebrtc already downloaded.")
endif()
