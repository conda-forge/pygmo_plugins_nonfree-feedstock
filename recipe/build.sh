#!/usr/bin/env bash
set -euxo pipefail

cd "${SRC_DIR}"

# Find any sysroot-ish directory under BUILD_PREFIX
for sysroot in $(find "${BUILD_PREFIX}" -type d -path "*/sysroot*" 2>/dev/null || true); do
  if [[ -d "${sysroot}/usr" ]]; then
    root="${sysroot}"
  else
    # if we matched something deeper (e.g. .../sysroot/usr), normalize upward
    root="${sysroot%%/usr*}"
  fi

  if [[ ! -e "${root}/usr/lib/libm.so" ]]; then
    mkdir -p "${root}/usr/lib"
    for cand in \
      "${root}/usr/lib64/libm.so.6" \
      "${root}/lib64/libm.so.6" \
      "${root}/usr/lib/x86_64-linux-gnu/libm.so.6" \
      "${root}/usr/lib/libm.so.6"
    do
      if [[ -e "${cand}" ]]; then
        ln -s "${cand}" "${root}/usr/lib/libm.so"
        break
      fi
    done
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
