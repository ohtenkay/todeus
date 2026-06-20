{ pkgs, lib, ... }:

{
  android = {
    enable = true;
    flutter.enable = true;
  };

  languages.dart.enable = true;

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
