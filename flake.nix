{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable"; # Or a stable channel
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, utils }:
    let 
		system = "x86_64-linux";
    	pkgs = import nixpkgs { inherit system; };
		# datadirs = rec {
		# 	root = "~/.local/state/flamenco";
		# 	manager = "${root}/manager";
		# 	worker = "${root}/worker";
		# };
		#
  #       raw = pkgs.stdenv.mkDerivation { 
  #         name = "flamenco-manager-3.5";
  #         version = "3.5";
  #         src = pkgs.fetchurl {
		# 	url = "https://flamenco.blender.org/downloads/flamenco-3.5-linux-amd64.tar.gz";
		# 	sha256 = "78f6e647fb3512e73f1985ae947d50b428b9d9830ecb75fc0bf4c7a814646f9e";
  #         };
		#
  #         installPhase = ''
  #           mkdir -p $out/bin
  #           # Extract the archive for a more accurate executable path
  #           tar -xf $src -C $out 
  #           mv $out/flamenco-3.5-linux-amd64/* $out/bin  # Assuming this is the path
		# 	cp -f ${./flamenco-manager.yaml} $out/flamenco-manager.yaml
  #         '';
		#
  #         propagatedBuildInputs = with pkgs; [ 
  #           blender
  #         ];
  #       };
    in 
    {
      packages.${system} = rec {
		# manager = pkgs.writeShellApplication {
		# 	name = "flamenco-manager";
		# 	runtimeInputs = [ pkgs.coreutils ];
		#
		# 	text = ''
		# 		mkdir -p ${datadirs.manager}
		# 		cp ${raw}/flamenco-manager.yaml ${datadirs.manager} -n
		#
		# 		cd ${datadirs.manager}
		# 		${raw}/bin/flamenco-manager
		# 	'';
		# 	};
		#
		# worker = pkgs.writeShellApplication {
		# 	name = "flamenco-worker" ;
		# 	runtimeInputs = [ pkgs.coreutils ];
		#
		# 	text = ''
		# 		mkdir -p ${datadirs.worker}
		#
		# 		cd ${datadirs.worker}
		# 		${raw}/bin/flamenco-worker
		# 	'';
		# };
		flamenco = pkgs.callPackage ./hubble-flamenco.nix {};
        default = flamenco;
      };

	  nixosModules.flamenco = import ./hubble-service.nix self;
    };
}

