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
          
          nativeBuildInputs = [ pkgs.makeWrapper ];
          
          dontConfigure = true;
          dontBuild = true;
          
          installPhase = ''
            mkdir -p $out/share/geforce-infinity
            cp -r ./* $out/share/geforce-infinity/
            
            mkdir -p $out/bin
            
            # Wrap the binary with all required library paths
            makeWrapper $out/share/geforce-infinity/geforce-infinity $out/bin/geforce-infinity-binary \
              --prefix LD_LIBRARY_PATH : "${pkgs.lib.makeLibraryPath [
                pkgs.gtk3 pkgs.glib pkgs.nss pkgs.nspr pkgs.dbus pkgs.libxscrnsaver
                pkgs.libxtst pkgs.libxkbfile pkgs.alsa-lib pkgs.cups pkgs.systemd
                pkgs.libdrm pkgs.mesa pkgs.libxcomposite pkgs.libxdamage
                pkgs.libxrandr pkgs.libxrender pkgs.libxext pkgs.libxfixes
                pkgs.libxcb pkgs.expat pkgs.libxkbcommon pkgs.at-spi2-atk
                pkgs.at-spi2-core pkgs.pango pkgs.cairo pkgs.gdk-pixbuf pkgs.atk
                pkgs.libglvnd pkgs.vulkan-loader pkgs.wayland pkgs.libepoxy
                pkgs.pulseaudio pkgs.pipewire pkgs.freetype pkgs.fontconfig
                pkgs.openssl pkgs.udev pkgs.libusb1 pkgs.libsecret
                pkgs.gsettings-desktop-schemas pkgs.libx11
              ]}:$out/share/geforce-infinity" \
              --add-flags "--no-sandbox"
          '';
        };
      in
      {
        packages = {
          geforce-infinity = geforce-infinity-bin;
          default = geforce-infinity-bin;
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.geforce-infinity}/bin/geforce-infinity-binary";
        };
      });
}
