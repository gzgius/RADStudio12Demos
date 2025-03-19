@echo off
setlocal

set pwd=%~dp0
set pwd=%pwd:~0,-1%

@call %pwd%\setup.bat git || goto :END

rem ----------------------------------------------------------------------------
rem ----------------------------------------------------------------------------

set repo_uri=https://github.com/vsg-dev/VulkanSceneGraph.git
set repo_version=master
set repo_local=%pwd%\vsg
set output_dir=%pwd%\build-vsg
set setup_dir=%pwd%\install\vsg

rem ----------------------------------------------------------------------------
rem ----------------------------------------------------------------------------

if exist %repo_local%\ goto :CLONE_DONE
mkdir "D:\src++\RADStudio12Demos-main\CPP\CMake\vsg" || goto :END
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
rem set cmake_options=%cmake_options% -DCMAKE_ASM_COMPILER="%c_compiler:\=/%"
rem set cmake_options=%cmake_options% -DCMAKE_C_COMPILER="%c_compiler:\=/%"
set cmake_options=%cmake_options% -DCMAKE_CXX_COMPILER="%cxx_compiler:\=/%"
set cmake_options=%cmake_options% -DCMAKE_INSTALL_PREFIX=%setup_dir%

rem ----------------------------------------------------------------------------

if not exist %output_dir%\ mkdir %output_dir% || goto :END
if not exist %setup_dir%\ mkdir %setup_dir% || goto :END

cmake -G Ninja -S %repo_local% -B %output_dir% -DCMAKE_BUILD_TYPE=%build_type% %cmake_options% || goto :END
cmake --build %output_dir% -j 16 -t install || goto :END

:END
exit /b %errorlevel%

