#!/bin/bash
set -e

echo "🔨 Building CYBERDUNE WASM Challenge Module locally..."

# تأكد أن emcc متاح
if ! command -v emcc &> /dev/null; then
    echo "❌ Emscripten not found. Please install and activate emsdk."
    echo "Visit: https://emscripten.org/docs/getting_started/downloads.html"
    exit 1
fi

# نظف أي ملفات WASM سابقة
rm -f module.wasm module.js

# Compile WASM locally
echo "📦 Compiling WASM module locally..."
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

# تحقق من نجاح البناء
if [ -f "module.wasm" ]; then
    echo "✅ Build successful!"
    echo "📏 WASM size: $(stat -c%s module.wasm 2>/dev/null || stat -f%z module.wasm) bytes"
else
    echo "❌ Build failed!"
    exit 1
fi

echo "🚀 WASM module is ready locally for testing!"
