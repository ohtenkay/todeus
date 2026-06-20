{ pkgs, lib, ... }:

{
  packages = [
    pkgs.docker-client
    pkgs.docker-compose
  ];

  android = {
    enable = true;
    flutter.enable = true;

    platforms.version = [
      "32"
      "33"
      "34"
      "35"
      "36"
    ];
  };

  languages.dart.enable = true;

  scripts.convex-up.exec = ''
    exec docker-compose --project-name todeus-convex --project-directory "$DEVENV_ROOT/self-hosted/convex" -f "$DEVENV_ROOT/self-hosted/convex/docker-compose.yml" up -d "$@"
  '';

  scripts.convex-down.exec = ''
    exec docker-compose --project-name todeus-convex --project-directory "$DEVENV_ROOT/self-hosted/convex" -f "$DEVENV_ROOT/self-hosted/convex/docker-compose.yml" down "$@"
  '';

  scripts.convex-logs.exec = ''
    exec docker-compose --project-name todeus-convex --project-directory "$DEVENV_ROOT/self-hosted/convex" -f "$DEVENV_ROOT/self-hosted/convex/docker-compose.yml" logs -f "$@"
  '';

  scripts.convex-status.exec = ''
    exec docker-compose --project-name todeus-convex --project-directory "$DEVENV_ROOT/self-hosted/convex" -f "$DEVENV_ROOT/self-hosted/convex/docker-compose.yml" ps "$@"
  '';

  scripts.convex-admin-key.exec = ''
    exec docker-compose --project-name todeus-convex --project-directory "$DEVENV_ROOT/self-hosted/convex" -f "$DEVENV_ROOT/self-hosted/convex/docker-compose.yml" exec backend ./generate_admin_key.sh
  '';

  scripts.start-emulator.exec = ''
    export ANDROID_AVD_HOME="$PWD/.android/avd"
    exec emulator -avd pixel-6-pro-api-36 -gpu host
  '';

  scripts.flutter-run.exec = ''
    exec flutter run --dart-define=CONVEX_URL=http://10.0.2.2:3210 "$@"
  '';

  # Work around https://github.com/cachix/devenv/issues/2782: devenv's Android
  # shell puts build-tools lib64 on LD_LIBRARY_PATH, which makes the emulator
  # load the wrong libc++.so and fail with a libabseil_dll.so symbol error.
  enterShell = lib.mkAfter ''
    export LD_LIBRARY_PATH="${
      pkgs.lib.makeLibraryPath [
        pkgs.vulkan-loader
        pkgs.libGL
      ]
    }"
  '';
}
