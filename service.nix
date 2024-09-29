 flake: {config, pkgs, lib, ...}:
 
 let
   cfg = config.services.flamenco;
   flamenco = flake.packages.${pkgs.stdenv.hostPlatform.system};
	datadirs = flake.datadirs;
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
				ExecStart = "${flamenco.manager}";
				WorkingDirectory = "%h/.local/state/flamenco/manager";
			};
		};
		systemd.services.flamenco-worker = {
			wantedBy = ["multi-user.target"];
			after = ["network.target"];
			description = "Run Flamenco Worker";
			serviceConfig = {
				Type = "simple";
				ExecStart = "${flamenco.worker}";
				WorkingDirectory = "%h/.local/state/flamenco/worker";
			};
		};
	};
 }
