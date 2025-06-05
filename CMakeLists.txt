cmake_minimum_required(VERSION 3.10)
project(opengl_triangle_wasm)

set(CMAKE_CXX_STANDARD 11)
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

else()
    # For native build
    find_package(OpenGL REQUIRED)
    
    add_executable(${PROJECT_NAME} ${SOURCE_FILES})
    
    target_link_libraries(${PROJECT_NAME} 
        OpenGL::GL
        ${CMAKE_CURRENT_SOURCE_DIR}/glfw/lib-vc2022/glfw3.lib
    )
endif() 