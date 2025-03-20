@echo off
setlocal

set pwd=%~dp0
set pwd=%pwd:~0,-1%

@call %pwd%\setup.bat git || goto :END

rem ----------------------------------------------------------------------------
rem ----------------------------------------------------------------------------

rem set repo_uri=https://github.com/openscenegraph/OpenSceneGraph.git
set repo_uri=https://github.com/gzgius/OpenSceneGraph.git
set repo_version=master
set repo_local=%pwd%\openscenegraph
set output_dir=%pwd%\build-openscenegraph
set setup_dir=%pwd%\install-openscenegraph

rem ----------------------------------------------------------------------------
rem ----------------------------------------------------------------------------

if exist %repo_local%\ goto :CLONE_DONE
mkdir "D:\src++\RADStudio12Demos-main\CPP\CMake\openscenegraph" || goto :END

git clone --branch %repo_version% --single-branch %repo_uri% %repo_local% || goto :CLONE_ERROR

rem echo Applying compatibility patch, please see %patch_file% for details.
rem git -C %repo_local% apply %patch_file% && goto :CLONE_DONE

goto :CLONE_DONE

:CLONE_ERROR
rd /s /q %repo_local%
goto :END

:CLONE_DONE

rem ----------------------------------------------------------------------------
set cmake_options=%cmake_options% -DCMAKE_SYSTEM_NAME=Windows
set cmake_options=%cmake_options% -DCMAKE_SYSTEM_PROCESSOR=x86_64
set cmake_options=%cmake_options% -DCMAKE_CROSSCOMPILING=OFF
set cmake_options=%cmake_options% -DCMAKE_INSTALL_PREFIX=%setup_dir:\=/%
set cmake_options=%cmake_options% -DCMAKE_ASM_COMPILER="%c_compiler:\=/%"
set cmake_options=%cmake_options% -DCMAKE_C_COMPILER="%c_compiler:\=/%"
set cmake_options=%cmake_options% -DCMAKE_CXX_COMPILER="%cxx_compiler:\=/%"

rem set cmake_options=%cmake_options% -DCMAKE_EXE_LINKER_FLAGS="-static -static-libgcc -static-libstdc++"
rem set cmake_options=%cmake_options% -DDYNAMIC_OPENSCENEGRAPH=OFF
rem set cmake_options=%cmake_options% -DDYNAMIC_OPENTHREADS=OFF

set cmake_options=%cmake_options% -DCMAKE_INSTALL_PREFIX=%setup_dir%
set cmake_options=%cmake_options% -DBUILD_OSG_EXAMPLES=ON

rem  -ffast-math
set cmake_options=%cmake_options% -DCMAKE_CXX_FLAGS="-O3 -march=native -flto -DNDEBUG"   

rem le opzioni di ottimizzazione creano problemi con sincos
rem    if(NOT BUILD_SHARED_LIBS)
rem        add_definitions(
rem            -DNO_SINCOS
rem            -DNO_SINCOSF
rem        )
rem    endif()
rem	#add_compile_options(-include ${CMAKE_SOURCE_DIR}/include/compat_math.h)
rem	if(CMAKE_CXX_COMPILER_ID MATCHES "Embarcadero")
rem		include_directories(${CMAKE_SOURCE_DIR}/include)
rem		add_compile_options(-FI${CMAKE_SOURCE_DIR}/include/compat_math.h)
rem	endif()
rem  OSG_GL_LIBRARY_STATIC=ON

rem ----------------------------------------------------------------------------

if not exist %output_dir%\ mkdir %output_dir% || goto :END
if not exist %setup_dir%\ mkdir %setup_dir% || goto :END


cmake -G Ninja -S %repo_local% -B %output_dir% -DCMAKE_BUILD_TYPE=%build_type% %cmake_options% || goto :END
cmake --build %output_dir% -- -j16 || goto :END
cmake --install %output_dir% || goto :END

:END
exit /b %errorlevel%

