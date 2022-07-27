{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-22.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree rec {
          blinky = pkgs.stdenv.mkDerivation rec {
            pname = "blinky";
            version = "0.0.0";
            src = nixpkgs.lib.cleanSource ./.;
            nativeBuildInputs = with pkgs; [
              gcc-arm-embedded
              stlink
            ];
            buildPhase = ''
              make
            '';
            installPhase = ''
              mkdir -p "$out/share/${pname}"
              cp -v build/*.elf build/*.hex build/*.bin "$out/share/${pname}/"

              mkdir -p $out/bin/
              echo "#!/bin/sh" > $out/bin/install-blinky-stlink
              echo "st-flash write $out/share/blinky/Blinky.bin 0x08000000" >> $out/bin/install-blinky-stlink
              chmod +x $out/bin/install-blinky-stlink
            '';
            fixupPhase = ''
              # do nothing
            '';
            buildInputs = with pkgs; [
            ];
          };
          default = blinky;
        };
        apps = {
          install = flake-utils.lib.mkApp {
            drv = packages.blinky;
            exePath = "/bin/install-blinky-stlink";
          };
        };
      }
    );
}
