# Self-Hosted Convex

This directory contains the local Convex backend and dashboard runtime used by the Flutter app during local development.

## Usage

From the repository root, run:

```sh
devenv up
```

This starts the Docker Compose stack, waits for the backend to become healthy, generates a self-hosted admin key, writes root `.env.local`, runs the Convex CLI watcher, and runs Dartvex code generation in watch mode.

Stop it with:

```sh
devenv processes down
```

The default local endpoints are:

- Backend: `http://127.0.0.1:3210`
- HTTP actions: `http://127.0.0.1:3211`
- Dashboard: `http://localhost:6791`

If you need to debug the containers directly, use Docker Compose from the repository root:

```sh
docker-compose \
  --project-name todeus-convex \
  --project-directory self-hosted/convex \
  -f self-hosted/convex/docker-compose.yml \
  ps
```

Generate an admin key manually if needed:

```sh
docker-compose \
  --project-name todeus-convex \
  --project-directory self-hosted/convex \
  -f self-hosted/convex/docker-compose.yml \
  exec backend ./generate_admin_key.sh
```

## Configuration

The Compose file uses the official Convex self-hosted images and stores data in a Docker-managed volume named under the `todeus-convex` Compose project.

For local overrides, copy `.env.example` to `.env` in this directory and edit it. Keep `.env` out of git.

On NixOS, use this Docker setup instead of Convex CLI's built-in local backend. The built-in local backend downloads a generic dynamically linked Linux binary, which NixOS cannot run without additional linker patching.
