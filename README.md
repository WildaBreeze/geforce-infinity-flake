# GeForce Infinity Flake

A Nix flake for [GeForce Infinity](https://github.com/AstralVixen/GeForce-Infinity) - an enhanced GeForce NOW experience for Linux.

## 🎯 Solution: FHS Environment

This flake uses **`buildFHSEnv`** to solve the "non-nix executables" problem. Following the [nix.dev FAQ recommendation](https://nix.dev/guides/faq#how-to-run-non-nix-executables), we create a Filesystem Hierarchy Standard environment that provides all the dynamic libraries Electron apps need.

### Why FHS?

NixOS doesn't have a global library path (`/usr/lib`, `/lib`) and doesn't follow FHS. This causes dynamically linked binaries (like Electron apps) to fail with "file not found" errors for libraries.

`buildFHSEnv` creates a chroot environment with:
- Standard Linux directory structure
- All required libraries in expected locations
- Proper dynamic linker configuration

## ✅ What Works Now

| Feature | Status | Command |
|---------|--------|---------|
| Development shell | ✅ Working | `nix develop` |
| Build locally | ✅ Working | `npm install && npm run build` |
| Run app | ✅ Working | `nix run` |
| Library resolution | ✅ Working | Via `buildFHSEnv` |

## 🚀 Quick Start

### 1. Enter Development Shell

```bash
nix develop git+https://git.rislavarn.cloud/argus/geforce-infinity-flake
```

### 2. Clone and Build

```bash
git clone https://github.com/AstralVixen/GeForce-Infinity.git
cd GeForce-Infinity
npm install
npm run build
```

### 3. Run the App

```bash
# From the project directory
nix run

# Or from anywhere
nix run git+https://git.rislavarn.cloud/argus/geforce-infinity-flake
```

## 📦 Flake Outputs

```nix
# Development shell with build tools
packages.devShells.default

# FHS environment package
packages.geforce-infinity-fhs

# Wrapper script
packages.geforce-infinity

# App for nix run
apps.default
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

## 📚 How It Works

### The Problem

When you build an Electron app locally with `npm`, the resulting binaries expect libraries in standard locations like:
- `/usr/lib/libssl.so`
- `/lib/x86_64-linux-gnu/libc.so`

NixOS doesn't have these paths, so the app fails to start.

### The Solution

`buildFHSEnv` creates a wrapper that:
1. Sets up a chroot with FHS directory structure
2. Symlinks all required libraries into `/usr/lib`
3. Runs the Electron app inside this environment
4. Handles all dynamic linking transparently

```nix
geforce-infinity-fhs = pkgs.buildFHSEnv {
  name = "geforce-infinity";
  targetPkgs = pkgs: with pkgs; [
    electron
    gtk3
    glib
    nss
    # ... all other libraries
  ];
  runScript = ''
    electron /path/to/app/dist/electron/main.js --no-sandbox
  '';
};
```

## 🔧 Customization

### Adding More Libraries

If the app needs additional libraries, add them to `targetPkgs` in `flake.nix`:

```nix
targetPkgs = pkgs: with pkgs; [
  # Existing libraries...
  
  # Add new ones here
  libfoo
  libbar
];
```

### Using with Your NixOS Config

```nix
# In your configuration.nix
environment.systemPackages = [
  inputs.geforce-infinity-flake.packages.${pkgs.system}.geforce-infinity
];
```

## 📖 Further Reading

- [nix.dev: How to run non-nix executables](https://nix.dev/guides/faq#how-to-run-non-nix-executables)
- [Nixpkgs: buildFHSEnv documentation](https://nixos.org/manual/nixpkgs/stable/#sec-fhs-environments)
- [GeForce Infinity upstream repository](https://github.com/AstralVixen/GeForce-Infinity)

## 🔍 Troubleshooting

### "file not found" errors
If you see errors about missing `.so` files, add the missing library to `targetPkgs` in `flake.nix`.

### "Cannot open display" 
Make sure you're running from a graphical session with `$DISPLAY` set.

### Audio not working
The FHS environment includes pulseaudio and pipewire libraries. Make sure your host system is running a sound server.

## License

MIT (same as upstream)
