#!/usr/bin/env bash
set -euo pipefail

# Patch pagmo-devel's CMake config to remove the stale rattler-build sysroot libm path
find "${PREFIX}/lib/cmake" -name "*.cmake" -exec \
  sed -i 's|[^ ]*rattler-build[^ ]*/sysroot/usr/lib/libm\.so|-lm|g' {} +

# ---- C++ build ----
cmake -S . -B build_cpp ${CMAKE_ARGS:-} \
  -DPPNF_BUILD_CPP=ON \
  -DPPNF_BUILD_PYTHON=OFF \
  -DPPNF_BUILD_TESTS=OFF

cmake --build build_cpp --parallel "${CPU_COUNT:-1}"
cmake --install build_cpp

# ---- Python build ----
cmake -S . -B build_py ${CMAKE_ARGS:-} \
  -DPPNF_BUILD_CPP=OFF \
  -DPPNF_BUILD_PYTHON=ON \
  -DPPNF_BUILD_TESTS=OFF \
  -DPython3_EXECUTABLE="${PYTHON}"

cmake --build build_py --parallel "${CPU_COUNT:-1}"
cmake --install build_py
