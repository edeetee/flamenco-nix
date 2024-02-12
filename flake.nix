{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # Or a stable channel
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    {
      defaultPackage.x86_64-linux = 
        with import nixpkgs { system = "x86_64-linux"; };
        stdenv.mkDerivation { 
          name = "flamenco-3.4";
          version = "3.4";
          src = pkgs.fetchurl {
            url = "https://flamenco.blender.org/downloads/flamenco-3.4-linux-amd64.tar.gz";
            sha256 = "1185a721cf3b016b2772c28a7b4748fe73dc97d73c88b197f670b2c719e20cc4";
          };

          installPhase = ''
            mkdir -p $out/bin
            # Extract the archive for a more accurate executable path
            tar -xf $src -C $out 
            cp $out/flamenco-3.4-linux-amd64/* $out/bin  # Assuming this is the path
          '';

          propagatedBuildInputs = with pkgs; [ 
            blender
          ];
        };
    };
}
