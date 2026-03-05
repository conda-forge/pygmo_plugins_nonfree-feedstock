#!/usr/bin/env bash
set -euxo pipefail

# Always build from the extracted sources
cd "${SRC_DIR}"  # SRCDIR is set by conda-build/rattler-build [file:77]

# Workaround for brittle exported link interface:
# some dependency exports an absolute .../sysroot/usr/lib/libm.so path. [file:77]
for sysroot in $(find "${BUILD_PREFIX}" -path "*/sysroot" -type d 2>/dev/null || true); do
  if [[ ! -e "${sysroot}/usr/lib/libm.so" ]]; then
    mkdir -p "${sysroot}/usr/lib"
    for cand in \
      "${sysroot}/usr/lib64/libm.so.6" \
      "${sysroot}/lib64/libm.so.6" \
      "${sysroot}/usr/lib/x86_64-linux-gnu/libm.so.6" \
      "${sysroot}/usr/lib/libm.so.6"
    do
      if [[ -e "${cand}" ]]; then
        ln -s "${cand}" "${sysroot}/usr/lib/libm.so"
        break
      fi
    done
  fi
done

########################################
# C++ build
########################################
cmake -S . -B build_cpp ${CMAKE_ARGS} \
  -DPPNF_BUILD_CPP=ON \
  -DPPNF_BUILD_PYTHON=OFF \
  -DPPNF_BUILD_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build_cpp --parallel "${CPU_COUNT}"
cmake --install build_cpp

########################################
# Python build
########################################
cmake -S . -B build_py ${CMAKE_ARGS} \
  -DPPNF_BUILD_CPP=OFF \
  -DPPNF_BUILD_PYTHON=ON \
  -DPPNF_BUILD_TESTS=OFF \
  -DPython3_EXECUTABLE="${PYTHON}"

cmake --build build_py --parallel "${CPU_COUNT}"
cmake --install build_py
