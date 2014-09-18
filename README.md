# VDom - Virtual DOM diff/patch

> Virtual DOM diff/patch implementation inspired by
> [ReactJS Reconciliation](http://facebook.github.io/react/docs/reconciliation.html).

## Usage example

```dart
import 'package:vdom/vdom.dart' as v;

main() {
  final a = new v.Element('unique_key', 'div');
  final aHtmlElement = a.render();

  final b = new v.Element('unique_key', 'div');
  b.children = [new v.Text('text_key', 'Text Content')];

  final patch = a.diff(b);

  patch.apply(aHtmlElement);
}
```