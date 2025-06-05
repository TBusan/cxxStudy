# OpenGL Triangle with WebAssembly Support

This project demonstrates a simple OpenGL application that renders a colored triangle. It can be built both as a native application and as WebAssembly using Emscripten.

## Prerequisites

### For Native Build
- CMake (3.10 or higher)
- C++ Compiler (with C++11 support)
- GLFW3 library
- OpenGL development libraries

### For WebAssembly Build
- Emscripten SDK (emsdk)

## Building the Project

### Native Build

```bash
# Create a build directory
mkdir build && cd build

# Configure and build
cmake ..
cmake --build .

# Run the application
./opengl_triangle_wasm
```

### WebAssembly Build

First, make sure you have activated the Emscripten SDK:

```bash
# Source the Emscripten environment (adjust path as needed)
source /path/to/emsdk/emsdk_env.sh  # On Linux/macOS
# OR
emsdk_env.bat  # On Windows
```

Then build the project:

```bash
# Create a build directory for WebAssembly
mkdir build_wasm && cd build_wasm

# Configure and build using Emscripten
emcmake cmake ..
cmake --build .

# The output will be:
# - opengl_triangle_wasm.html: HTML file to load in browser
# - opengl_triangle_wasm.js: JavaScript glue code
# - opengl_triangle_wasm.wasm: WebAssembly binary
```

## Running the WebAssembly Version

To run the WebAssembly version, you need to serve the files via a web server (browsers won't load WebAssembly from local files due to security restrictions).

Simple way to start a local server:

```bash
# Using Python 3
python -m http.server

# Using Python 2
python -m SimpleHTTPServer
```

Then open a browser and navigate to: `http://localhost:8000/opengl_triangle_wasm.html`

## Project Structure

- `src/main.cpp`: Main application code with OpenGL rendering
- `src/shell.html`: HTML template for the WebAssembly output
- `CMakeLists.txt`: Build configuration for both native and WebAssembly builds 