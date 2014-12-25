# VDom

Virtual DOM library for [Dart](https://www.dartlang.org/) inspired by
[ReactJS Reconciliation](http://facebook.github.io/react/docs/reconciliation.html).

This library is not intended for use by web-application developers, it
is a low-level library for high-level libraries like
[Liquid](http://github.com/localvoid/liquid/).

Virtual DOM libraries can be designed in many ways depending on the
problems it is trying to solve, the primary use case for this library
is performing updates to stateful trees.

In this library, Virtual DOM hierarchy does not represent one-to-one
real DOM hierarchy. Several Virtual DOM Nodes can refer to the same
real DOM node and have control over different properties.

There are no "onEvent" callback-style event listeners and they won't
be added in the future.

## API

### Context

Context is an object that is used to pass specific details to the
subtree.

Default Context is a simple object with `isAttached` property.

### Node

#### `void create(Context context)`

Creates a root-level html node for this virtual Node. It is essential
to render Nodes in two steps, so we can propagate attached calls at
the same time as we render subtrees.

Two-step rendering is also solves problem when you need to stop at any
point in `render()` to wait for async operations. When we create
root-level html node, we can just place it as a placeholder in the DOM
and wait for any async operation to finish.

#### `void render(Context context)`

Render attributes, styles, classes, children, etc. "Second step" in
two-step rendering model.

#### `void update(Node other, Context context)`

Apply changes to the DOM and transfer state from the previous virtual
tree to the new one.

## Usage example

```dart
import 'dart:html';
import 'dart:async';
import 'package:vdom/vdom.dart';

int count = 0;
VElement root;

void increment(){
  count += 1;
  rerender();
}

void rerender() {
  var next = render();
  root.update(next, const Context(true));
  root = next;
}

VHtmlGenericElement render() => new VHtmlGenericElement('div')(count.toString());

void main() {
   root = render();
   root.create(const Context(false));
   root.init();
   document.body.append(root.ref);
   root.attached();
   root.render(const Context(true));
   new Timer.periodic(const Duration(seconds: 1), (t){ increment(); });
}
```
