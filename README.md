# VDom - Virtual DOM diff/patch

> Virtual DOM diff/patch implementation inspired by
> [ReactJS Reconciliation](http://facebook.github.io/react/docs/reconciliation.html).

## diff/patch API is deprecated in favour of new sync API

## Usage example

```dart
import 'package:vdom/vdom.dart' as v;

main() {
  final a = new v.Element('unique_key', 'div');
  final aHtmlElement = a.render();

  final b = new v.Element('unique_key', 'div', [new v.Text('text_key', 'Text Content')]);

  a.sync(b);
}
```