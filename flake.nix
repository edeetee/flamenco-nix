{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11"; # Or a stable channel
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    utils.lib.eachDefaultSystem
    (system:
      let 
        pkgs = import nixpkgs { 
          inherit system;
        };
      in 
      {
        packages = rec {
          flamenco = pkgs.callPackage ./hubble-flamenco.nix {};
          default = flamenco;
        };

        nixosModules.flamenco = import ./hubble-service.nix self;
      }
    );
}

