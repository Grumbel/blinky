{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";

    stm32cubef4_src.url = "github:STMicroelectronics/STM32CubeF4";
    stm32cubef4_src.flake = false;
  };

  outputs = { self, nixpkgs, flake-utils, stm32cubef4_src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = rec {
          default = blinky;

          blinky = pkgs.stdenv.mkDerivation rec {
            pname = "blinky";
            version = "0.0.0";
            src = nixpkgs.lib.cleanSource ./.;
            nativeBuildInputs = with pkgs; [
              gcc-arm-embedded
              stlink
            ];
            buildPhase = ''
              make STM32CUBEF4=${stm32cubef4_src}
            '';
            installPhase = ''
              mkdir -p "$out/share/${pname}"
              cp -v build/*.elf build/*.hex build/*.bin "$out/share/${pname}/"
            '';
            fixupPhase = ''
              # do nothing
            '';
            buildInputs = with pkgs; [
            ];
          };

          flash-blinky = pkgs.writeShellScriptBin "flash-blinky" ''
            st-flash write ${blinky}/share/blinky/Blinky.bin 0x08000000
          '';
        };
      }
    );
}
