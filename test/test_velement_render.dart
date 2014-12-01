import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:vdom/vdom.dart' as v;

void main() {
  useHtmlEnhancedConfiguration();

  group('Basic', () {
    test('Create empty div', () {
      final frag = new DivElement();
      final n = new v.Element('div');
      v.inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div></div>'));
    });

    test('Create empty span', () {
      final frag = new DivElement();
      final n = new v.Element('span');
      v.inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<span></span>'));
    });
  });
  group('Attributes', () {
    test('Create div with 1 attribute', () {
      final frag = new DivElement();
      final n = new v.Element('div', attributes: {
        'id': 'test-id'
      });
      v.inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div id="test-id"></div>'));
    });

    test('Create div with 2 attributes', () {
      final frag = new DivElement();
      final n = new v.Element('div', attributes: {
        'id': 'test-id',
        'data-test': 'test-data'
      });
      v.inject(n, frag, const v.Context(false));
      expect(
          frag.innerHtml,
          equals('<div id="test-id" data-test="test-data"></div>'));
    });
  });

  group('Styles', () {
    test('Create div with 1 style', () {
      final frag = new DivElement();
      final n = new v.Element('div', styles: {
        'top': '10px'
      });
      v.inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div style="top: 10px;"></div>'));
    });

    test('Create div with 2 styles', () {
      final frag = new DivElement();
      final n = new v.Element('div', styles: {
        'top': '10px',
        'left': '20px'
      });
      v.inject(n, frag, const v.Context(false));
      expect(
          frag.innerHtml,
          equals('<div style="top: 10px; left: 20px;"></div>'));
    });
  });

  group('Classes', () {
    test('Create div with 1 class', () {
      final frag = new DivElement();
      final n = new v.Element('div', classes: ['button']);
      v.inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div class="button"></div>'));
    });

    test('Create div with 2 classes', () {
      final frag = new DivElement();
      final n =
          new v.Element('div', classes: ['button', 'button.important']);
      v.inject(n, frag, const v.Context(false));
      expect(
          frag.innerHtml,
          equals('<div class="button button.important"></div>'));
    });
  });

  group('Children', () {
    test('Create div with 1 child', () {
      final frag = new DivElement();
      final n = new v.Element('div')([new v.Element('span')]);
      v.inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div><span></span></div>'));
    });

    test('Create div with 2 children', () {
      final frag = new DivElement();
      final n =
          new v.Element('div')([
            new v.Element('span'),
            new v.Element('span')
          ]);
      v.inject(n, frag, const v.Context(false));
      expect(frag.innerHtml, equals('<div><span></span><span></span></div>'));
    });
  });
}
