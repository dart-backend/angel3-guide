# Running in a Container with Podman

Each [starter template](../tutorial/application-setup.md) includes a `Containerfile`, which runs the app in a rootless container with [Podman](https://podman.io/), and a Compose file in `contrib/deployment/`.

## The image

The `Containerfile` compiles the server into a native executable, and copies it into a `scratch` image, with only the Dart runtime's libraries and the files the server reads:

```dockerfile
# Compile with the Dart SDK.
FROM docker.io/library/dart:stable AS build

WORKDIR /app
COPY pubspec.* ./
RUN dart pub get

COPY . .
RUN dart pub get --offline
RUN dart compile exe bin/prod.dart -o bin/server

# Run with only what the server needs.
FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /app/bin/server /app/bin/server
COPY --from=build /app/config /app/config
COPY --from=build /app/views /app/views
COPY --from=build /app/web /app/web

WORKDIR /app
ENV ANGEL_ENV=production
EXPOSE 3000
# Use -j to set the number of isolates, as -j 4.
CMD ["/app/bin/server", "-p", "3000", "-a", "0.0.0.0"]
```

The server is compiled with `dart compile exe`, so the app must run without `dart:mirrors`, as the templates do. See [Running without `dart:mirrors`](../guides/running-without-mirrors.md).

Build and run it:

```bash
podman build -t my_app .
podman run --rm -p 3000:3000 my_app
```

## Podman Compose

`contrib/deployment/compose.yaml` builds the same image, and runs it with a read-only root filesystem, no Linux capabilities and `no-new-privileges`. The templates with a database also start the database, and run the migrations before the server.

It needs [`podman-compose`](https://github.com/containers/podman-compose), or Docker Compose with the Podman socket enabled (`systemctl --user enable --now podman.socket`). From the project's root:

```bash
# Build the image and start the server in the background
podman-compose -f contrib/deployment/compose.yaml up --build -d

# Follow its logs
podman-compose -f contrib/deployment/compose.yaml logs -f

# Stop and remove the container
podman-compose -f contrib/deployment/compose.yaml down
```

Then open <http://localhost:3000>. To publish on another host port, set `APP_PORT`:

```bash
APP_PORT=8080 podman-compose -f contrib/deployment/compose.yaml up --build -d
```

## Notes

* **Secrets**: the image includes `config/`, so its `jwt_secret` values. `angel3 init` generates new ones for a new project, and `angel3 key` generates new ones for an existing project. Keep `config/production.yaml` out of public repositories.
* **Static files**: the files of `web/` are built into the image, so rebuild it (`up --build`) after changing them.
* **Network**: the Compose file publishes the port on `127.0.0.1` only. Change `ports` to `"3000:3000"` to expose it on every interface, or put a reverse proxy, such as [nginx](ubuntu-and-nginx.md), in front.
* **Databases on the host**: in a container, `localhost` is the container itself. For a database on the host machine, Podman names the host `host.containers.internal`. The PostgreSQL template reads it from the `POSTGRES_HOST` environment variable:

  ```bash
  podman run --rm -p 3000:3000 -e POSTGRES_HOST=host.containers.internal my_app
  ```
