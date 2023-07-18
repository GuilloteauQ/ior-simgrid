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
      devShells.${system} = {
        default = pkgs.mkShell {
          buildInputs = [
            qorn.ior-simgrid
            myR
          ];
        };
      };
    };
}
