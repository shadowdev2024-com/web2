// Placeholder wasm_source.c
// This is a minimal C source file included as a placeholder.
// For production you'd implement a proper check_secret exported function.
// Example simple stub using EMSCRIPTEN_KEEPALIVE to ensure export when compiled with emscripten.

#include <emscripten/emscripten.h>
#include <stdint.h>
#include <string.h>

// Simple stub: returns 0 (access denied) for all inputs.
// Replace with real challenge logic when building the challenge.
EMSCRIPTEN_KEEPALIVE
int check_secret(const char* ptr, int len) {
    (void)ptr;
    (void)len;
    return 0;
}

// Allocation stub if needed by build scripts.
EMSCRIPTEN_KEEPALIVE
void* alloc(int size) {
    return malloc(size);
}
