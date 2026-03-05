#!/usr/bin/env bash

mkdir build_cpp
cd build_cpp
export PPNF_BUILD_DIR=`pwd`

# Work around missing libm.so in conda-forge sysroot layout (linux build)
if [[ -n "${CONDA_BUILD_SYSROOT:-}" ]]; then
  if [[ ! -e "${CONDA_BUILD_SYSROOT}/usr/lib/libm.so" && -e "${CONDA_BUILD_SYSROOT}/lib64/libm.so.6" ]]; then
    ln -s "${CONDA_BUILD_SYSROOT}/lib64/libm.so.6" "${CONDA_BUILD_SYSROOT}/usr/lib/libm.so"
  fi
  if [[ ! -e "${CONDA_BUILD_SYSROOT}/usr/lib/libm.so" && -e "${CONDA_BUILD_SYSROOT}/usr/lib64/libm.so.6" ]]; then
    ln -s "${CONDA_BUILD_SYSROOT}/usr/lib64/libm.so.6" "${CONDA_BUILD_SYSROOT}/usr/lib/libm.so"
  fi
fi

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
