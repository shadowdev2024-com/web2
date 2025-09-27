# CYBERDUNE CTF Challenge

A **Very Hard** WebAssembly reverse engineering challenge with client-side integrity bypass requirements.

## Quick Start

### Deploy to Vercel
1. Fork this repository
2. Go to [vercel.com](https://vercel.com)
3. Click "New Project" → Import Git Repository
4. Select this repository
5. Deploy (no build configuration needed)

### Local Testing
```bash
# Option 1: Python
python -m http.server 8000

# Option 2: Node.js
npx serve .

# Option 3: PHP
php -S localhost:8000
```

## Building the WASM Module

Before deployment, you must compile the WebAssembly module:

```bash
# Make build script executable
chmod +x build.sh

# Run build
./build.sh
```

This creates `module.wasm` from `wasm_source.c`.

## Challenge Details

- **Difficulty**: Very Hard
- **Flag Format**: `CYBERDUNE{...}`
- **Skills Required**: WASM reverse engineering, client-side bypass
- **Theme**: Black/Red/White Matrix style

The flag is encrypted within the WASM binary and requires reverse engineering to extract.

## Security Note

This challenge is designed for educational purposes. All security mechanisms are intentionally client-side and bypassable.
