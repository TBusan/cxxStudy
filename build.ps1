# Build script for OpenGL Triangle WebAssembly project
param (
    [string]$mode = "native",  # Options: "native", "wasm"
    [switch]$clean = $false,
    [string]$emsdkPath = $null
)

# Print header
Write-Host "===================================="
Write-Host "  OpenGL Triangle WebAssembly Build"
Write-Host "===================================="
Write-Host ""

# Handle clean option
if ($clean) {
    Write-Host "Cleaning build directories..."
    if (Test-Path -Path "build") {
        Remove-Item -Path "build" -Recurse -Force
        Write-Host "  Removed native build directory"
    }
    if (Test-Path -Path "build_wasm") {
        Remove-Item -Path "build_wasm" -Recurse -Force
        Write-Host "  Removed WebAssembly build directory"
    }
    Write-Host "Clean completed."
    if ($mode -eq "clean") {
        exit 0
    }
}

# Build based on mode
switch ($mode) {
    "native" {
        Write-Host "Building native application..."
        
        # Create build directory if it doesn't exist
        if (-not (Test-Path -Path "build")) {
            New-Item -Path "build" -ItemType Directory | Out-Null
        }
        
        # Run CMake and build
        Set-Location -Path "build"
        cmake ..
        if ($LASTEXITCODE -ne 0) {
            Write-Host "CMake configuration failed!" -ForegroundColor Red
            exit 1
        }
        
        cmake --build .
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Build failed!" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "Native build completed successfully." -ForegroundColor Green
        Set-Location -Path ".."
    }
    
    "wasm" {
        Write-Host "Building WebAssembly application..."
        
        # Check if Emscripten SDK path is provided
        if ([string]::IsNullOrEmpty($emsdkPath)) {
            Write-Host "Error: Emscripten SDK path not provided!" -ForegroundColor Red
            Write-Host "Usage: ./build.ps1 -mode wasm -emsdkPath 'C:\Path\To\emsdk'" -ForegroundColor Yellow
            exit 1
        }
        
        # Activate Emscripten environment
        Write-Host "Activating Emscripten SDK from $emsdkPath..."
        $emsdkEnvScript = Join-Path -Path $emsdkPath -ChildPath "emsdk_env.ps1"
        
        if (-not (Test-Path -Path $emsdkEnvScript)) {
            Write-Host "Error: Emscripten environment script not found at: $emsdkEnvScript" -ForegroundColor Red
            exit 1
        }
        
        # Source the Emscripten environment
        & $emsdkEnvScript
        
        # Create build directory if it doesn't exist
        if (-not (Test-Path -Path "build_wasm")) {
            New-Item -Path "build_wasm" -ItemType Directory | Out-Null
        }
        
        # Run CMake with Emscripten and build
        Set-Location -Path "build_wasm"
        emcmake cmake ..
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Emscripten CMake configuration failed!" -ForegroundColor Red
            exit 1
        }
        
        emmake cmake --build .
        if ($LASTEXITCODE -ne 0) {
            Write-Host "WebAssembly build failed!" -ForegroundColor Red
            exit 1
        }
        
        Write-Host "WebAssembly build completed successfully." -ForegroundColor Green
        Write-Host ""
        Write-Host "To run the WebAssembly version, start a web server in this directory and open opengl_triangle_wasm.html"
        Write-Host "Example: python -m http.server"
        Set-Location -Path ".."
    }
    
    default {
        Write-Host "Error: Unknown build mode '$mode'" -ForegroundColor Red
        Write-Host "Supported modes: native, wasm" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host ""
Write-Host "Build process completed!" 