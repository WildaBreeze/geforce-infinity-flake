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
        
        version = "1.2.2";
        
        # Download pre-built release
        geforce-infinity-bin = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "geforce-infinity-bin";
          inherit version;
          
          src = pkgs.fetchzip {
            url = "https://github.com/AstralVixen/GeForce-Infinity/releases/download/1.2.2/GeForceInfinity-linux-1.2.2-x64.zip";
            hash = "sha256-hw2mM6+OaILUhQU+PSvOf4dqS26COKzQY5VTrCpBHeo=";
            stripRoot = false;
          };
          
          dontConfigure = true;
          dontBuild = true;
          
          installPhase = ''
            mkdir -p $out/share/geforce-infinity
            cp -r ./* $out/share/geforce-infinity/
            
            mkdir -p $out/bin
            ln -s $out/share/geforce-infinity/geforce-infinity $out/bin/geforce-infinity-binary
          '';
        };
        
        # FHS environment wrapper - runs the pre-built binary
        geforce-infinity-fhs = pkgs.buildFHSEnv {
          name = "geforce-infinity";
          targetPkgs = pkgs: with pkgs; [
            # Electron runtime dependencies
            gtk3 glib nss nspr dbus alsa-lib cups systemd libdrm mesa
            libx11 libxscrnsaver libxtst libxkbfile libxcomposite libxdamage
            libxrandr libxrender libxext libxfixes libxcb libxkbcommon
            at-spi2-atk at-spi2-core pango cairo gdk-pixbuf atk
            libglvnd vulkan-loader wayland libepoxy
            pulseaudio pipewire freetype fontconfig openssl
            udev libusb1 libsecret gsettings-desktop-schemas
            mesa.drivers  # for libgbm
            bubblewrap
          ];
          
          runScript = pkgs.writeShellScript "geforce-infinity-launcher" ''
            export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:${pkgs.mesa}/lib:${pkgs.mesa.drivers}/lib"
            exec ${geforce-infinity-bin}/share/geforce-infinity/geforce-infinity --no-sandbox "$@"
          '';
          
          meta = with pkgs.lib; {
            description = "Enhanced GeForce NOW experience for Linux";
            homepage = "https://github.com/AstralVixen/GeForce-Infinity";
            license = licenses.mit;
            platforms = platforms.linux;
            mainProgram = "geforce-infinity";
          };
        };
      in
      {
        packages = {
          geforce-infinity-bin = geforce-infinity-bin;
          geforce-infinity = geforce-infinity-fhs;
          default = geforce-infinity-fhs;
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.geforce-infinity}/bin/geforce-infinity";
        };
      });
}
