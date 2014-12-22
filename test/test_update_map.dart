import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:vdom/src/utils/map.dart';

void main() {
  useHtmlEnhancedConfiguration();

  group('Update Map', () {
    group('No modifications', () {
      test('null => null', () {
        final a = null;
        final b = null;
        final c = {0: 0};
        updateMap(a, b, c);
        expect(c, equals({0: 0}));
      });

      test('null => {}', () {
        final a = null;
        final b = {};
        final c = {0: 0};
        updateMap(a, b, c);
        expect(c, equals({0: 0}));
      });

      test('{} => null', () {
        final a = {};
        final b = null;
        final c = {0: 0};
        updateMap(a, b, c);
        expect(c, equals({0: 0}));
      });

      test('{} => {}', () {
        final a = {};
        final b = {};
        final c = {0: 0};
        updateMap(a, b, c);
        expect(c, equals({0: 0}));
      });
    });

    group('Basic inserts', () {
      test('null => {1: 1}', () {
        final a = null;
        final b = {1: 1};
        final c = {0: 0};
        updateMap(a, b, c);
        expect(c, equals({0: 0, 1: 1}));
      });

      test('{} => {1: 1}', () {
        final a = {};
        final b = {1: 1};
        final c = {0: 0};
        updateMap(a, b, c);
        expect(c, equals({0: 0, 1: 1}));
      });

      test('{} => {1: 1, 2: 2}', () {
        final a = {};
        final b = {1: 1, 2: 2};
        final c = {0: 0};
        updateMap(a, b, c);
        expect(c, equals({0: 0, 1: 1, 2: 2}));
      });

      test('{} => {1: 1, 2: 2, 3: 3}', () {
        final a = {};
        final b = {1: 1, 2: 2, 3: 3};
        final c = {0: 0};
        updateMap(a, b, c);
        expect(c, equals({0: 0, 1: 1, 2: 2, 3: 3}));
      });
    });

    group('Basic removes', () {
      test('{1: 1} => null', () {
        final a = {1: 1};
        final b = null;
        final c = {0: 0, 1: 1};
        updateMap(a, b, c);
        expect(c, equals({0: 0}));
      });

      test('{1: 1} => {}', () {
        final a = {1: 1};
        final b = {};
        final c = {0: 0, 1: 1};
        updateMap(a, b, c);
        expect(c, equals({0: 0}));
      });

      test('{1: 1, 2: 2} => {}', () {
        final a = {1: 1, 2: 2};
        final b = {};
        final c = {0: 0, 1: 1, 2: 2};
        updateMap(a, b, c);
        expect(c, equals({0: 0}));
      });
    });

    group('Inserts and Removes', () {
      test('{1: 1} => {5: 5}', () {
        final a = {1: 1};
        final b = {5: 5};
        final c = {0: 0, 1: 1};
        updateMap(a, b, c);
        expect(c, equals({0: 0, 5: 5}));
      });

      test('{1: 1, 2: 2} => {5: 5, 6: 6}', () {
        final a = {1: 1, 2: 2};
        final b = {5: 5, 6: 6};
        final c = {0: 0, 1: 1, 2: 2};
        updateMap(a, b, c);
        expect(c, equals({0: 0, 5: 5, 6: 6}));
      });
    });

    group('Updates', () {
      test('{1: 1} => {1: 10}', () {
        final a = {1: 1};
        final b = {1: 10};
        final c = {0: 0, 1: 1};
        updateMap(a, b, c);
        expect(c, equals({0: 0, 1: 10}));
      });

      test('{1: 1, 2: 2} => {1: 10, 2: 20}', () {
        final a = {1: 1, 2: 2};
        final b = {1: 10, 2: 20};
        final c = {0: 0, 1: 1, 2: 2};
        updateMap(a, b, c);
        expect(c, equals({0: 0, 1: 10, 2: 20}));
      });
    });
  });
}
