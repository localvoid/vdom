import 'dart:html' as html;
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:vdom/vdom.dart' as v;

void main() {
  useHtmlEnhancedConfiguration();

  group('Update Style', () {
    group('No modifications', () {
      test('null => null', () {
        final a = null;
        final b = null;
        final c = new html.DivElement().style..zIndex = '10';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
      });

     test('null => {}', () {
        final a = null;
        final b = {};
        final c = new html.DivElement().style..zIndex = '10';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
      });

     test('{} => {}', () {
        final a = {};
        final b = {};
        final c = new html.DivElement().style..zIndex = '10';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
      });

     test('{} => null', () {
        final a = {};
        final b = null;
        final c = new html.DivElement().style..zIndex = '10';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
      });
    });

    group('Basic inserts', () {
      test('null => {top: 10px}', () {
        final a = null;
        final b = {'top': '10px'};
        final c = new html.DivElement().style..zIndex = '10';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
        expect(c.top, equals('10px'));
      });

      test('{} => {top: 10px}', () {
        final a = null;
        final b = {'top': '10px'};
        final c = new html.DivElement().style..zIndex = '10';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
        expect(c.top, equals('10px'));
      });

      test('{} => {top: 10px, left: 10px}', () {
        final a = null;
        final b = {'top': '10px', 'left': '10px'};
        final c = new html.DivElement().style..zIndex = '10';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
        expect(c.top, equals('10px'));
        expect(c.left, equals('10px'));
      });
    });

    group('Basic removes', () {
      test('{top: 10px} => null', () {
        final a = {'top': '10px'};
        final b = null;
        final c = new html.DivElement().style
          ..zIndex = '10'
          ..top = '10px';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
        expect(c.top, equals(''));
      });

      test('{top: 10px} => {}', () {
        final a = {'top': '10px'};
        final b = {};
        final c = new html.DivElement().style
          ..zIndex = '10'
          ..top = '10px';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
        expect(c.top, equals(''));
      });

      test('{top: 10px, left: 10px} => {}', () {
        final a = {'top': '10px', 'left': '10px'};
        final b = {};
        final c = new html.DivElement().style
          ..zIndex = '10'
          ..top = '10px'
          ..left = '10px';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
        expect(c.top, equals(''));
        expect(c.left, equals(''));
      });
    });

    group('Inserts and Removes', () {
      test('{top: 10px} => {bottom: 10px}', () {
        final a = {'top': '10px'};
        final b = {'bottom': '10px'};
        final c = new html.DivElement().style
          ..zIndex = '10'
          ..top = '10px';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
        expect(c.top, equals(''));
        expect(c.bottom, equals('10px'));
      });

      test('{top: 10px, left: 10px} => {bottom: 10px: right: 10px}', () {
        final a = {'top': '10px', 'left': '10px'};
        final b = {'bottom': '10px', 'right': '10px'};
        final c = new html.DivElement().style
          ..zIndex = '10'
          ..top = '10px'
          ..left = '10px';
        v.updateStyle(a, b, c);
        expect(c.zIndex, equals('10'));
        expect(c.top, equals(''));
        expect(c.left, equals(''));
        expect(c.bottom, equals('10px'));
        expect(c.right, equals('10px'));
      });
    });
  });
}
