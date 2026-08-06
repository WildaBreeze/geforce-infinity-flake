{
  description = "GeForce Infinity - Enhanced GeForce NOW experience";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        
        # Electron - using latest available in nixpkgs
        electron = pkgs.electron;
        
        # App version
        version = "1.2.2";
        
        # Common library path for Electron apps
        electronLibPath = pkgs.lib.makeLibraryPath [
          pkgs.gtk3
          pkgs.glib
          pkgs.nss
          pkgs.nspr
          pkgs.dbus
          pkgs.libxscrnsaver
          pkgs.libxtst
          pkgs.libxkbfile
          pkgs.alsa-lib
          pkgs.cups
          pkgs.systemd
          pkgs.libdrm
          pkgs.mesa
          pkgs.libxcomposite
          pkgs.libxdamage
          pkgs.libxrandr
          pkgs.libxrender
          pkgs.libxext
          pkgs.libxfixes
          pkgs.libxcb
          pkgs.expat
          pkgs.libxkbcommon
          pkgs.at-spi2-atk
          pkgs.at-spi2-core
          pkgs.pango
          pkgs.cairo
          pkgs.gdk-pixbuf
          pkgs.atk
        ];
      in
      rec {
        # Package: Wraps a pre-built version
        # Note: This requires the user to build first using 'nix develop'
        packages = {
          geforce-infinity = pkgs.writeShellScriptBin "geforce-infinity" ''
            export LD_LIBRARY_PATH="${electronLibPath}:$LD_LIBRARY_PATH"
            export ELECTRON_IS_DEV=0
            export NODE_ENV=production
            
            # Check for locally built version
            if [ -d "$HOME/.local/share/geforce-infinity/dist" ]; then
              exec ${electron}/bin/electron "$HOME/.local/share/geforce-infinity/dist/electron/main.js" --no-sandbox "$@"
            fi
            
            # Check for project directory
            if [ -d "dist" ]; then
              exec ${electron}/bin/electron "./dist/electron/main.js" --no-sandbox "$@"
            fi
            
            echo "GeForce Infinity needs to be built first."
            echo "Run: nix develop"
            echo "Then: git clone https://github.com/AstralVixen/GeForce-Infinity.git"
            echo "      cd GeForce-Infinity && npm install && npm run build"
            exit 1
          '';
          
          default = packages.geforce-infinity;
        };

        # Development shell with all the tools needed
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.nodejs_22
            pkgs.bun
            electron
            pkgs.git
            pkgs.cacert
            pkgs.esbuild
            pkgs.tailwindcss
            pkgs.typescript
            pkgs.gnumake
            pkgs.python3
            pkgs.gcc
            pkgs.pkg-config
          ];
          
          shellHook = ''
            echo ""
            echo "🎮 Welcome to GeForce Infinity Development Shell"
            echo ""
            echo "Quick start:"
            echo "  git clone https://github.com/AstralVixen/GeForce-Infinity.git"
            echo "  cd GeForce-Infinity"
            echo "  npm install"
            echo "  npm run build"
            echo "  npm run start"
            echo ""
            echo "Note: If your CPU supports AVX2, you can use 'bun' instead of 'npm'"
            echo "      for faster installs: bun install && bun run build"
            echo ""
          '';
        };
        
        # App for nix run
        apps.default = {
          type = "app";
          program = "${packages.geforce-infinity}/bin/geforce-infinity";
        };
      });
}
