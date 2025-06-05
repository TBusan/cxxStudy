@echo off
echo Building WebAssembly version...

rem 设置Python路径
set PATH=D:\miniconda3;D:\miniconda3\Scripts;%PATH%

rem 设置MinGW路径
set PATH=D:\Programs\mingw64\bin;%PATH%
echo Path with MinGW: %PATH%

rem 确保最新版本的Emscripten已激活
cd D:\emsdk
echo Verifying Emscripten installation...
call D:\emsdk\emsdk.bat install latest
call D:\emsdk\emsdk.bat activate latest
cd %~dp0

rem 设置Emscripten环境
call D:\emsdk\emsdk_env.bat

rem 创建构建目录
if exist build_wasm rmdir /s /q build_wasm
mkdir build_wasm
cd build_wasm

rem 配置和构建
echo Configuring with emcmake...
call emcmake cmake .. -G "MinGW Makefiles"
if %ERRORLEVEL% NEQ 0 (
    echo CMake configure failed with error level %ERRORLEVEL%
    exit /B 1
)

echo Building with emmake...
echo Current directory: %CD%
call emmake mingw32-make
if %ERRORLEVEL% NEQ 0 (
    echo Build failed with error level %ERRORLEVEL%
    exit /B 1
)

rem 检查是否生成了输出文件
if exist opengl_triangle_wasm.html (
    echo WebAssembly build successful! Output files:
    dir *.html *.js *.wasm
) else (
    echo WARNING: opengl_triangle_wasm.html not found in output directory.
    echo Checking for other output files:
    dir /B
)

echo Build completed.
echo 在浏览器中查看结果请运行: python -m http.server
echo 然后访问: http://localhost:8000/opengl_triangle_wasm.html

cd .. 