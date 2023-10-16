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
      myR = pkgs.rWrapper.override{ packages = [
        pkgs.rPackages.tidyverse
        qorn.pajengr
      ]; };
    in
    {
      packages.${system} = {
        notes = pkgs.writeShellApplication {
          name = "notes";
          runtimeInputs = [ pkgs.emacs ];
          text = ''
            emacs -q -l ./.init.el notes.org &
          '';
        };
        simgrid = pkgs.simgrid.overrideAttrs (finalAttrs: previousAttrs: {
            patches = [ ./test.patch ];
        });
        ior-simgrid = pkgs.ior.overrideAttrs (finalAttrs: previousAttrs: {
            pname = "ior-simgrid";
            propagatedBuildInputs = [ pkgs.simgrid ];
            configurePhase = ''
              ./bootstrap && SMPI_PRETEND_CC=1 ./configure --prefix=$out MPICC=${pkgs.simgrid}/bin/smpicc CC=${pkgs.simgrid}/bin/smpicc
            '';
          });
      };
      devShells.${system} = {
        default = pkgs.mkShell {
          packages = [
            qorn.ior-simgrid
            myR
          ];
        };
        expe = pkgs.mkShell {
          packages = [
            self.packages.${system}.ior-simgrid
          ];
          shellHook = ''
            ln -sf ${self.packages.${system}.ior-simgrid}/bin/ior ior.bin
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
