{
  lib,
  buildGoModule,
  fetchFromGitea,
  fetchYarnDeps,
  fixup-yarn-lock,
  makeWrapper,
  blender-hip,
  ffmpeg,
  go_1_25,
  oapi-codegen,
  mockgen,
  nodejs,
  yarn,
  prefetch-yarn-deps,
}: buildGoModule rec {
    pname = "flamenco";
	  version = "3.8";

    src = fetchFromGitea {
      domain = "projects.blender.org";
      owner = "studio";
      repo = "flamenco";
      rev = "v3.8";
      hash = "sha256-F1UnvPpLsHrSIpr3GbYQ+kXG5nLV4iDuL+Vqi18/ohU=";
    };

    webappOfflineCache = fetchYarnDeps {
      yarnLock = "${src}/web/app/yarn.lock";
      hash = "sha256-9g7cClQD6/lorjIfljgj3lVcUbj+V+7RhrR9BYF25sc=";
    };

    vendorHash = "sha256-Kflpa+nQP106Pvu2ZcYDbxjL3wMGi01j/q1PP7b7BoE=";

    nativeBuildInputs = [
      makeWrapper
      go_1_25
      oapi-codegen
      mockgen
      nodejs
      yarn
      prefetch-yarn-deps
      fixup-yarn-lock
    ];

    buildInputs = [
      blender-hip
      ffmpeg
    ];

    postConfigure = ''
      export HOME=$(mktemp -d)
      yarn config --offline set yarn-offline-mirror ${webappOfflineCache}
      fixup-yarn-lock web/app/yarn.lock
      cd web/app && yarn --offline --frozen-lockfile --ignore-platform --ignore-scripts --no-progress --non-interactive install && cd ../..
      patchShebangs web
    '';

    buildPhase = ''
      runHook preBuild

      make -s webapp-static
      make -s flamenco-manager-without-webapp GOOS=linux GOARCH=amd64
      make -s flamenco-worker GOOS=linux GOARCH=amd64

      runHook postBuild
    '';

    postInstall = ''
      mkdir -p "$out/bin"
      cp flamenco-manager flamenco-worker $out/bin
    '';

    postFixup = ''
      for f in $out/bin/*
      do
        wrapProgram $f \
          --set PATH ${lib.makeBinPath [
        blender-hip
        ffmpeg
      ]}
      done
    '';

    meta = {
      description = "Production render farm manager for Blender";
      homepage = "https://flamenco.blender.org/";
      license = lib.licenses.gpl3Only;
      platforms = ["x86_64-linux"];
      maintainers = with lib.maintainers; [hubble];
    };
  }
