# Technical Details

This document explains the technical decisions behind the flake structure.

## The Problem

NixOS doesn't have a global library path (`/usr/lib`, `/lib`) and doesn't follow FHS. This causes dynamically linked binaries (like Electron apps) to fail with "file not found" errors for libraries.

## The Solution: buildFHSEnv

We use `buildFHSEnv` following the [nix.dev FAQ recommendation](https://nix.dev/guides/faq#how-to-run-non-nix-executables). It creates a chroot environment with:
- Standard Linux directory structure
- All required libraries in expected locations
- Proper dynamic linker configuration

## Why Not a Pure Nix Build?

We attempted several approaches before settling on the FHS wrapper:

| Approach | Result | Reason |
|----------|--------|--------|
| `bun` in Nix build | ❌ Failed | Bun requires AVX2 (not available on all hardware) |
| `npm` in Nix build | ❌ Failed | node-gyp needs network during build (sandbox violation) |
| `buildNpmPackage` | ❌ Failed | Upstream has no lock file (bun.lockb or package-lock.json) |
| **Local build + FHS wrapper** | ✅ **Works** | Build outside Nix, run inside FHS environment |

### Why No Lock File Matters

For a pure/reproducible Nix build, we need either:
- `bun.lockb` for `bun` builds
- `package-lock.json` for `npm` or `buildNpmPackage`

Without these, Nix cannot verify dependency integrity in the sandbox.

## How the FHS Wrapper Works

```nix
geforce-infinity-fhs = pkgs.buildFHSEnv {
  name = "geforce-infinity";
  targetPkgs = pkgs: with pkgs; [
    electron
    gtk3
    glib
    nss
    nspr
    mesa
    libdrm
    alsa-lib
    # ... all other libraries
  ];
  runScript = ''
    electron /path/to/app/dist/electron/main.js --no-sandbox
  '';
};
```

The wrapper:
1. Sets up a chroot with FHS directory structure
2. Symlinks all required libraries into `/usr/lib`
3. Runs the Electron app inside this environment
4. Handles all dynamic linking transparently

## Library Selection

The `targetPkgs` list includes libraries commonly needed by Electron apps:

- **Graphics**: mesa, libdrm, vulkan-loader, libglvnd
- **Audio**: alsa-lib, pulseaudio, pipewire
- **GTK/GUI**: gtk3, pango, cairo, gdk-pixbuf
- **Security**: nss, nspr, openssl
- **X11/Wayland**: libX11, libxcb, wayland, libxcomposite, etc.
- **D-Bus**: dbus, at-spi2-core

If you encounter missing library errors, use `ldd` to identify what's needed and `nix-locate -w libfoo.so.1` to find the Nix package.
