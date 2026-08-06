# GeForce Infinity Flake

A Nix flake for [GeForce Infinity](https://github.com/AstralVixen/GeForce-Infinity) - an enhanced GeForce NOW experience for Linux.

## ✅ What Works Now

The flake provides:
- `nix develop` - A development shell with all required tools
- `nix run` - Runs the app (requires local build first)
- `nix build` - Builds a wrapper script that finds your locally built app

## ⚠️ Build Challenges

This project has some unique requirements that make pure Nix builds difficult:

1. **Bun Runtime**: Uses Bun for builds, which requires modern CPU instructions (AVX2)
2. **No Lock File**: No `package-lock.json` in releases, preventing reproducible builds in pure Nix
3. **Native Dependencies**: Some packages need compilation with node-gyp

## 🚀 Usage

### Development Shell (Recommended)

```bash
# Enter the development environment
nix develop

# Clone and build
git clone https://github.com/AstralVixen/GeForce-Infinity.git
cd GeForce-Infinity
npm install
npm run build

# Run the app
npm run start
```

### Run (after building)

```bash
# From the project directory
nix run

# Or with explicit path to your built dist/
nix run ~/projects/GeForce-Infinity
```

## 🛠️ Development Environment

The flake provides:
- **Node.js 22** - JavaScript runtime
- **Bun** - Fast build tool (if your CPU supports AVX2)
- **Electron** - Desktop framework
- **TypeScript** - Type compiler
- **esbuild** - JavaScript bundler
- **TailwindCSS** - CSS framework
- **Build tools** - Python, GCC, Make, pkg-config for native modules

## 📋 Flake Commands

| Command | Description |
|---------|-------------|
| `nix develop` | Enter dev shell with all tools |
| `nix run` | Run the app (needs local build) |
| `nix build` | Build the wrapper package |
| `nix flake check` | Validate the flake |

## 🔧 Future Improvements

Possible enhancements:
1. Add a Docker-based build for systems without AVX2
2. Create a NixOS module for system-wide installation
3. Submit PR upstream to add `package-lock.json` to releases
4. Create an AppImage-based package

## License

MIT (same as upstream)
