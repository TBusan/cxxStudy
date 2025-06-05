#!/bin/bash

# Build script for OpenGL Triangle WebAssembly project

# Default values
MODE="native"
CLEAN=false
EMSDK_PATH=""

# Print header
echo "===================================="
echo "  OpenGL Triangle WebAssembly Build"
echo "===================================="
echo ""

# Parse arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        --mode)
        MODE="$2"
        shift
        shift
        ;;
        --clean)
        CLEAN=true
        shift
        ;;
        --emsdk)
        EMSDK_PATH="$2"
        shift
        shift
        ;;
        --help)
        echo "Usage: ./build.sh [options]"
        echo ""
        echo "Options:"
        echo "  --mode MODE      Build mode: 'native' or 'wasm' (default: native)"
        echo "  --clean          Clean build directories before building"
        echo "  --emsdk PATH     Path to Emscripten SDK (required for wasm mode)"
        echo "  --help           Display this help message"
        exit 0
        ;;
        *)
        echo "Unknown option: $key"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
done

# Handle clean option
if [ "$CLEAN" = true ]; then
    echo "Cleaning build directories..."
    if [ -d "build" ]; then
        rm -rf build
        echo "  Removed native build directory"
    fi
    if [ -d "build_wasm" ]; then
        rm -rf build_wasm
        echo "  Removed WebAssembly build directory"
    fi
    echo "Clean completed."
    if [ "$MODE" = "clean" ]; then
        exit 0
    fi
fi

# Build based on mode
case "$MODE" in
    "native")
        echo "Building native application..."
        
        # Create build directory if it doesn't exist
        mkdir -p build
        
        # Run CMake and build
        cd build
        cmake ..
        if [ $? -ne 0 ]; then
            echo "CMake configuration failed!"
            exit 1
        fi
        
        cmake --build .
        if [ $? -ne 0 ]; then
            echo "Build failed!"
            exit 1
        fi
        
        echo "Native build completed successfully."
        cd ..
        ;;
    
    "wasm")
        echo "Building WebAssembly application..."
        
        # Check if Emscripten SDK path is provided
        if [ -z "$EMSDK_PATH" ]; then
            echo "Error: Emscripten SDK path not provided!"
            echo "Usage: ./build.sh --mode wasm --emsdk /path/to/emsdk"
            exit 1
        fi
        
        # Activate Emscripten environment
        echo "Activating Emscripten SDK from $EMSDK_PATH..."
        EMSDK_ENV_SCRIPT="$EMSDK_PATH/emsdk_env.sh"
        
        if [ ! -f "$EMSDK_ENV_SCRIPT" ]; then
            echo "Error: Emscripten environment script not found at: $EMSDK_ENV_SCRIPT"
            exit 1
        fi
        
        # Source the Emscripten environment
        source "$EMSDK_ENV_SCRIPT"
        
        # Create build directory if it doesn't exist
        mkdir -p build_wasm
        
        # Run CMake with Emscripten and build
        cd build_wasm
        emcmake cmake ..
        if [ $? -ne 0 ]; then
            echo "Emscripten CMake configuration failed!"
            exit 1
        fi
        
        emmake cmake --build .
        if [ $? -ne 0 ]; then
            echo "WebAssembly build failed!"
            exit 1
        fi
        
        echo "WebAssembly build completed successfully."
        echo ""
        echo "To run the WebAssembly version, start a web server in this directory and open opengl_triangle_wasm.html"
        echo "Example: python -m http.server"
        cd ..
        ;;
    
    *)
        echo "Error: Unknown build mode '$MODE'"
        echo "Supported modes: native, wasm"
        exit 1
        ;;
esac

echo ""
echo "Build process completed!" 