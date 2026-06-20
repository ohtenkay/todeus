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

  processes.convex.exec = ''
    compose=(
      docker-compose
      --project-name todeus-convex
      --project-directory "$DEVENV_ROOT/self-hosted/convex"
      -f "$DEVENV_ROOT/self-hosted/convex/docker-compose.yml"
    )

    exec "''${compose[@]}" up
  '';

  processes.convex.ready.http.get = {
    port = 3210;
    path = "/version";
  };

  processes.convex-dev = {
    exec = "npm run convex:dev";
    after = [ "convex:env" ];
  };

  processes.dart-codegen = {
    exec = ''
      export PATH="$DEVENV_ROOT/node_modules/.bin:$PATH"
      exec dart run dartvex_codegen generate \
        --project "$DEVENV_ROOT" \
        --output "$DEVENV_ROOT/lib/convex_api" \
        --watch
    '';
    after = [ "devenv:processes:convex-dev@started" ];
  };

  tasks."convex:env" = {
    after = [ "devenv:processes:convex@ready" ];
    exec = ''
    set -euo pipefail

    compose=(
      docker-compose
      --project-name todeus-convex
      --project-directory "$DEVENV_ROOT/self-hosted/convex"
      -f "$DEVENV_ROOT/self-hosted/convex/docker-compose.yml"
    )

    admin_key=$("''${compose[@]}" exec -T backend ./generate_admin_key.sh | sed -n 's/^convex-self-hosted|/convex-self-hosted|/p')

    if [ -z "$admin_key" ]; then
      echo "Failed to generate Convex admin key" >&2
      exit 1
    fi

    env_file="$DEVENV_ROOT/.env.local"
    tmp_file=$(mktemp)
    if [ -f "$env_file" ]; then
      grep -v -E '^(CONVEX_URL|CONVEX_URL_HOST|CONVEX_URL_ANDROID_EMULATOR|CONVEX_SELF_HOSTED_URL|CONVEX_SELF_HOSTED_ADMIN_KEY|CONVEX_SITE_URL)=' "$env_file" > "$tmp_file" || true
    fi

    {
      cat "$tmp_file"
      [ ! -s "$tmp_file" ] || printf '\n'
      printf 'CONVEX_SELF_HOSTED_URL=http://127.0.0.1:3210\n'
      printf 'CONVEX_SELF_HOSTED_ADMIN_KEY=%s\n' "$admin_key"
      printf 'CONVEX_SITE_URL=http://127.0.0.1:3211\n'
      printf '\nCONVEX_URL_HOST=http://127.0.0.1:3210\n'
      printf 'CONVEX_URL_ANDROID_EMULATOR=http://10.0.2.2:3210\n'
    } > "$env_file"

    rm -f "$tmp_file"
    echo "Updated $env_file for self-hosted Convex"
    '';
  };

  scripts.setup.exec = ''
    set -euo pipefail
    npm install
    flutter pub get
  '';

  scripts.check.exec = ''
    set -euo pipefail
    flutter analyze
    flutter test
  '';

  scripts.codegen.exec = ''
    set -euo pipefail
    export PATH="$DEVENV_ROOT/node_modules/.bin:$PATH"
    dart run dartvex_codegen generate \
      --project "$DEVENV_ROOT" \
      --output "$DEVENV_ROOT/lib/convex_api"
  '';

  scripts.flutter-run-local.exec = ''
    exec flutter run --dart-define=CONVEX_URL=http://127.0.0.1:3210 "$@"
  '';

  scripts.start-emulator.exec = ''
    export ANDROID_AVD_HOME="$PWD/.android/avd"
    exec emulator -avd pixel-6-pro-api-36 -gpu host
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
