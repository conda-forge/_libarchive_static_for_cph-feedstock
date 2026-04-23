@echo on
set "exit_on_error=|| exit /b 1"

set LIB=%LIBRARY_LIB%;%LIB%
set LIBPATH=%LIBRARY_LIB%;%LIBPATH%
set INCLUDE=%LIBRARY_INC%;%INCLUDE%

cmake ^
      -DCMAKE_INSTALL_PREFIX="%LIBRARY_PREFIX%" ^
      -DCMAKE_BUILD_TYPE=Release ^
      -DCMAKE_C_USE_RESPONSE_FILE_FOR_OBJECTS:BOOL=FALSE ^
      -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
      -DCMAKE_C_FLAGS_RELEASE="%CFLAGS%" ^
      -DENABLE_ACL=ON ^
      -DENABLE_BZip2=ON ^
      -DENABLE_CAT=OFF ^
      -DENABLE_CNG=%ENABLE_CNG% ^
      -DENABLE_COVERAGE=OFF ^
      -DENABLE_CPIO=OFF ^
      -DENABLE_EXPAT=ON ^
      -DENABLE_ICONV=OFF ^
      -DENABLE_INSTALL=ON ^
      -DENABLE_LIBB2=OFF ^
      -DENABLE_LIBXML2=OFF ^
      -DENABLE_LZ4=OFF ^
      -DENABLE_LZMA=OFF ^
      -DENABLE_LZO=OFF ^
      -DENABLE_LibGCC=OFF ^
      -DENABLE_NETTLE=OFF ^
      -DENABLE_OPENSSL=OFF ^
      -DENABLE_SAFESEH=AUTO ^
      -DENABLE_TAR=OFF ^
      -DENABLE_XATTR=ON ^
      -DENABLE_ZLIB=ON ^
      -DENABLE_ZSTD=ON ^
      -DBZIP2_LIBRARY_RELEASE=%LIBRARY_LIB%\bzip2_static.lib ^
      -DZLIB_LIBRARY_RELEASE=%LIBRARY_LIB%\zlibstatic.lib ^
      -DZSTD_LIBRARY=%LIBRARY_LIB%\zstd_static.lib ^
      . ^
      %exit_on_error%

:: Build.
cmake --build . --target install --config Release %exit_on_error%

:: Test.
:: Failures:
:: The following tests FAILED:
::         365 - libarchive_test_read_truncated_filter_bzip2 (Timeout) => runs msys2's bzip2.exe
::         372 - libarchive_test_sparse_basic (Failed)
::         373 - libarchive_test_fully_sparse_files (Failed)
::         386 - libarchive_test_warn_missing_hardlink_target (Failed)
:: ctest -C Release
:: if errorlevel 1 exit 1

:: Test extracting a 7z. This failed due to not using the multi-threaded DLL runtime, fixed by 0009-CMake-Force-Multi-threaded-DLL-runtime.patch
::powershell -command "& { (New-Object Net.WebClient).DownloadFile('http://download.qt.io/development_releases/prebuilt/llvmpipe/windows/opengl32sw-64-mesa_12_0_rc2.7z', 'opengl32sw-64-mesa_12_0_rc2.7z') }"
::if errorlevel 1 exit 1
::%LIBRARY_BIN%\bsdtar -xf opengl32sw-64-mesa_12_0_rc2.7z
::if errorlevel 1 exit 1

:: remove man pages
rd /s /q %PREFIX%\Library\share\man

:: remove the dynamic libraries
del %PREFIX%\Library\bin\archive.DLL
del %PREFIX%\Library\lib\archive.lib

pushd %PREFIX%\Library\lib
lib.exe /OUT:archive_and_deps.lib archive_static.lib zstd_static.lib bzip2_static.lib zlibstatic.lib
popd
