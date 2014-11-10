# VDom

Virtual DOM library for [Dart](https://www.dartlang.org/) inspired by
[ReactJS Reconciliation](http://facebook.github.io/react/docs/reconciliation.html).

## API

### `Context`

Context is an object that is used to pass specific details to the
subtree.

Default Context is a simple object with `isAttached` property.

In the Liquid library, `Component` class implements this interface,
and is used to establish ownership relationships.

### `Node`

#### `void create(Context context)`

Creates a root-level html node for this virtual Node. It is essential
to render Nodes in two steps, so we can propagate attached calls at
the same time as we render subtrees.

#### `void mount(Context context)`

Mount root-level node to the existing root-level html node. It doesn't
mount subtrees, just root-level node.

#### `void render(Context context)`

Render attributes, styles, classes, children, etc.

#### `void update(Node other, Context context)`

Update previous tree with the new one.

## Usage example

```dart
import 'package:vdom/vdom.dart' as v;

main() {
  final a = new v.Element(#uniqueKey, 'div', const []);
  a.create(const v.Context(false));
  document.body.append(a.ref);
  a.attach();
  a.render(const v.Context(true));

  final b = new v.Element(#uniqueKey, 'div',
      [new v.Text(#textKey, 'Text Content')]);

  a.update(b);
}
```
