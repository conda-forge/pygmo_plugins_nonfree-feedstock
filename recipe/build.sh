#!/usr/bin/env bash

mkdir build_cpp
cd build_cpp
export PPNF_BUILD_DIR=`pwd`

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
    ..

make -j${CPU_COUNT} VERBOSE=1
make install
