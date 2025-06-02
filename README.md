<!--

********************************************************************************

WARNING:

    DO NOT EDIT "amplify-json/README.md"

    IT IS AUTO-GENERATED

    (based on Dockerfile, usage example, and entrypoint logic)

********************************************************************************

-->

# Quick reference

- **Maintained by**:  
  [Douglas Cabrera](https://github.com/cabreraevil)

- **Where to get help**:  
  [GitHub Issues](https://github.com/cabreraevil/amplify-json/issues)

# Supported tags and respective `Dockerfile` links

- [`latest`](https://github.com/cabreraevil/amplify-json/blob/main/Dockerfile)

# What is amplify-json?

**amplify-json** is a containerized tool that fetches metadata from AWS Amplify apps and branches, transforms it into structured JSON, and serves it via a lightweight HTTP server. It is designed to be used in observability dashboards, CI pipelines, or other automation processes that require visibility into Amplify deployments.

> The project uses `awscli`, `jq`, `cron`, and `serve` to produce and expose machine-readable deployment data.

# How to use this image

## docker exec usage (standalone)

```bash
docker volume create -d local amplify-json-data && \
docker run --name amplify-json --restart unless-stopped -p 80:80 --env-file .env -v ~/.aws:/root/.aws:ro -v amplify-json-data:/app/public:rw cabreraevil/amplify-json:latest
```

## docker-compose usage

```yaml
services:
  amplify-json:
    image: cabreraevil/amplify-json:latest
    container_name: amplify-json
    restart: unless-stopped
    ports:
      - 80:80
    env_file:
      - .env
    volumes:
      - ~/.aws:/root/.aws:ro
      - amplify-json-data:/app/public:rw

volumes:
  amplify-json-data:
    driver: local
    name: amplify-json-data
```

## Environment variables

| Variable          | Description                                            | Default        |
| ----------------- | ------------------------------------------------------ | -------------- |
| `AWS_REGION`      | AWS region where Amplify apps are deployed             | `ca-central-1` |
| `AWS_PROFILE`     | AWS CLI profile to use                                 | `default`      |
| `PORT`            | Port to expose via `serve`                             | `80`           |
| `INTERVAL`        | Interval (in minutes) to regenerate JSON               | `5`            |
| `CRON_EXPRESSION` | Optional custom cron expression (overrides `INTERVAL`) | _(unset)_      |
| `DEBUG`           | Enables verbose entrypoint logging if set to `true`    | `false`        |

## Access the generated files

Once the container is running, you can access:

- `http://localhost:80/input.json` – raw `amplify list` output
- `http://localhost:80/output.json` – formatted domain and branch metadata

# Quick reference (cont.)

- **Where to file issues**:
  [https://github.com/cabreraevil/amplify-json/issues](https://github.com/cabreraevil/amplify-json/issues)

- **Supported architectures**:
  `linux/amd64`, `linux/arm64`

- **Published image details**:
  [Docker Hub: cabreraevil/amplify-json](https://hub.docker.com/r/cabreraevil/amplify-json)

- **Source of this description**:
  [docs repo’s `amplify-json/` directory](https://github.com/cabreraevil/amplify-json)

# Behavior & Scheduling

This image uses a shell-based entrypoint to:

- Run `amplify-generate && amplify-process` once at startup
- Schedule future runs using a cron job

```cron
*/5 * * * * root amplify-generate && amplify-process >> /var/log/amplify-json.log
```

You can customize the cron job via:

- `INTERVAL=10` → `*/10 * * * *`
- `CRON_EXPRESSION="0 * * * *"` → runs at the top of every hour

> Logs are stored in `/var/log/amplify-json.log`.
> Cron jobs are written to `/etc/cron.d/amplify`.

To view the logs:

```bash
docker exec -it amplify-json tail -f /var/log/amplify-json.log
```

# Image variants

Only `latest` is currently published. It is based on:

- `node:jod-bookworm-slim`
- Includes: `jq`, `curl`, `cron`, `awscli v2`, `serve`

This is a **slim yet complete** image suitable for both development and production usage.

# License

This project is released under the [MIT License](https://github.com/cabreraevil/amplify-json/blob/main/LICENSE).
Included tools like AWS CLI and `jq` are subject to their respective licenses.

As with all container images, it is the user's responsibility to ensure that use complies with all relevant licenses.
