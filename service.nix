 flake: {config, pkgs, lib, ...}:
 
 let
   cfg = config.services.flamenco;
   flamenco = flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
 in
 
 with lib;

 {
	options = {
		services.flamenco = {
			enable = mkOption {
				default = false;
				description = "run flamenco manager and flamenco worker as a service";
			};
		};
	};

	config = mkIf cfg.enable {
		systemd.services.flamenco = {
			wantedBy = ["multi-user.target"];
			after = ["network.target"];
			description = "Run Flamenco Manager and Worker";
			serviceConfig = {
				Type = "simple";
				ExecStart = "${flamenco}/bin/flamenco-manager";
				ExecStartPost = "${flamenco}/bin/flamenco-worker";
			};
		};
	};
 }
