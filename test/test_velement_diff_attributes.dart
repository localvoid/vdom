import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:vdom/src/vdom.dart';

void main() {
  useHtmlEnhancedConfiguration();

  group('Insert', () {
    group('Into empty', () {
      final a = new VElement('0', 'div');

      test('1 attribute', () {
        final b = new VElement('0', 'div');
        b.attributes = {
          'attr10': 'value10'
        };

        final patch = a.diff(b);
        expect(patch, isNotNull);
        expect(patch.attributesPatch, isNotNull);
        expect(patch.attributesPatch.keys, equals(['attr10']));
        expect(patch.attributesPatch.values, equals(['value10']));
      });

      test('2 attributes', () {
        final b = new VElement('0', 'div');
        b.attributes = {
          'attr10': 'value10',
          'attr11': 'value11'
        };

        final patch = a.diff(b);
        expect(patch, isNotNull);
        expect(patch.attributesPatch, isNotNull);
        expect(patch.attributesPatch.keys, equals(['attr10', 'attr11']));
        expect(patch.attributesPatch.values, equals(['value10', 'value11']));
      });
    });

    group('Into element with 1 attribute', () {
      final a = new VElement('0', 'div');
      a.attributes = {
        'attr01': 'value01',
      };

      test('1 attribute', () {
        final b = new VElement('0', 'div');
        b.attributes = {
          'attr01': 'value01',
          'attr10': 'value10'
        };

        final patch = a.diff(b);
        expect(patch, isNotNull);
        expect(patch.attributesPatch, isNotNull);
        expect(patch.attributesPatch.keys, equals(['attr10']));
        expect(patch.attributesPatch.values, equals(['value10']));
      });

      test('2 attributes', () {
        final b = new VElement('0', 'div');
        b.attributes = {
          'attr01': 'value01',
          'attr10': 'value10',
          'attr11': 'value11'
        };

        final patch = a.diff(b);
        expect(patch, isNotNull);
        expect(patch.attributesPatch, isNotNull);
        expect(patch.attributesPatch.keys, equals(['attr10', 'attr11']));
        expect(patch.attributesPatch.values, equals(['value10', 'value11']));
      });
    });

    group('Into element with 2 attribute', () {
      final a = new VElement('0', 'div');
      a.attributes = {
        'attr01': 'value01',
        'attr02': 'value02'
      };

      test('1 attribute', () {
        final b = new VElement('0', 'div');
        b.attributes = {
          'attr01': 'value01',
          'attr02': 'value02',
          'attr10': 'value10'
        };

        final patch = a.diff(b);
        expect(patch, isNotNull);
        expect(patch.attributesPatch, isNotNull);
        expect(patch.attributesPatch.keys, equals(['attr10']));
        expect(patch.attributesPatch.values, equals(['value10']));
      });

      test('2 attributes', () {
        final b = new VElement('0', 'div');
        b.attributes = {
          'attr01': 'value01',
          'attr02': 'value02',
          'attr10': 'value10',
          'attr11': 'value11'
        };

        final patch = a.diff(b);
        expect(patch, isNotNull);
        expect(patch.attributesPatch, isNotNull);
        expect(patch.attributesPatch.keys, equals(['attr10', 'attr11']));
        expect(patch.attributesPatch.values, equals(['value10', 'value11']));
      });
    });
  });

  group('Remove', () {
    test('From element with 1 attribute', () {
      final a = new VElement('0', 'div');
      a.attributes = {
        'attr01': 'value01'
      };

      final b = new VElement('0', 'div');

      final patch = a.diff(b);
      expect(patch, isNotNull);
      expect(patch.attributesPatch, isNotNull);
      expect(patch.attributesPatch.keys, equals(['attr01']));
      expect(patch.attributesPatch.values, equals([null]));
    });

    group('From element with 2 attributes', () {
      final a = new VElement('0', 'div');
      a.attributes = {
        'attr01': 'value01',
        'attr02': 'value02'
      };

      test('1 attribute', () {
        final b = new VElement('0', 'div');
        b.attributes = {
          'attr02': 'value02'
        };

        final patch = a.diff(b);
        expect(patch, isNotNull);
        expect(patch.attributesPatch, isNotNull);
        expect(patch.attributesPatch.keys, equals(['attr01']));
        expect(patch.attributesPatch.values, equals([null]));
      });

      test('2 attributes', () {
        final b = new VElement('0', 'div');

        final patch = a.diff(b);
        expect(patch, isNotNull);
        expect(patch.attributesPatch, isNotNull);
        expect(patch.attributesPatch.keys, equals(['attr01', 'attr02']));
        expect(patch.attributesPatch.values, equals([null, null]));
      });
    });
  });
}
