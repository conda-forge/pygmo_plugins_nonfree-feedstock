#!/usr/bin/env bash
set -euxo pipefail

cd "${SRC_DIR}"

fixed_any=0

for root in $(find "${BUILD_PREFIX}" -type d -path "*/sysroot" 2>/dev/null || true); do
  if [[ -e "${root}/usr/lib/libm.so" ]]; then
    continue
  fi

  mkdir -p "${root}/usr/lib"

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

  if [[ -z "${cand}" ]]; then
    cand="$(find "${root}" -type f -name 'libm.so.6' -print -quit 2>/dev/null || true)"
  fi

  if [[ -n "${cand}" ]]; then
    ln -sf "${cand}" "${root}/usr/lib/libm.so"
    fixed_any=1
  else
    echo "ERROR: libm.so.6 not found under sysroot: ${root}" 1>&2
    echo "Top-level of sysroot:" 1>&2
    ls -la "${root}" 1>&2 || true
    echo "usr/lib contents:" 1>&2
    ls -la "${root}/usr/lib" 1>&2 || true
    echo "usr/lib64 contents:" 1>&2
    ls -la "${root}/usr/lib64" 1>&2 || true
    exit 1
  fi
done

if [[ "${fixed_any}" -eq 0 ]]; then
  echo "WARNING: Did not create any libm.so symlink (already existed or no sysroot found)" 1>&2
fi

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
