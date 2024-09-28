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
		systemd.services.flamenco-manager = {
			wantedBy = ["multi-user.target"];
			after = ["network.target"];
			description = "Run Flamenco Manager";
			serviceConfig = {
				Type = "simple";
				ExecStart = "${flamenco}/bin/flamenco-manager";
				WorkingDirectory = "${flamenco}";
			};
		};
		systemd.services.flamenco-worker = {
			wantedBy = ["multi-user.target"];
			after = ["network.target"];
			description = "Run Flamenco Worker";
			serviceConfig = {
				Type = "simple";
				ExecStart = "${flamenco}/bin/flamenco-worker";
				WorkingDirectory = "${flamenco}";
			};
		};
	};
 }
