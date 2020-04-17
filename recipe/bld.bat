mkdir build_cpp
cd build_cpp
SET PPNF_BUILD_DIR=%cd%

git clone https://github.com/pybind/pybind11.git
cd pybind11
git checkout 4f72ef846fe8453596230ac285eeaa0ce3278bb4
mkdir build
cd build
cmake ^
    -G "Ninja" ^
    -DPYBIND11_TEST=NO ^
    -DCMAKE_INSTALL_PREFIX=%PPNF_BUILD_DIR% ^
    -DCMAKE_PREFIX_PATH=%PPNF_BUILD_DIR% ^
    -DCMAKE_BUILD_TYPE=Release ^
    ..
cmake --build . --target install
cd ../..

cmake ^
    -G "NMake Makefiles" ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DPPNF_BUILD_CPP=yes ^
    -DPPNF_BUILD_TESTS=no ^
    ..

cmake --build . --config Release --target install

cd ..
mkdir build
cd build

cmake ^
    -G "NMake Makefiles" ^
    -DBoost_NO_BOOST_CMAKE=ON ^
    -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
    -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
    -DPPNF_BUILD_CPP=no ^
    -DPPNF_BUILD_PYTHON=yes ^
    -Dpybind11_DIR=%PYAUDI_BUILD_DIR%\share\cmake\pybind11\ ^
    ..

cmake --build . --config Release --target install