#!/usr/bin/env bash
set -euxo pipefail

# Satisfy brittle exported link interface that references an absolute .../sysroot/usr/lib/libm.so
# Search any sysroot in the current build prefix tree and create usr/lib/libm.so if missing.
for sysroot in $(find "${BUILD_PREFIX}" -path "*/sysroot" -type d 2>/dev/null || true); do
  if [[ ! -e "${sysroot}/usr/lib/libm.so" ]]; then
    mkdir -p "${sysroot}/usr/lib"
    # Try common locations for the real SONAME
    for cand in \
      "${sysroot}/usr/lib64/libm.so.6" \
      "${sysroot}/lib64/libm.so.6" \
      "${sysroot}/usr/lib/x86_64-linux-gnu/libm.so.6" \
      "${sysroot}/usr/lib/libm.so.6"
    do
      if [[ -e "$cand" ]]; then
        ln -s "$cand" "${sysroot}/usr/lib/libm.so"
        break
      fi
    done
  fi
done

# ppnf (C++)
cmake ${CMAKE_ARGS} \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPPNF_BUILD_CPP=yes \
    -DPPNF_BUILD_TESTS=no \
    ..

make -j${CPU_COUNT} VERBOSE=1
make install
cd ..

# ppnf (python)
mkdir build_python
cd build_python

cmake \
    -DPython3_EXECUTABLE=$PREFIX/bin/python \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPPNF_BUILD_CPP=no \
    -DPPNF_BUILD_PYTHON=yes \
    ..

make -j${CPU_COUNT} VERBOSE=1
make install
