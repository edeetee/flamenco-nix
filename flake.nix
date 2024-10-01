{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # Or a stable channel
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    let 
		system = "x86_64-linux";
    	pkgs = import nixpkgs { 
				inherit system;
			};
    in 
    {
      packages.${system} = rec {
		flamenco = pkgs.callPackage ./hubble-flamenco.nix {};
        default = flamenco;
      };

	  nixosModules.flamenco = import ./hubble-service.nix self;
    };
}

