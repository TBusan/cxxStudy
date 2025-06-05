@echo off
echo Starting HTTP server to serve WebAssembly files...
echo.
echo Navigate to http://localhost:8000/opengl_triangle_wasm.html in your browser
echo.
cd build_wasm
python -m http.server 