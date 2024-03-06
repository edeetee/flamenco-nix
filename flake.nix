{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # Or a stable channel
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    let 
	system = "x86_64-linux";
    	pkgs = import nixpkgs { inherit system; };
    in 
    {
      packages.${system} = {
        manager = pkgs.stdenv.mkDerivation { 
          name = "flamenco-manager-3.4";
          version = "3.4";
          src = pkgs.fetchurl {
            url = "https://flamenco.blender.org/downloads/flamenco-3.4-linux-amd64.tar.gz";
            sha256 = "1185a721cf3b016b2772c28a7b4748fe73dc97d73c88b197f670b2c719e20cc4";
          };

          installPhase = ''
            mkdir -p $out/bin
            # Extract the archive for a more accurate executable path
            tar -xf $src -C $out 
            cp -r $out/flamenco-3.4-linux-amd64/* $out/bin  # Assuming this is the path
	    mkdir /var/tmp/flamenco-manager-storage || true
	    ln -s /var/tmp/flamenco-manager-storage $out/bin/flamenco-manager-storage
          '';

          propagatedBuildInputs = with pkgs; [ 
            blender
          ];
        };
        
        default = self.packages.${system}.manager;
      };

	  nixosModules.flamenco = import ./service.nix self;
    };
}

