mkdir build_cpp
cd build_cpp
SET PPNF_BUILD_DIR=%cd%

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
    ..

cmake --build . --config Release --target install