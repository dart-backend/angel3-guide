# Templates and Views

The `Basic` template renders HTML pages with [Jael](../views/jael/about.md), a template engine built for Angel3. Its templates are in `views/`.

## Rendering a view

`res.render` renders a template of `views/`, and sends it as HTML. The template's home page route, in `lib/src/routes/routes.dart`, is:

```dart
app.get('/', (req, res) => res.render('hello'));
```

`'hello'` is `views/hello.jael`:

```html
<extend src="layout.jael">
    <block name="content">
        <div class="title">Angel</div>
    </block>
</extend>
```

It [extends](../views/jael/Directive-extend.md) `views/layout.jael`, which holds the page's `<html>`, `<head>` and stylesheet, and fills its `content` block. Every page of the app can share the layout this way.

## Passing data to a view

Pass a `Map` to `res.render`, and use its values in the template between `{{ }}`. Add this route to `routes.dart`, before the `app.fallback` calls:

```dart
app.get('/greet/:name', (req, res) {
  return res.render('greet', {
    'title': 'Greeting',
    'name': req.params['name'],
  });
});
```

and create `views/greet.jael`:

```html
<extend src="layout.jael">
    <block name="content">
        <div class="title">Hello, {{ name }}!</div>
    </block>
</extend>
```

Open <http://localhost:3000/greet/Bob>, and you'll see `Hello, Bob!`. The layout's `<title>` is `{{ title ?? 'Angel' }}`, so this page's title is `Greeting`.

`{{ }}` escapes HTML, so a value from the request cannot inject markup into the page. Use `{{- }}` only for HTML you trust.

Jael also has [conditionals](../views/jael/Directive-if.md), [loops](../views/jael/Directive-for-each.md), [includes](../views/jael/Directive-include.md) and [custom elements](../views/jael/Custom-Elements.md).

To pass an object of your own, rather than a `Map`, Jael reads its fields by name, which needs reflection: mark its class `@injectable`, and generate its reflection data, as [Running without `dart:mirrors`](../guides/running-without-mirrors.md) describes. Or pass `toJson()` of the object.

## Static files

The files of `web/`, such as `web/css/site.css`, are served at the root of the site, as `/css/site.css`, by a `CachingVirtualDirectory` of [`angel3_static`](https://github.com/dart-backend/angel/tree/master/packages/static). In production, it also sends caching headers.

## Error pages

When a request that accepts HTML fails, the template renders `views/error.jael` with the error's message. Other requests, such as those of an API, get the error as JSON.

## Other template engines

Jael is not the only choice. See [Server Side Rendered Views](../views/rendering-views.md) for Mustache, Jinja and Markdown, and [Full-stack with Kelicap](../views/kelicap.md) for a client-side web app.

## Next Up

Continue to [Configure ORM](configure-orm.md) to store data in a database.
