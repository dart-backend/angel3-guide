# Commands

Run these from the root of your project. To install the CLI, see [Setup](cli-setup.md).

| Command | Description |
| --- | --- |
| `angel3 init [<folder>]` | Creates a project from a [starter template](../tutorial/application-setup.md) |
| `angel3 make controller` | Generates a controller class (`-w` for a WebSocket controller) |
| `angel3 make service` | Generates a service |
| `angel3 make model` | Generates a model class, serializable and with a migration by default (`--no-serializable`, `--no-migration`), and with ORM code with `--orm` |
| `angel3 make migration` | Generates a migration class |
| `angel3 make plugin` | Generates a plug-in |
| `angel3 make test` | Generates a test |
| `angel3 deploy nginx` | Generates an NGINX configuration for a reverse proxy and static server |
| `angel3 deploy systemd` | Generates a systemd service that keeps your server running |
| `angel3 key` | Generates new JWT secrets in `config/default.yaml` and `config/production.yaml` |
| `angel3 doctor` | Checks that your system has what Angel3 needs |

For the options of a command:

```bash
angel3 help
angel3 help make model
```

## `angel3 init`

`angel3 init` asks for a template, then:

1. downloads the templates from the [boilerplates](https://github.com/dart-backend/boilerplates) repository, and caches them in `~/.angel3/boilerplates` for a day
2. copies the chosen template into the folder, and names the package after it
3. generates new JWT secrets in `config/default.yaml` and `config/production.yaml`
4. runs `dart pub get`, and `dart run build_runner build` for the templates that need code generation

| Option | Description |
| --- | --- |
| `-n`, `--project-name` | The name of the project, instead of the folder's |
| `--refresh` | Download the latest templates, even if the cached ones are recent |
| `--offline` | Use the cached templates only, and skip `dart pub get` |
| `--no-pub-get` | Skip `dart pub get` and code generation |

If the download fails, `angel3 init` uses the cached templates when there are any.

## Deployment helpers

`angel3 deploy` writes its configuration to the standard output, or to a file with `-o`:

```bash
angel3 deploy nginx -o my_app.conf
angel3 deploy systemd -o my_app.service
```

Review the generated files, then install them, as [Deploying under nginx](../deployment/ubuntu-and-nginx.md) describes.
