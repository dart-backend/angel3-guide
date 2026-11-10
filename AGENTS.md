# AGENTS.md — Angel3 Guide

Guidance for AI coding agents working in this repository.

## What this repo is

The user guide for [Angel3](https://github.com/dart-backend/angel), a Dart backend framework. It covers Angel3 10.0.0, which requires Dart SDK 3.13 or later. The guide is published with GitBook at <https://angel3-docs.dukefirehawk.com>, through GitBook's Git Sync with this repository.

There is no build step and no Dart package here: every page is a Markdown file. The framework source is in the `dart-backend/angel` repository. Check API names, constructors and package versions against that source, or against the released packages on pub.dev (also in the local pub cache, such as `~/.pub-cache/hosted/pub.dev/angel3_orm-10.0.1`), never from memory or from older Angel versions.

## Layout

```text
README.md          Landing page of the GitBook site
SUMMARY.md         GitBook sidebar: every published page is listed here
.gitbook.yaml      GitBook config: the root, the landing page and the sidebar file
foreword.md        Foreword
tutorial/          Step-by-step tutorial, from getting started to deployment
cli/               The angel3 command line tool
views/             Server-side rendering: Jael (views/jael/), Jinja, SEO, Kelicap
auth/              Authentication and strategies
orm/               ORM: basics, relations, migrations, PostgreSQL, MySQL and MariaDB, NoSQL, Sembast
guides/            "Under the hood": routing, requests, DI, middleware, controllers, services, testing...
deployment/        Production mode, isolates, Podman, SSL, nginx, App Engine
migration/         Migration guides between major versions
assets/            Images, such as assets/branding/
CHANGELOG.md       Changes to the guide, by guide version
```

`guides/README.md` and `auth/side-bar.md` are old navigation lists that are not published. Don't link to them; use `SUMMARY.md` for navigation.

## GitBook

- **`SUMMARY.md` is the sidebar.** A page that isn't listed in it is not published. When you add, rename, move or delete a page, update `SUMMARY.md` in the same change. Keep its existing format: a `# Menu` title, `*` items indented by two spaces, group items without a link (such as `* Tutorial`), and external links for the package list. Each file is listed once.
- **Sync goes both ways.** Edits made in GitBook's editor become commits on the synced branch, so pull before you edit, and don't rewrite history on that branch.
- **Write plain Markdown.** Pages are read both on GitBook and on GitHub. Don't use GitBook-only blocks (`{% hint %}`, `{% tabs %}`, `{% embed %}`) or GitHub-only callouts (`> [!NOTE]`). For a note, use a plain blockquote or a sentence starting with **Note:**.
- **Links between pages are relative links to the `.md` file**, such as `[Controllers](../guides/controllers.md)` or `[Hooks](hooks.md#hooks)`. GitBook turns them into site URLs. Use a full URL only for other sites.

## Content conventions

- **Name:** "Angel3" for the framework. Mention "Angel" or "Angel 2" only for history and in the migration guides.
- **Packages:** The packages are named `angel3_*`, such as `package:angel3_framework/angel3_framework.dart` and `package:angel3_orm/angel3_orm.dart`. Dependency snippets use the current major version, `^10.0.0`, with the versions of other packages (such as `mysql_dart: ^3.0.3`) that the Angel3 10 packages depend on.
- **Code samples** are valid Dart 3: null safe, and using the current API. Every code block names its language: `dart`, `yaml`, `bash`, `html`, `sql`, `dockerfile`. For samples that need reflection, show the reflector: `MirrorsReflector` of `angel3_container_mirrors`, or a generated `StaticReflector` (see `guides/running-without-mirrors.md`).
- **Databases:** PostgreSQL 16 or later (`angel3_orm_postgres`), MySQL 8 or later and MariaDB 10.2 or later (`angel3_orm_mysql`). Keep `orm/postgresql.md` and `orm/mysql.md` consistent with each other.
- **Examples:** Runnable example projects live in [`belatuk-examples`](https://github.com/dart-backend/belatuk-examples), and project templates in [`boilerplates`](https://github.com/dart-backend/boilerplates). Link to them rather than copying whole projects into a page.
- **Images** go in `assets/`, and are referenced with relative paths.
- **Tone:** second person or "we", present tense. Each page starts with a single `# Title` heading.

## Checking your changes

There's no build or CI. Before finishing:

- Check that every relative link and image path you added or changed points to a file that exists.
- Check that `SUMMARY.md` lists every page under the content folders exactly once, and that each listed file exists.
- Search for merge conflict markers, which GitBook publishes as text: `grep -rnE '^(<<<<<<<|=======|>>>>>>>)( |$)' --include=*.md .`. When you merge branches, also read the merged pages: git can combine both sides' lines outside the markers into code that no longer makes sense.
- Check new or changed code against the released `angel3_*` packages.

## Git

- Work on a topic branch, such as `feature/<name>` or `fix-bug/<name>`, and merge it into `master` with a pull request.
- Commit messages use a conventional prefix: `docs:`, `fix:` or `refactor:`, such as `docs: add the MySQL guide to the sidebar`.
- Record user-facing changes in `CHANGELOG.md`, under the guide version they belong to, written as plain statements about the guide.
