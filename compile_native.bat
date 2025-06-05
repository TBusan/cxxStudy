@echo off
REM 确保vcpkg已安装并设置好环境变量

REM 创建build目录
mkdir build
cd build

REM 使用CMake生成项目
cmake .. -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%/scripts/buildsystems/vcpkg.cmake"

REM 编译项目
cmake --build . --config Release

REM 返回原目录
cd ..

echo 编译完成！运行build\Release\opengl_triangle.exe即可启动程序 