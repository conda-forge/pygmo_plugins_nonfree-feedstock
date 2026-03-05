#!/usr/bin/env bash
set -euxo pipefail

cd "${SRC_DIR}"

# Only consider the actual sysroot dir (not every subdir containing "sysroot")
for root in $(find "${BUILD_PREFIX}" -type d -path "*/sysroot" 2>/dev/null || true); do
  if [[ ! -e "${root}/usr/lib/libm.so" ]]; then
    mkdir -p "${root}/usr/lib"

    # First try a few common locations
    cand=""
    for p in \
      "${root}/usr/lib64/libm.so.6" \
      "${root}/lib64/libm.so.6" \
      "${root}/usr/lib/x86_64-linux-gnu/libm.so.6" \
      "${root}/usr/lib/libm.so.6"
    do
      if [[ -e "${p}" ]]; then
        cand="${p}"
        break
      fi
    done

    # Fallback: locate libm.so.6 anywhere under this sysroot
    if [[ -z "${cand}" ]]; then
      cand="$(find "${root}" -type f -name 'libm.so.6' -print -quit 2>/dev/null || true)"
    fi

    # Create the symlink if we found a candidate
    if [[ -n "${cand}" ]]; then
      ln -sf "${cand}" "${root}/usr/lib/libm.so"
    fi
  fi
done

cmake -S . -B build_cpp ${CMAKE_ARGS} \
  -DPPNF_BUILD_CPP=ON \
  -DPPNF_BUILD_PYTHON=OFF \
  -DPPNF_BUILD_TESTS=OFF \
  -DCMAKE_BUILD_TYPE=Release

cmake --build build_cpp --parallel "${CPU_COUNT}"
cmake --install build_cpp

cmake -S . -B build_py ${CMAKE_ARGS} \
  -DPPNF_BUILD_CPP=OFF \
  -DPPNF_BUILD_PYTHON=ON \
  -DPPNF_BUILD_TESTS=OFF \
  -DPython3_EXECUTABLE="${PYTHON}"

cmake --build build_py --parallel "${CPU_COUNT}"
cmake --install build_py
