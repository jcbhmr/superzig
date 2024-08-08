#!/usr/bin/env -S cmake -P

if(NOT ZIG_VERSION)
  file(READ CMakeLists.txt cmake_lists_txt)
  string(REGEX MATCHALL "VERSION [0-9a-zA-Z_\\.\\-]+" version_matches
               "${cmake_lists_txt}")
  # First "VERSION 1.2.3" is the "cmake_minimum_required()" directive. Second
  # one is the "project()" directive which we want.
  list(GET version_matches 1 project_version_match)
  # Trim the "VERSION " prefix to get just the version specifier.
  string(SUBSTRING "${project_version_match}" 8 -1 project_version)
  # Discard any "-rc.1" or "-beta.2" suffixes.
  string(REGEX MATCH "[0-9]+\\.[0-9]+\\.[0-9]+" ZIG_VERSION
               "${project_version}")
  message(STATUS "Inferred ZIG_VERSION=${ZIG_VERSION} from CMakeLists.txt")
endif()

# By default file(DOWNLOAD) has silent errors.
function(file_download_ok url file)
  file(DOWNLOAD "${url}" "${file}" STATUS status)
  if(NOT status EQUAL 0)
    file(REMOVE "${file}")
    message(FATAL_ERROR "Failed to download ${url}")
  endif()
endfunction()

message(STATUS "Clearing build/generate folder")
file(REMOVE_RECURSE build/generate)
file(MAKE_DIRECTORY build/generate)

message(STATUS "Downloading zig-<os>-<arch>-${ZIG_VERSION} archives")
file_download_ok(
  "https://ziglang.org/download/${ZIG_VERSION}/zig-windows-x86_64-${ZIG_VERSION}.zip"
  build/generate/zig-windows-x86_64.zip)
file_download_ok(
  "https://ziglang.org/download/${ZIG_VERSION}/zig-windows-aarch64-${ZIG_VERSION}.zip"
  build/generate/zig-windows-aarch64.zip)
file_download_ok(
  "https://ziglang.org/download/${ZIG_VERSION}/zig-macos-aarch64-${ZIG_VERSION}.tar.xz"
  build/generate/zig-macos-aarch64.tar.xz)
file_download_ok(
  "https://ziglang.org/download/${ZIG_VERSION}/zig-macos-x86_64-${ZIG_VERSION}.tar.xz"
  build/generate/zig-macos-x86_64.tar.xz)
file_download_ok(
  "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-x86_64-${ZIG_VERSION}.tar.xz"
  build/generate/zig-linux-x86_64.tar.xz)
file_download_ok(
  "https://ziglang.org/download/${ZIG_VERSION}/zig-linux-aarch64-${ZIG_VERSION}.tar.xz"
  build/generate/zig-linux-aarch64.tar.xz)
file_download_ok(
  "https://ziglang.org/download/${ZIG_VERSION}/zig-freebsd-x86_64-${ZIG_VERSION}.tar.xz"
  build/generate/zig-freebsd-x86_64.tar.xz)
message(STATUS "Downloaded zig-<os>-<arch>-${ZIG_VERSION} archives")

message(STATUS "Extracting zig-<os>-<arch> archives")
file(ARCHIVE_EXTRACT INPUT build/generate/zig-windows-x86_64.zip DESTINATION
     build/generate)
file(ARCHIVE_EXTRACT INPUT build/generate/zig-windows-aarch64.zip DESTINATION
     build/generate)
file(ARCHIVE_EXTRACT INPUT build/generate/zig-macos-aarch64.tar.xz DESTINATION
     build/generate)
file(ARCHIVE_EXTRACT INPUT build/generate/zig-macos-x86_64.tar.xz DESTINATION
     build/generate)
file(ARCHIVE_EXTRACT INPUT build/generate/zig-linux-x86_64.tar.xz DESTINATION
     build/generate)
file(ARCHIVE_EXTRACT INPUT build/generate/zig-linux-aarch64.tar.xz DESTINATION
     build/generate)
file(ARCHIVE_EXTRACT INPUT build/generate/zig-freebsd-x86_64.tar.xz DESTINATION
     build/generate)
message(STATUS "Extracted zig-<os>-<arch> archives")

message(STATUS "Removing zig-<os>-<arch> archives")
file(REMOVE build/generate/zig-windows-x86_64.zip)
file(REMOVE build/generate/zig-windows-aarch64.zip)
file(REMOVE build/generate/zig-macos-aarch64.tar.xz)
file(REMOVE build/generate/zig-macos-x86_64.tar.xz)
file(REMOVE build/generate/zig-linux-x86_64.tar.xz)
file(REMOVE build/generate/zig-linux-aarch64.tar.xz)
file(REMOVE build/generate/zig-freebsd-x86_64.tar.xz)

message(STATUS "Renaming extracted folders")
file(RENAME "build/generate/zig-windows-x86_64-${ZIG_VERSION}"
     build/generate/zig-windows-x86_64-TEMP)
file(RENAME "build/generate/zig-windows-aarch64-${ZIG_VERSION}"
     build/generate/zig-windows-aarch64-TEMP)
file(RENAME "build/generate/zig-macos-aarch64-${ZIG_VERSION}"
     build/generate/zig-macos-aarch64-TEMP)
file(RENAME "build/generate/zig-macos-x86_64-${ZIG_VERSION}"
     build/generate/zig-macos-x86_64-TEMP)
file(RENAME "build/generate/zig-linux-x86_64-${ZIG_VERSION}"
     build/generate/zig-linux-x86_64-TEMP)
file(RENAME "build/generate/zig-linux-aarch64-${ZIG_VERSION}"
     build/generate/zig-linux-aarch64-TEMP)
file(RENAME "build/generate/zig-freebsd-x86_64-${ZIG_VERSION}"
     build/generate/zig-freebsd-x86_64-TEMP)

# The only thing that's different about each of these archives is the "zig"
# binary at the root of each. The lib/ folder is identical in each of them.
# There's also a doc/ folder and a README.md & LICENSE at the top level too. To
# save space in the Git repository and in the bundled zip in the binary we can
# dedupe all those things as a "zig-common" bundle separate from the
# platform-specific zig(.exe) binary.

message(STATUS "Removing previously generated folders")
file(REMOVE_RECURSE zig-common)
file(REMOVE_RECURSE zig-windows-x86_64)
file(REMOVE_RECURSE zig-windows-aarch64)
file(REMOVE_RECURSE zig-macos-aarch64)
file(REMOVE_RECURSE zig-macos-x86_64)
file(REMOVE_RECURSE zig-linux-x86_64)
file(REMOVE_RECURSE zig-linux-aarch64)
file(REMOVE_RECURSE zig-freebsd-x86_64)

message(STATUS "Creating zig-windows-x86_64 folder")
file(MAKE_DIRECTORY zig-windows-x86_64)
file(RENAME build/generate/zig-windows-x86_64-TEMP/zig.exe
     zig-windows-x86_64/zig.exe)

message(STATUS "Creating zig-common folder")
file(RENAME build/generate/zig-windows-x86_64-TEMP zig-common)

message(STATUS "Creating zig-windows-aarch64 folder")
file(MAKE_DIRECTORY zig-windows-aarch64)
file(RENAME build/generate/zig-windows-aarch64-TEMP/zig.exe
     zig-windows-aarch64/zig.exe)
file(REMOVE_RECURSE build/generate/zig-windows-aarch64-TEMP)

message(STATUS "Creating zig-macos-aarch64 folder")
file(MAKE_DIRECTORY zig-macos-aarch64)
file(RENAME build/generate/zig-macos-aarch64-TEMP/zig zig-macos-aarch64/zig)
file(REMOVE_RECURSE build/generate/zig-macos-aarch64-TEMP)

message(STATUS "Creating zig-macos-x86_64 folder")
file(MAKE_DIRECTORY zig-macos-x86_64)
file(RENAME build/generate/zig-macos-x86_64-TEMP/zig zig-macos-x86_64/zig)
file(REMOVE_RECURSE build/generate/zig-macos-x86_64-TEMP)

message(STATUS "Creating zig-linux-x86_64 folder")
file(MAKE_DIRECTORY zig-linux-x86_64)
file(RENAME build/generate/zig-linux-x86_64-TEMP/zig zig-linux-x86_64/zig)
file(REMOVE_RECURSE build/generate/zig-linux-x86_64-TEMP)

message(STATUS "Creating zig-linux-aarch64 folder")
file(MAKE_DIRECTORY zig-linux-aarch64)
file(RENAME build/generate/zig-linux-aarch64-TEMP/zig zig-linux-aarch64/zig)
file(REMOVE_RECURSE build/generate/zig-linux-aarch64-TEMP)

message(STATUS "Creating zig-freebsd-x86_64 folder")
file(MAKE_DIRECTORY zig-freebsd-x86_64)
file(RENAME build/generate/zig-freebsd-x86_64-TEMP/zig zig-freebsd-x86_64/zig)
file(REMOVE_RECURSE build/generate/zig-freebsd-x86_64-TEMP)

message(STATUS "Removing build/generate folder")
file(REMOVE_RECURSE build/generate)

# At this point the artifacts are large folders. These folders are great for
# "zip -Ar archive.zip zig-common zig-windows-aarch64 ..."-ing but they are a bit
# too big to store on GitHub. Thus, we need to compress them.

message(STATUS "Removing previously generated archives")
file(REMOVE_RECURSE zig-common.zip)
file(REMOVE_RECURSE zig-windows-x86_64.zip)
file(REMOVE_RECURSE zig-windows-aarch64.zip)
file(REMOVE_RECURSE zig-macos-aarch64.zip)
file(REMOVE_RECURSE zig-macos-x86_64.zip)
file(REMOVE_RECURSE zig-linux-x86_64.zip)
file(REMOVE_RECURSE zig-linux-aarch64.zip)
file(REMOVE_RECURSE zig-freebsd-x86_64.zip)

message(STATUS "Archiving zig-* folders")
file(ARCHIVE_CREATE OUTPUT zig-common.zip PATHS zig-common FORMAT zip)
file(ARCHIVE_CREATE OUTPUT zig-freebsd-x86_64.zip PATHS zig-freebsd-x86_64 FORMAT zip)
file(ARCHIVE_CREATE OUTPUT zig-linux-aarch64.zip PATHS zig-linux-aarch64 FORMAT zip)
file(ARCHIVE_CREATE OUTPUT zig-linux-x86_64.zip PATHS zig-linux-x86_64 FORMAT zip)
file(ARCHIVE_CREATE OUTPUT zig-macos-aarch64.zip PATHS zig-macos-aarch64 FORMAT zip)
file(ARCHIVE_CREATE OUTPUT zig-macos-x86_64.zip PATHS zig-macos-x86_64 FORMAT zip)
file(ARCHIVE_CREATE OUTPUT zig-windows-aarch64.zip PATHS zig-windows-aarch64 FORMAT zip)
file(ARCHIVE_CREATE OUTPUT zig-windows-x86_64.zip PATHS zig-windows-x86_64 FORMAT zip)
message(STATUS "Archived zig-* folders")

message(STATUS "Removing zig-* folders")
file(REMOVE_RECURSE zig-common)
file(REMOVE_RECURSE zig-freebsd-x86_64)
file(REMOVE_RECURSE zig-linux-aarch64)
file(REMOVE_RECURSE zig-linux-x86_64)
file(REMOVE_RECURSE zig-macos-aarch64)
file(REMOVE_RECURSE zig-macos-x86_64)
file(REMOVE_RECURSE zig-windows-aarch64)
file(REMOVE_RECURSE zig-windows-x86_64)

message(STATUS "All done!")
