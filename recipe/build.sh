#!/usr/bin/env bash

mkdir build_cpp
cd build_cpp
export PPNF_BUILD_DIR=`pwd`

# Pybind11 (remove when the whole chain will be pinned)
git clone https://github.com/pybind/pybind11.git
cd pybind11
git checkout 4f72ef846fe8453596230ac285eeaa0ce3278bb4
mkdir build
cd build
pwd
cmake \
    -DPYBIND11_TEST=NO \
    -DCMAKE_INSTALL_PREFIX=$PPNF_BUILD_DIR \
    -DCMAKE_PREFIX_PATH=$PPNF_BUILD_DIR \
    ..
make install
cd ../..

# ppnf (C++)
cmake \
    -DBoost_NO_BOOST_CMAKE=ON \
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
    -DBoost_NO_BOOST_CMAKE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPPNF_BUILD_CPP=no \
    -DPPNF_BUILD_PYTHON=yes \
    -DPPNF_BUILD_TESTS=no \
    -Dpybind11_DIR=$PPNF_BUILD_DIR/share/cmake/pybind11/ \
    ..

make -j${CPU_COUNT} VERBOSE=1
make install
