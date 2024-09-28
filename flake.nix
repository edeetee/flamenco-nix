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
          name = "flamenco-manager-3.5";
          version = "3.5";
          src = pkgs.fetchurl {
			url = "https://flamenco.blender.org/downloads/flamenco-3.5-linux-amd64.tar.gz";
			sha256 = "78f6e647fb3512e73f1985ae947d50b428b9d9830ecb75fc0bf4c7a814646f9e";
          };

          installPhase = ''
            mkdir -p $out/bin
            # Extract the archive for a more accurate executable path
            tar -xf $src -C $out 
            cp -r $out/flamenco-3.5-linux-amd64/* $out/bin  # Assuming this is the path
	    mkdir /var/tmp/flamenco-manager-storage || true
	    ln -s /var/tmp/flamenco-manager-storage $out/bin/flamenco-manager-storage
		cp ${././flamenco-manager.yaml} $out/bin/flamenco-manager.yaml
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

