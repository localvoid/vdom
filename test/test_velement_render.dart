import 'dart:html';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:vdom/src/vdom.dart';

void main() {
  useHtmlEnhancedConfiguration();

  group('Basic', () {
    test('Create empty div', () {
      final frag = new DocumentFragment();
      final n = new VElement('div', 'key');
      frag.append(n.render());
      expect(frag.innerHtml, equals('<div></div>'));
    });

    test('Create empty span', () {
      final frag = new DocumentFragment();
      final n = new VElement('span', 'key');
      frag.append(n.render());
      expect(frag.innerHtml, equals('<span></span>'));
    });
  });

  group('Attributes', () {
    test('Create div with 1 attribute', () {
      final frag = new DocumentFragment();
      final n = new VElement('div', 'key');
      n.attributes = {
        'id': 'test-id'
      };
      frag.append(n.render());
      expect(frag.innerHtml, equals('<div id="test-id"></div>'));
    });

    test('Create div with 2 attributes', () {
      final frag = new DocumentFragment();
      final n = new VElement('div', 'key');
      n.attributes = {
        'id': 'test-id',
        'data-test': 'test-data'
      };
      frag.append(n.render());
      expect(frag.innerHtml, equals('<div id="test-id" data-test="test-data"></div>'));
    });
  });

  group('Styles', () {
    test('Create div with 1 style', () {
      final frag = new DocumentFragment();
      final n = new VElement('div', 'key');
      n.styles = {
        'top': '10px'
      };
      frag.append(n.render());
      expect(frag.innerHtml, equals('<div style="top: 10px;"></div>'));
    });

    test('Create div with 2 styles', () {
      final frag = new DocumentFragment();
      final n = new VElement('div', 'key');
      n.styles = {
        'top': '10px',
        'left': '20px'
      };
      frag.append(n.render());
      expect(frag.innerHtml, equals('<div style="top: 10px; left: 20px;"></div>'));
    });
  });

  group('Classes', () {
    test('Create div with 1 class', () {
      final frag = new DocumentFragment();
      final n = new VElement('div', 'key');
      n.classes = ['button'];
      frag.append(n.render());
      expect(frag.innerHtml, equals('<div class="button"></div>'));
    });

    test('Create div with 2 classes', () {
      final frag = new DocumentFragment();
      final n = new VElement('div', 'key');
      n.classes = ['button', 'button.important'];
      frag.append(n.render());
      expect(frag.innerHtml, equals('<div class="button button.important"></div>'));
    });
  });

  group('Children', () {
    test('Create div with 1 child', () {
      final frag = new DocumentFragment();
      final n = new VElement('div', 'key');
      n.children = [new VElement('span', '0')];
      frag.append(n.render());
      expect(frag.innerHtml, equals('<div><span></span></div>'));
    });

    test('Create div with 2 children', () {
      final frag = new DocumentFragment();
      final n = new VElement('div', 'key');
      n.children = [new VElement('span', '0'), new VElement('span', '1')];
      frag.append(n.render());
      expect(frag.innerHtml, equals('<div><span></span><span></span></div>'));
    });
  });
}