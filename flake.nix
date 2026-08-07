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
        
        libraryPath = pkgs.lib.makeLibraryPath [
          pkgs.gtk3 pkgs.glib pkgs.nss pkgs.nspr pkgs.dbus pkgs.libxscrnsaver
          pkgs.libxtst pkgs.libxkbfile pkgs.alsa-lib pkgs.cups pkgs.systemd
          pkgs.libdrm pkgs.mesa pkgs.libxcomposite pkgs.libxdamage
          pkgs.libxrandr pkgs.libxrender pkgs.libxext pkgs.libxfixes
          pkgs.libxcb pkgs.libxkbcommon pkgs.at-spi2-atk pkgs.at-spi2-core
          pkgs.pango pkgs.cairo pkgs.gdk-pixbuf pkgs.atk pkgs.libglvnd
          pkgs.vulkan-loader pkgs.wayland pkgs.libepoxy pkgs.pulseaudio
          pkgs.pipewire pkgs.freetype pkgs.fontconfig pkgs.openssl
          pkgs.udev pkgs.libusb1 pkgs.libsecret pkgs.gsettings-desktop-schemas
          pkgs.libx11 pkgs.stdenv.cc.cc
        ];
        
        # Download pre-built release and patch it for NixOS
        geforce-infinity = pkgs.stdenvNoCC.mkDerivation rec {
          pname = "geforce-infinity";
          inherit version;
          
          src = pkgs.fetchzip {
            url = "https://github.com/AstralVixen/GeForce-Infinity/releases/download/1.2.2/GeForceInfinity-linux-1.2.2-x64.zip";
            hash = "sha256-hw2mM6+OaILUhQU+PSvOf4dqS26COKzQY5VTrCpBHeo=";
            stripRoot = false;
          };
          
          # Include the logo file
          logo = ./assets/resources/infinitylogo.png;
          
          nativeBuildInputs = [ pkgs.autoPatchelfHook pkgs.makeWrapper ];
          
          buildInputs = with pkgs; [
            # Libraries the binary needs
            gtk3 glib nss nspr dbus libxscrnsaver libxtst libxkbfile alsa-lib
            cups systemd libdrm mesa libxcomposite libxdamage libxrandr
            libxrender libxext libxfixes libxcb libxkbcommon at-spi2-atk
            at-spi2-core pango cairo gdk-pixbuf atk libglvnd vulkan-loader
            wayland libepoxy pulseaudio pipewire freetype fontconfig openssl
            udev libusb1 libsecret gsettings-desktop-schemas libx11
            stdenv.cc.cc  # for libstdc++
          ];
          
          dontConfigure = true;
          dontBuild = true;
          
          installPhase = ''
            mkdir -p $out/share/geforce-infinity
            cp -r ./* $out/share/geforce-infinity/
            
            mkdir -p $out/bin
            
            # Create wrapper script that sets up the environment
            makeWrapper $out/share/geforce-infinity/geforce-infinity $out/bin/geforce-infinity \
              --prefix LD_LIBRARY_PATH : "${libraryPath}:$out/share/geforce-infinity" \
              --add-flags "--no-sandbox"
            
            # Copy logo for desktop entry
            mkdir -p $out/share/icons/hicolor/256x256/apps
            cp $logo $out/share/icons/hicolor/256x256/apps/geforce-infinity.png
            
            # Create .desktop file
            mkdir -p $out/share/applications
            cat > $out/share/applications/geforce-infinity.desktop <<EOF
[Desktop Entry]
Name=GeForce Infinity
Comment=Enhanced GeForce NOW experience
Exec=$out/bin/geforce-infinity
Icon=geforce-infinity
Type=Application
Categories=Game;Network;
Terminal=false
StartupNotify=true
EOF
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
          inherit geforce-infinity;
          default = geforce-infinity;
        };

        apps.default = {
          type = "app";
          program = "${self.packages.${system}.geforce-infinity}/bin/geforce-infinity";
        };
      });
}
