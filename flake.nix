{
  description = "XMC toolchain for NixOS";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    systems.url = "github:nix-systems/default";
    flake-utils.url = "github:numtide/flake-utils";
    flake-utils.inputs.systems.follows = "systems";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    (flake-utils.lib.eachDefaultSystem (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      legacyPackages = {
        xmclib = pkgs.callPackage ./pkgs/xmclib {};
      };

      devShells.default = let
        xmclib = self.legacyPackages.${system}.xmclib;
      in
        pkgs.mkShell {
          packages = with pkgs; [
            gcc-arm-embedded
            xmclib
          ];

          env = {
            XMC_LIBDIR = "${xmclib}/opt/XMClib/XMC_Peripheral_Library_v${xmclib.version}";
          };
        };
    }))
    // {
      nixosModules.jlink = import ./module.nix nixpkgs;
    };
}
