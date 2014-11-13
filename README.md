# VDom

Virtual DOM library for [Dart](https://www.dartlang.org/) inspired by
[ReactJS Reconciliation](http://facebook.github.io/react/docs/reconciliation.html).

Virtual DOM solves the problem of moving state from previous tree to
the new one, so that you can always render DOM in a simple way like it
doesn't have any previous state, and the algorithm behind it will do
all the hard work and move state from the previous tree to the new
one.

As I see it, it is the most important idea behind the Virtual DOM. It
is not the performance optimization to generate as little as possible
DOM operations, or something else, it is a simple idea of moving
state.

Many people told me that Virtual DOM is not as important as
Components, but I am not looking at Components as it is something
special, there are many different ways to implement Components, I
treat them like any other state.

For example, all `Node`'s in virtual dom have simple state that is
just reference to their real html node. And Components is just another
Node that will render/update its subtree in a lazy way, nothing
special about it. Some features like TransitionGroup's can be
implemented in a different ways, for example we can extend virtual
Element and add additional state that will track all necessary
information for transitions, and it won't be a "Component", it will be
the same element with additional state and behavior.

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

#### `void mount(html.Node node, Context context)`

Mount root-level node to the existing root-level html node. It doesn't
mount subtrees, just root-level node. It is used in Components as a
micro-optimization.

#### `void render(Context context)`

Render attributes, styles, classes, children, etc. "Second step" in ours
two-step rendering model.

#### `void update(Node other, Context context)`

Update previous node with the new one.

## Usage example

```dart
import 'package:vdom/vdom.dart' as v;

main() {
  final a = new v.Element(#uniqueKey, 'div', const []);
  a.create(const v.Context(false));
  document.body.append(a.ref);
  a.attached();
  a.render(const v.Context(true));

  final b = new v.Element(#uniqueKey, 'div',
      [new v.Text(#textKey, 'Text Content')]);

  a.update(b);
}
```
