import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:vdom/vdom.dart' as v;

void main() {
  useHtmlEnhancedConfiguration();

  group('Update Set', () {
    group('No modifications', () {
      test('null => null', () {
        final a = null;
        final b = null;
        final c = new Set.from([10]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10])));
      });

      test('null => []', () {
        final a = null;
        final b = [];
        final c = new Set.from([10]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10])));
      });

      test('[] => null', () {
        final a = [];
        final b = null;
        final c = new Set.from([10]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10])));
      });

      test('[] => []', () {
        final a = [];
        final b = [];
        final c = new Set.from([10]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10])));
      });
    });

    group('Basic inserts', () {
      test('null => [1]', () {
        final a = null;
        final b = [1];
        final c = new Set.from([10]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10, 1])));
      });

      test('[] => [1]', () {
        final a = [];
        final b = [1];
        final c = new Set.from([10]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10, 1])));
      });

      test('[] => [1, 2]', () {
        final a = [];
        final b = [1, 2];
        final c = new Set.from([10]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10, 1, 2])));
      });
    });

    group('Basic removes', () {
      test('[1] => null', () {
        final a = [1];
        final b = null;
        final c = new Set.from([10, 1]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10])));
      });

      test('[1] => []', () {
        final a = [1];
        final b = [];
        final c = new Set.from([10, 1]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10])));
      });

      test('[1, 2] => []', () {
        final a = [1, 2];
        final b = [];
        final c = new Set.from([10, 1, 2]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10])));
      });
    });

    group('Inserts and Removes', () {
      test('[1] => [20]', () {
        final a = [1];
        final b = [20];
        final c = new Set.from([10, 1]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10, 20])));
      });

      test('[1, 2] => [20, 21]', () {
        final a = [1, 2];
        final b = [20, 21];
        final c = new Set.from([10, 1, 2]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10, 20, 21])));
      });

      test('[1, 2, 3, 4, 5] => [20, 21, 22, 23, 24]', () {
        final a = [1, 2, 3, 4, 5];
        final b = [20, 21, 22, 23, 24];
        final c = new Set.from([10, 1, 2, 3, 4, 5]);
        v.updateSet(a, b, c);
        expect(c, equals(new Set.from([10, 20, 21, 22, 23, 24])));
      });
    });
  });
}