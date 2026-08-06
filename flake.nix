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
        
        # FHS environment for running the Electron app
        # This solves the "non-nix executables" issue by providing
        # a standard Linux environment with all required libraries
        geforce-infinity-fhs = pkgs.buildFHSEnv {
          name = "geforce-infinity";
          targetPkgs = pkgs: with pkgs; [
            # Electron runtime dependencies
            electron
            gtk3
            glib
            nss
            nspr
            dbus
            libxscrnsaver
            libxtst
            libxkbfile
            alsa-lib
            cups
            systemd
            libdrm
            mesa
            libxcomposite
            libxdamage
            libxrandr
            libxrender
            libxext
            libxfixes
            libxcb
            expat
            libxkbcommon
            at-spi2-atk
            at-spi2-core
            pango
            cairo
            gdk-pixbuf
            atk
            # Additional libraries commonly needed by Electron
            libglvnd
            vulkan-loader
            wayland
            libepoxy
            # Audio
            pulseaudio
            pipewire
            # Fonts
            freetype
            fontconfig
            # Network
            openssl
            # Misc
            udev
            libusb1
            libsecret
            gsettings-desktop-schemas
          ];
          
          runScript = pkgs.writeShellScript "geforce-infinity-launcher" ''
            export ELECTRON_IS_DEV=0
            export NODE_ENV=production
            
            # Check for locally built version
            if [ -d "$HOME/.local/share/geforce-infinity/dist" ]; then
              exec ${electron}/bin/electron "$HOME/.local/share/geforce-infinity/dist/electron/main.js" --no-sandbox "$@"
            fi
            
            # Check for project directory in common locations
            for dir in "$HOME/projects/GeForce-Infinity" "$HOME/GeForce-Infinity" "./GeForce-Infinity"; do
              if [ -d "$dir/dist" ]; then
                exec ${electron}/bin/electron "$dir/dist/electron/main.js" --no-sandbox "$@"
              fi
            done
            
            echo "GeForce Infinity needs to be built first."
            echo ""
            echo "Quick start:"
            echo "  git clone https://github.com/AstralVixen/GeForce-Infinity.git"
            echo "  cd GeForce-Infinity"
            echo "  npm install && npm run build"
            echo "  nix run"
            exit 1
          '';
          
          meta = with pkgs.lib; {
            description = "Enhanced GeForce NOW experience for Linux (FHS environment)";
            homepage = "https://github.com/AstralVixen/GeForce-Infinity";
            license = licenses.mit;
            platforms = platforms.linux;
            mainProgram = "geforce-infinity";
          };
        };
      in
      rec {
        packages = {
          inherit geforce-infinity-fhs;
          
          # Wrapper script that launches the FHS environment
          geforce-infinity = pkgs.writeShellScriptBin "geforce-infinity" ''
            exec ${geforce-infinity-fhs}/bin/geforce-infinity "$@"
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
            echo "  npm install && npm run build"
            echo "  nix run"
            echo ""
            echo "The built app will run in an FHS environment with all libraries available."
            echo "This solves the 'non-nix executables' issue documented at:"
            echo "  https://nix.dev/guides/faq#how-to-run-non-nix-executables"
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
