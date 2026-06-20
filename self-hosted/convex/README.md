# Self-Hosted Convex

This directory contains the local Convex backend and dashboard runtime. It is intentionally not wired into the Flutter app yet.

## Usage

Run these from inside `devenv shell`:

```sh
convex-up
convex-status
convex-admin-key
convex-logs
convex-down
```

The default local endpoints are:

- Backend: `http://127.0.0.1:3210`
- HTTP actions: `http://127.0.0.1:3211`
- Dashboard: `http://localhost:6791`

`convex-admin-key` generates an admin key for the dashboard or CLI once the backend is healthy.

## Configuration

The Compose file uses the official Convex self-hosted images and stores data in a Docker-managed volume named under the `todeus-convex` Compose project.

For local overrides, copy `.env.example` to `.env` in this directory and edit it. Keep `.env` out of git.

The Flutter app is not configured to use these endpoints yet. When integration starts, use the generated admin key with `CONVEX_SELF_HOSTED_URL` and `CONVEX_SELF_HOSTED_ADMIN_KEY` in the app/backend tooling environment.
