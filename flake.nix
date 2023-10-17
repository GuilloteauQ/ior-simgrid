{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05";
    qornflakes.url = "github:guilloteauq/qornflakes";
    qornflakes.inputs."nixpkgs".follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, qornflakes }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
      qorn = qornflakes.packages.${system};
      myR = pkgs.rWrapper.override {
        packages = [ pkgs.rPackages.tidyverse qorn.pajengr ];
      };
    in {
      packages.${system} = rec {
        notes = pkgs.writeShellApplication {
          name = "notes";
          runtimeInputs = [ pkgs.emacs ];
          text = ''
            emacs -q -l ./.init.el notes.org &
          '';
        };
        replayer = pkgs.stdenv.mkDerivation {
          name = "replayer";
          src = ./replayer_src;
          buildInputs = [ simgrid ];
          buildPhase = ''
            smpicxx -o replayer replay.cpp -std=c++17
          '';
          installPhase = ''
            mkdir -p $out/bin
            cp replayer $out/bin
          '';
        };
        simgrid = pkgs.simgrid.overrideAttrs
          (finalAttrs: previousAttrs: { patches = [ ./test.patch ]; });
        ior-simgrid = pkgs.ior.overrideAttrs (finalAttrs: previousAttrs: {
          pname = "ior-simgrid";
          propagatedBuildInputs = [ simgrid ];
          configurePhase = ''
            ./bootstrap && SMPI_PRETEND_CC=1 ./configure --prefix=$out MPICC=${simgrid}/bin/smpicc CC=${simgrid}/bin/smpicc
          '';
        });
      };
      devShells.${system} = {
        rshell = pkgs.mkShell {
          packages = [
            # qorn.ior-simgrid
            myR
          ];
        };
        expe = pkgs.mkShell {
          packages = [
            self.packages.${system}.ior-simgrid
            self.packages.${system}.replayer
          ];
          shellHook = ''
            ln -sf ${self.packages.${system}.ior-simgrid}/bin/ior ior.bin
            ln -sf ${self.packages.${system}.replayer}/bin/replayer replay.bin
          '';
        };
        dev = pkgs.mkShell {
          packages = [
            # pkgs.simgrid
            self.packages.${system}.simgrid
            pkgs.gnumake
            pkgs.gnat
            pkgs.pkg-config
          ];
        };
      };
    };
}
