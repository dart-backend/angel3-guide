# Deploy to Production

## Before deploying

Check the `jwt_secret` in `config/default.yaml` and `config/production.yaml`: it signs the app's tokens. `angel3 init` generates new ones for a new project. If one is still `INSECURE_DEFAULT_SECRET`, as in a template cloned by hand, generate new ones with:

```bash
angel3 key
```

Keep the secrets out of public repositories, as anyone who knows one can sign tokens the app accepts.

Set `ANGEL_ENV=production` wherever the server runs. In [production mode](../deployment/production-mode.md), the app loads `config/production.yaml`, flattens its route tree and caches resolved routes, and its static files are sent with caching headers.

## Running the production server

```bash
ANGEL_ENV=production dart bin/prod.dart
```

`bin/prod.dart` runs the app with the `Runner` of [`angel3_production`](https://github.com/dart-backend/angel/tree/master/packages/production). Its options include:

| Option | Description |
| --- | --- |
| `-a`, `--address` | The address to listen on |
| `-p`, `--port` | The port to listen on |
| `-j`, `--concurrency` | The number of isolates to spawn |
| `--[no-]respawn` | Re-spawn crashed isolates, on by default |
| `--ssl`, `--http2` | Listen for HTTPS, or HTTP/2, with `--certificate-file` and `--key-file` |

`dart bin/prod.dart --help` lists all of them. See [Running in Isolates](../deployment/running-in-isolates.md).

## Compiling to a native executable

The templates run without `dart:mirrors`, so the server can be compiled into a native executable, which starts faster, and needs no Dart SDK to run:

```bash
dart compile exe bin/prod.dart -o server
ANGEL_ENV=production ./server -p 3000
```

Run it from the project directory, as the server reads `config/`, `views/` and `web/` from there. To deploy the executable, copy those directories with it.

If your app uses controllers with `@Expose`, or other features that need reflection, see [Running without `dart:mirrors`](../guides/running-without-mirrors.md).

## Running in a container

Each template has a `Containerfile`, which builds the native executable into a minimal image:

```bash
podman build -t hello .
podman run --rm -p 3000:3000 hello
```

See [Running in a Container with Podman](../deployment/podman.md), which also covers Podman Compose.

## Behind a reverse proxy

On a server of your own, run the app as an unprivileged user, keep it running with systemd, and put nginx in front of it, to terminate TLS and serve static files. The CLI generates both configurations:

```bash
angel3 deploy systemd -o hello.service
angel3 deploy nginx -o hello.conf
```

See [Deploying under nginx](../deployment/ubuntu-and-nginx.md) and [Configuring SSL](../deployment/configuring-ssl.md).

## Next Up

Congratulations, you've built and deployed an Angel3 application! Read the guides under "Under the hood" to learn more about each part of the framework.
