# 0.8.2

- Improved performance in children diff algorithm with explicit keys.

# 0.8.1

- Added new Html Elements.

# 0.8.0

- Added runtime checking for implicit/explicit keys.
- Added new attribute "type" for Elements, it is rendered as an
  immutable class and used to detect similar elements when keys are
  implicit.
- Added basic Html elements.
- Added basic SVG elements.
- Reorganized class hierarchy.
- VContainer renamed to Container.

# 0.7.1

- Add support for Iterables in `call(children)` method.

# 0.7.0

- Changed interface of the `Element` constructor, `children` and `key`
  arguments are now named arguments.
- When `key` argument is `null`, it means that the key should be
  implicit.
- Added `ElementContainerBase call(List<Node> children)` method to the
  `ElementContainerBase`. Didn't notice any performance regressions in
  the VDom Benchmark. API is much better this way:

```dart
v.div(#root, styles: {'top': '10px'})([
  v.div(1)('one'),
  v.div(2)('two')
]);
```

- Removed `inject` methods from the API.
- Added named attribute `id` for Elements.
- Disallow mixing childrens with implicit and explicit keys inside of the
  `Container`.
- Changed lifecycle to support server-side rendering. New methods:
  `mount` and `init`.
- Added prefix 'V' to all Node classes.
