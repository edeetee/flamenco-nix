{
  lib,
  buildGo123Module,
  fetchFromGitea,
  fetchYarnDeps,
  fixup-yarn-lock,
  makeWrapper,
  blender-hip,
  ffmpeg,
  go_1_23,
  oapi-codegen,
  mockgen,
  nodejs,
  yarn,
  prefetch-yarn-deps,
}: buildGo123Module rec {
    pname = "flamenco";
	version = "3.6-alpha4";

    src = fetchFromGitea {
      domain = "projects.blender.org";
      owner = "studio";
      repo = "flamenco";
      rev = "5e52e1efa4";
      hash = "sha256-2FsRcmQJu8H8ZvH8i7qeWp9rUMVZqvhsMW28bwnHdg0=";
    };

    patches = [
      ./absolute-path-bypass.patch
    ];

    webappOfflineCache = fetchYarnDeps {
      yarnLock = "${src}/web/app/yarn.lock";
      hash = "sha256-QcfyiL2/ALkxZpJyiwyD7xNlkOCPu4THCyywwZ40H8s=";
    };

    vendorHash = "sha256-Kflpa+nQP106Pvu2ZcYDbxjL3wMGi01j/q1PP7b7BoE=";

    nativeBuildInputs = [
      makeWrapper
      go_1_23
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
      # TODO Wanted: maintainer for darwin
      platforms = ["x86_64-linux"];
      maintainers = with lib.maintainers; [hubble];
    };
  }
