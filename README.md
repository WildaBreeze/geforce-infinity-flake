# GeForce Infinity Flake

A Nix flake for [GeForce Infinity](https://github.com/AstralVixen/GeForce-Infinity) - an enhanced GeForce NOW experience for Linux.

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

| Output | Description | Command |
|--------|-------------|---------|
| Dev shell | Build tools and dependencies | `nix develop` |
| Package | FHS environment wrapper | `nix build .#geforce-infinity` |
| App | Direct launcher | `nix run` |

## 🛠️ Development Environment

The flake provides:
- **Node.js 22** - JavaScript runtime
- **Bun** - Fast build tool (if your CPU supports AVX2)
- **Electron** - Desktop framework
- **Build tools** - Python, GCC, Make, pkg-config for native modules

## 📚 How It Works

This flake uses **`buildFHSEnv`** to run Electron apps on NixOS. It creates an FHS (Filesystem Hierarchy Standard) environment that provides all the dynamic libraries Electron needs.

For technical details on why this approach was chosen and how the flake is structured, see [TECHNICAL.md](./TECHNICAL.md).

## 🔧 Customization

### Adding More Libraries

If the app needs additional libraries, add them to `targetPkgs` in `flake.nix`:

```nix
targetPkgs = pkgs: with pkgs; [
  # Existing libraries...
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
