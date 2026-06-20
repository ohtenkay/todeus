# Todeus

This project is a proof of concept for a Flutter application with a self hosted Convex backend.
The goal is to be able to use streams the same way as with Firebase.

Also, this project is a learning opportunity for me to get familiar with devenv.sh

## Stack

- Flutter app in `lib/`
- Convex backend functions in `convex/`
- Self-hosted Convex runtime in `self-hosted/convex/`
- Dart Convex client via [`dartvex`](https://pub.dev/packages/dartvex)
- Local development shell via [`devenv`](https://devenv.sh/)

## Setup

Enter the development shell:

```sh
devenv shell
```

Install JavaScript dependencies for the Convex CLI:

```sh
npm install
```

Install Flutter dependencies:

```sh
flutter pub get
```

Or run the project setup script, which installs npm and Flutter dependencies:

```sh
setup
```

The Flutter app reads the Convex deployment URL from the Dart define `CONVEX_URL`:

```sh
--dart-define=CONVEX_URL=http://10.0.2.2:3210
```

If no value is provided, `lib/convex/client.dart` defaults to `http://10.0.2.2:3210` so plain `flutter run` works with the Android emulator.

Use different URLs depending on where the app runs:

- Android emulator: `http://10.0.2.2:3210` (default)
- Host desktop app or web browser: `http://127.0.0.1:3210`

The self-hosted Convex CLI/tooling variables stay on `127.0.0.1` because `npm run convex:dev` and Docker run on the host machine, not inside the Android emulator.

## Running Convex Locally

Start the local development processes:

```sh
devenv up
```

This starts the Docker Compose self-hosted Convex backend/dashboard, waits for the backend to become healthy, writes `.env.local` with a generated self-hosted admin key, runs `npm run convex:dev`, and runs Dartvex code generation in watch mode.

Stop the local development processes:

```sh
devenv processes down
```

If you need to inspect the underlying containers directly, use Docker Compose:

```sh
docker-compose \
  --project-name todeus-convex \
  --project-directory self-hosted/convex \
  -f self-hosted/convex/docker-compose.yml \
  ps
```

Tail raw Docker logs:

```sh
docker-compose \
  --project-name todeus-convex \
  --project-directory self-hosted/convex \
  -f self-hosted/convex/docker-compose.yml \
  logs -f
```

Default local endpoints:

- Backend: `http://127.0.0.1:3210`
- HTTP actions/site proxy: `http://127.0.0.1:3211`
- Dashboard: `http://localhost:6791`

For optional port/image overrides, copy `self-hosted/convex/.env.example` to `self-hosted/convex/.env` and edit it. Do not commit local `.env` files.

## Convex Development

Backend code lives in:

- `convex/schema.ts`: database schema
- `convex/todos.ts`: todo query and mutation functions
- `convex/_generated/`: Convex TypeScript generated files

On NixOS, do not choose Convex CLI's `Start without an account (run Convex locally)` option. That path downloads and runs a generic Linux `convex-local-backend` binary, which fails on NixOS with the `stub-ld` dynamic linker error. Use this repo's Docker-based self-hosted backend instead.

Recommended local workflow:

```sh
devenv up
```

`devenv up` starts two processes:

- `convex`: self-hosted Convex backend and dashboard via Docker Compose
- `convex-dev`: Convex CLI watcher, after `.env.local` has been generated
- `dart-codegen`: Dartvex code generator in watch mode, after Convex dev starts

The `convex:env` task runs between those processes. It generates a self-hosted admin key from the backend container and writes root `.env.local`.

Manual equivalent:

Start the self-hosted backend:

```sh
docker-compose \
  --project-name todeus-convex \
  --project-directory self-hosted/convex \
  -f self-hosted/convex/docker-compose.yml \
  up
```

Generate an admin key:

```sh
docker-compose \
  --project-name todeus-convex \
  --project-directory self-hosted/convex \
  -f self-hosted/convex/docker-compose.yml \
  exec backend ./generate_admin_key.sh
```

Add the self-hosted backend URL and admin key to `.env.local`:

```sh
CONVEX_SELF_HOSTED_URL=http://127.0.0.1:3210
CONVEX_SELF_HOSTED_ADMIN_KEY=<admin-key-from-convex-admin-key>
```

Keep the app client URL in `.env.local` too if you want a local reference for Flutter commands:

```sh
CONVEX_SITE_URL=http://127.0.0.1:3211
CONVEX_URL_HOST=http://127.0.0.1:3210
CONVEX_URL_ANDROID_EMULATOR=http://10.0.2.2:3210
```

Run the Convex dev process from the repo root after those variables are set:

```sh
npm run convex:dev
```

This watches `convex/`, pushes function/schema changes to the self-hosted backend, and updates `convex/_generated/` as needed.

Generate or inspect the Convex function spec:

```sh
npm run convex:function-spec
```

`devenv up` keeps Dart bindings up to date while you develop. The generated files are written to `lib/convex_api/`.

Run code generation once manually:

```sh
codegen
```

Current Dart integration:

- `lib/convex/client.dart`: shared Dartvex client, `CONVEX_URL` setup, and generated `ConvexApi` instance
- `lib/convex_api/`: generated Dartvex bindings; do not edit by hand

## Running The App

Android emulator with the default local Convex URL:

```sh
flutter run
```

Desktop with the host local Convex URL:

```sh
flutter-run-local
```

Desktop with an explicit Convex URL:

```sh
flutter run --dart-define=CONVEX_URL=http://127.0.0.1:3210
```

Start the configured Android emulator:

```sh
start-emulator
```

## Verification

Run static analysis:

```sh
flutter analyze
```

Run tests:

```sh
flutter test
```

Run both:

```sh
check
```

## Building

Build Android APK:

```sh
flutter build apk --dart-define=CONVEX_URL=<convex-backend-url>
```

Build Android App Bundle:

```sh
flutter build appbundle --dart-define=CONVEX_URL=<convex-backend-url>
```

Build Linux desktop:

```sh
flutter build linux --dart-define=CONVEX_URL=<convex-backend-url>
```

Build web:

```sh
flutter build web --dart-define=CONVEX_URL=<convex-backend-url>
```

Use a URL reachable from the target device. For example, Android emulator uses `http://10.0.2.2:3210` for a backend running on the host, while a physical device needs the host LAN address or a deployed Convex URL.

## Generated Files

Do not edit these manually:

- `convex/_generated/*`: generated by the Convex CLI
- `lib/convex_api/*`: generated by `dartvex_codegen`
- `pubspec.lock`: generated by `flutter pub get`
- `linux/flutter/generated_plugins.cmake` and `windows/flutter/generated_plugins.cmake`: generated by Flutter tooling

Regenerate them with:

```sh
devenv up
codegen
flutter pub get
```
