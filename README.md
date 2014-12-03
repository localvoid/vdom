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

Two-step rendering is also solves problem when you need to stop at any
point in `render()` to wait for async operations. When we create
root-level html node, we can just place it as a placeholder in the DOM
and wait for any async operation to finish.

#### `void render(Context context)`

Render attributes, styles, classes, children, etc. "Second step" in ours
two-step rendering model.

#### `void update(Node other, Context context)`

Apply changes to the DOM and transfer state from the previous virtual
tree to the new one.

## Usage example

```dart
import 'dart:html';
import 'dart:async';
import 'package:vdom/vdom.dart' as v;

int count = 0;
v.Element root;

void increment(){
  count += 1;
  rerender();
}

void rerender() {
  var next = render();
  root.update(next, const v.Context(true));
  root = next;
}

v.Element render(){
  return new v.Element('div')(count.toString());
}

void main() {
   root = render();
   root.create(const v.Context(false));
   root.init();
   document.body.append(root.ref);
   root.attached();
   root.render(const v.Context(true));
   new Timer.periodic(const Duration(seconds: 1), (t){ increment(); });
}
```
