# 0.7.0

- Changed interface of the `Element` constructor, children argument is
  now named argument.
- Added `ElementContainerBase call(List<Node> children)` method to the
  `ElementContainerBase`. Didn't notice any performance regressions in
  the VDom Benchmark. API is much better this way:

```dart
v.div(#root, styles: {'top': '10px'})([
  v.div(1)('one'),
  v.div(2)('two')
]);
```
