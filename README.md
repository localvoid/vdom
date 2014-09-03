# VDom - Virtual DOM diff/patch

> Virtual DOM diff/patch implementation inspired by
> [ReactJS Reconciliation](http://facebook.github.io/react/docs/reconciliation.html).

## Usage example

```dart
import 'package:vdom/vdom.dart';

main() {
  final a = new VElement('unique_key', 'div');
  final aHtmlElement = a.render();

  final b = new VElement('unique_key', 'div');
  b.children = [new VText('text_key', 'Text Content')];

  final patch = a.diff(b);

  patch.apply(aHtmlElement);
}
```