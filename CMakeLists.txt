cmake_minimum_required(VERSION 3.10)
project(opengl_triangle_wasm)

# 添加FetchContent模块
include(FetchContent)

# 配置threepp
set(THREEPP_BUILD_TESTS OFF)
set(THREEPP_BUILD_EXAMPLES OFF)
FetchContent_Declare(
    threepp
    GIT_REPOSITORY https://github.com/markaren/threepp.git
)
FetchContent_MakeAvailable(threepp)

# 更新C++标准以支持threepp
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Add GLAD
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/glad/include)

# Add GLFW
# set(GLFW_DIR "D:/study/code/wasm/glfw")
# include_directories(${GLFW_DIR}/include)
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/glfw/include)
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/glfw/lib-vc2022)

# Add source files
set(SOURCE_FILES
    src/main.cpp
    glad/src/glad.c
)

# Check if Emscripten is being used
if(EMSCRIPTEN)
    set(CMAKE_EXECUTABLE_SUFFIX ".html")
    add_executable(${PROJECT_NAME} ${SOURCE_FILES})
    
    # Emscripten-specific linker flags
    set(EMSCRIPTEN_LINK_FLAGS 
        "-s USE_WEBGL2=1 -s USE_GLFW=3 -s WASM=1 -s ALLOW_MEMORY_GROWTH=1 -s NO_EXIT_RUNTIME=1 -s ASSERTIONS=1"
        "--shell-file ${CMAKE_CURRENT_SOURCE_DIR}/src/shell.html"
    )
    string(REPLACE ";" " " EMSCRIPTEN_LINK_FLAGS "${EMSCRIPTEN_LINK_FLAGS}")
    set_target_properties(${PROJECT_NAME} PROPERTIES LINK_FLAGS "${EMSCRIPTEN_LINK_FLAGS}")
    
    # Add threepp for Emscripten build
    target_link_libraries(${PROJECT_NAME} threepp::threepp)
else()
    # For native build
    find_package(OpenGL REQUIRED)
    
    add_executable(${PROJECT_NAME} ${SOURCE_FILES})
    
    target_link_libraries(${PROJECT_NAME} 
        OpenGL::GL
        ${CMAKE_CURRENT_SOURCE_DIR}/glfw/lib-vc2022/glfw3.lib
        threepp::threepp
    )
endif() 