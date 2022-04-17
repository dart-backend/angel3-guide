# Angel3 CLI

The [Angel3 CLI](https://github.com/dukefirehawk/angel3-cli) is a friendly command line tool enabling quick scaffolding of common project
constructs.

To install it:

```bash
  pub global activate angel3_cli
```

You'll then be able to run:

```bash
  angel3 --help
```

The above will print documentation about each available command.

## Scaffolding

### New Projects

Bootstrapping a new Angel project, complete, CORS, hot-reloading, and more, is as easy as running:

```bash
    angel3 init <dirname>
```

You'll be ready to go after this!

### Project Files

Use `angel3 make` to scaffold common Dart files:

* `angel3 make service` - Generate an in-memory, MongoDB, RethinkDB, file-based, or other [service](service-basics.md).
* `angel3 make test`
* `angel3 make plugin`
* `angel3 make model`
* `angel3 make model --orm`
* `angel3 make controller`

### Deployment helpers

* `sudo -E angel3 deploy nginx -o /etc/sites-available/my_app.conf`
* `sudo -E angel3 deploy systemd -o /etc/systemd/system/my_app.service`

## Renaming the Project

To rename your project, and fix all references, run:

```bash
    angel3 rename <new-name>
```
