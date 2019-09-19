#!/usr/bin/env bash

mkdir build_cpp
cd build_cpp

cmake \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPPNF_BUILD_CPP=yes \
    -DPPNF_BUILD_TESTS=no \
    ..

make
make install

cd ..
mkdir build
cd build

cmake \
    -DBoost_NO_BOOST_CMAKE=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_INSTALL_PREFIX=$PREFIX \
    -DCMAKE_PREFIX_PATH=$PREFIX \
    -DPPNF_BUILD_CPP=no \
    -DPPNF_BUILD_PYTHON=yes \
    -DPPNF_BUILD_TESTS=no \
    ..

make

make install
