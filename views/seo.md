# SEO

[`angel3_seo`](https://github.com/dart-backend/angel/tree/master/packages/seo) inlines the stylesheets and scripts of HTML pages into the pages themselves, so the browser can show a page without further requests. Pages load faster, which search engines reward.

```yaml
dependencies:
  angel3_seo: ^10.0.0
```

## Inlining rendered pages

`inlineAssets` is a [response finalizer](../guides/request-lifecycle.md) that patches any `text/html` response, including those of a template engine such as Jael. The `link` and `script` elements that point to files of the given directory are replaced with the contents of those files:

```dart
import 'package:angel3_framework/angel3_framework.dart';
import 'package:angel3_seo/angel3_seo.dart';
import 'package:file/local.dart';

Future configureServer(Angel app) async {
  var fs = const LocalFileSystem();
  app.responseFinalizers.add(inlineAssets(fs.directory('web')));
}
```

Only internal resources are inlined: URIs without a scheme or host, such as `/site.css` or `foo/bar.js`, of a file in the directory. A path out of it (`../secret`) is never inlined.

## Inlining static pages

`inlineAssetsFromVirtualDirectory` wraps a `VirtualDirectory` of `angel3_static`, so it inlines the `.html` and `.htm` files it serves. The caching of a `CachingVirtualDirectory` still applies to them:

```dart
var vDir = inlineAssetsFromVirtualDirectory(
  CachingVirtualDirectory(app, fs, source: fs.directory('web')),
);

app.fallback(vDir.handleRequest);
```

## What is inlined

* A stylesheet keeps its `media`.
* A script that is `async`, or `defer` but not a module, stays external, as an inline script runs at once.
* An element marked `data-no-inline`, or without a valid `href` or `src`, is left as it is:

  ```html
  <script src="main.dart.js" data-no-inline></script>
  ```

The page is sent as UTF-8.
