import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:vdom/vdom.dart' as v;

void inject(v.Node n, Node parent, v.Context context) {
  n.create(context);
  parent.append(n.ref);
  if (context.isAttached){
    n.attached();
  }
  n.render(context);
}

void main() {
  useHtmlEnhancedConfiguration();

  group('Basic', () {
    test('Create empty div', () {
      final frag = new DivElement();
      final n = new v.VElement('div');
      inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div></div>'));
    });

    test('Create empty span', () {
      final frag = new DivElement();
      final n = new v.VElement('span');
      inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<span></span>'));
    });
  });
  group('Attributes', () {
    test('Create div with 1 attribute', () {
      final frag = new DivElement();
      final n = new v.VElement('div', attributes: {
        'id': 'test-id'
      });
      inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div id="test-id"></div>'));
    });

    test('Create div with 2 attributes', () {
      final frag = new DivElement();
      final n = new v.VElement('div', attributes: {
        'id': 'test-id',
        'data-test': 'test-data'
      });
      inject(n, frag, const v.Context(false));
      expect(
          frag.innerHtml,
          equals('<div id="test-id" data-test="test-data"></div>'));
    });
  });

  group('Styles', () {
    test('Create div with 1 style', () {
      final frag = new DivElement();
      final n = new v.VElement('div', styles: {
        'top': '10px'
      });
      inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div style="top: 10px;"></div>'));
    });

    test('Create div with 2 styles', () {
      final frag = new DivElement();
      final n = new v.VElement('div', styles: {
        'top': '10px',
        'left': '20px'
      });
      inject(n, frag, const v.Context(false));
      expect(
          frag.innerHtml,
          equals('<div style="top: 10px; left: 20px;"></div>'));
    });
  });

  group('Classes', () {
    test('Create div with 1 class', () {
      final frag = new DivElement();
      final n = new v.VElement('div', classes: ['button']);
      inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div class="button"></div>'));
    });

    test('Create div with 2 classes', () {
      final frag = new DivElement();
      final n =
          new v.VElement('div', classes: ['button', 'button.important']);
      inject(n, frag, const v.Context(false));
      expect(
          frag.innerHtml,
          equals('<div class="button button.important"></div>'));
    });
  });

  group('Children', () {
    test('Create div with 1 child', () {
      final frag = new DivElement();
      final n = new v.VElement('div')([new v.VElement('span')]);
      inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div><span></span></div>'));
    });

    test('Create div with 2 children', () {
      final frag = new DivElement();
      final n =
          new v.VElement('div')([
            new v.VElement('span'),
            new v.VElement('span')
          ]);
      inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div><span></span><span></span></div>'));
    });
  });
}
