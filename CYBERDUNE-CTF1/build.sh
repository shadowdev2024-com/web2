#!/bin/bash
set -e

echo "🔨 Building CYBERDUNE WASM Challenge Module..."

# Check if emscripten is available
if ! command -v emcc &> /dev/null; then
    echo "❌ Emscripten not found. Please install and activate emsdk."
    echo "Visit: https://emscripten.org/docs/getting_started/downloads.html"
    exit 1
fi

# Clean previous builds
rm -f module.wasm module.js

# Compile WASM module
echo "📦 Compiling WASM module..."
emcc -O3 \
  -s WASM=1 \
  -s EXPORTED_FUNCTIONS='["_check_secret","_alloc"]' \
  -s MODULARIZE=0 \
  -s ENVIRONMENT='web' \
  -s FILESYSTEM=0 \
  -s MALLOC=emmalloc \
  --no-entry \
  -Wl,--strip-debug \
  -fno-exceptions \
  -o module.wasm \
  wasm_source.c

# Verify build
if [ -f "module.wasm" ]; then
    echo "✅ Build successful!"
    echo "📏 WASM size: $(stat -f%z module.wasm 2>/dev/null || stat -c%s module.wasm) bytes"
else
    echo "❌ Build failed!"
    exit 1
fi

echo "🚀 Ready for deployment!"
