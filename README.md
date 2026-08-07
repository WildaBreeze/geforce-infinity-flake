# GeForce Infinity Flake

A Nix flake for [GeForce Infinity](https://github.com/AstralVixen/GeForce-Infinity) - an enhanced GeForce NOW experience for Linux.

## 🚀 Quick Start

Just run:

```bash
nix run github:WildaBreeze/geforce-infinity-flake
```

That's it! The application will download and run automatically.

## 📦 Flake Outputs

| Output | Description |
|--------|-------------|
| `packages.default` | The runnable application |
| `apps.default` | Same as `nix run` |

## 🔧 Using in Your NixOS Config

Add this flake as an input:

```nix
# flake.nix
{
  inputs.geforce-infinity-flake.url = "github:WildaBreeze/geforce-infinity-flake";
  
  outputs = { self, nixpkgs, geforce-infinity-flake, ... }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            geforce-infinity-flake.packages.${system}.default
          ];
        }
      ];
    };
  };
}
```

Or use it with Home Manager:

```nix
# home.nix
{ pkgs, inputs, ... }: {
  home.packages = [ 
    inputs.geforce-infinity-flake.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
```

## 📚 How It Works

This flake downloads the official pre-built release and wraps it in an FHS (Filesystem Hierarchy Standard) environment. This solves the issue of running non-Nix binaries on NixOS by providing all required libraries in expected locations.

## 📖 Further Reading

- [nix.dev: How to run non-nix executables](https://nix.dev/guides/faq#how-to-run-non-nix-executables)
- [GeForce Infinity upstream repository](https://github.com/AstralVixen/GeForce-Infinity)

## License

[MIT](LICENSE.md) — same as the upstream GeForce Infinity project.
