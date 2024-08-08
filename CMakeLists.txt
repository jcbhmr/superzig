cmake_minimum_required(VERSION 3.29)

# Project declaration
project(
  superzig
  VERSION 0.13.0
  LANGUAGES CXX)

include(FetchContent)
FetchContent_Declare(
  platformdirs
  GIT_REPOSITORY https://github.com/jcbhmr/platformdirs-cpp.git
  GIT_TAG eed745adb4e7000da0e6032374890e7353c9a184
  FIND_PACKAGE_ARGS 0.1.0...<1)
# Will try find_package(platformdirs 0.1.0...<1) first
FetchContent_MakeAvailable(platformdirs)

# Binary targets
add_executable(zig)
add_executable(superzig::zig ALIAS zig)
set_property(TARGET zig PROPERTY OUTPUT_NAME platformdirs)
target_sources(zig PRIVATE src/zig.cpp)
target_compile_features(zig PRIVATE cxx_std_23)
# cosmocc has exceptions off by default
target_compile_options(zig PRIVATE -fexceptions)
target_link_libraries(zig PRIVATE platformdirs)
target_compile_definitions(
  zig
  PRIVATE PROJECT_VERSION="${PROJECT_VERSION}"
          PROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}
          PROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}
          PROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH}
          PROJECT_VERSION_TWEAK=${PROJECT_VERSION_TWEAK})
find_program(zig_command NAMES zip REQUIRED)
add_custom_command(
  TARGET zig
  POST_BUILD
  COMMAND
    "${zip_command}" -Ar "$<TARGET_FILE:zig>" zig-common zig-freebsd-x86_64
    zig-linux-aarch64 zig-linux-x86_64 zig-macos-aarch64 zig-macos-x86_64
    zig-windows-aarch64 zig-windows-x86_64)

# Testing
include(CTest)
if(BUILD_TESTING)
  add_test(NAME zig COMMAND zig --version)
endif()

# Installation
include(GNUInstallDirs)
install(TARGETS zig)

# Packaging
set(CPACK_GENERATOR ZIP)
set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}")
include(CPack)

# Tasks
if(BUILD_TESTING AND CMAKE_SOURCE_DIR STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
  file(
    GLOB_RECURSE
    c_cxx_files
    src/*.c
    src/*.cpp
    src/*.cc
    src/*.cxx
    src/*.h
    src/*.hxx
    src/*.hh
    src/*.hpp
    include/*.h
    include/*.hxx
    include/*.hh
    include/*.hpp
    test/*.c
    test/*.cpp
    test/*.cc
    test/*.cxx
    test/*.h
    test/*.hxx
    test/*.hh
    test/*.hpp
    examples/*.c
    examples/*.cpp
    examples/*.cc
    examples/*.cxx
    examples/*.h
    examples/*.hxx
    examples/*.hh
    examples/*.hpp)
  file(
    GLOB_RECURSE
    cmake_files
    cmake/*.cmake
    src/*CMakeLists.txt
    src/*.cmake
    test/*CMakeLists.txt
    test/*.cmake)
  list(APPEND cmake_files CMakeLists.txt)
  add_custom_target(
    format
    COMMAND clang-format -i ${c_cxx_files}
    COMMAND cmake-format -i ${cmake_files}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    USES_TERMINAL)

  file(
    GLOB_RECURSE
    all_files
    .github/*
    cmake/*
    src/*
    examples/*
    test/*
    docs/*)
  list(
    APPEND
    all_files
    .gitignore
    CMakeLists.txt
    CMakePresets.json
    README.md
    task.cmake)
  add_custom_target(
    lint
    COMMAND codespell -w ${all_files}
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    USES_TERMINAL)

  add_custom_target(
    generate
    COMMAND "${CMAKE_COMMAND}" -P cmake/generate.cmake
    WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
    USES_TERMINAL)
endif()
