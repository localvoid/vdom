import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:vdom/src/vdom.dart' as v;

v.Element e(int key, [List<v.Node> children = const []]) {
  return new v.Element(key.toString(), 'div', children);
}

v.Text t(int key) {
  return new v.Text('text_' + key.toString(), key.toString());
}


/// Generate list of VElements from simple integers.
///
/// For example, list `[0, 1, [2, [0, 1, 2]], 3]` will create
/// list with 4 VElements and the 2nd element will have key `2` and 3 childrens
/// of its own.
List<v.Element> gen(List items) {
  final result = [];
  for (var i in items) {
    if (i is List) {
      result.add(e(i[0], gen(i[1])));
    } else {
      result.add(e(i, [t(i)]));
    }
  }
  return result;
}

void checkInnerHtml(v.Element a, v.Element b, v.ElementPatch p) {
  final aHtmlNode = a.render();
  final bHtmlNode = b.render();

  p.apply(aHtmlNode);

  final aHtml = aHtmlNode.innerHtml;
  final bHtml = bHtmlNode.innerHtml;

  if (aHtml != bHtml) {
    throw new TestFailure('Expected: "$bHtml" Actual: "$aHtml"');
  }
}

void main() {
  useHtmlEnhancedConfiguration();

  group('No modifications', () {
    test('No childrens', () {
      final a = e(0);
      final b = e(1);
      final patch = a.diff(b);
      expect(patch, isNull);
    });

    test('Same child', () {
      final a = e(0, gen([0]));
      final b = e(1, gen([0]));
      final patch = a.diff(b);
      expect(patch, isNull);
    });

    test('Same children', () {
      final a = e(0, gen([0, 1, 2]));
      final b = e(1, gen([0, 1, 2]));
      final patch = a.diff(b);
      expect(patch, isNull);
    });
  });

  group('Basic inserts', () {
    group('Into empty list', () {
      final a = e(0, []);

      final tests = [{
          'name': 'One item',
          'children': [1],
          'positions': [0]
        }, {
          'name': 'Two items',
          'children': [4, 9],
          'positions': [0, 0]
        }, {
          'name': 'Five items',
          'children': [9, 3, 6, 1, 0],
          'positions': [0, 0, 0, 0, 0]
        }];

      for (var t in tests) {
        var testFn = test;
        if (t['solo'] == true) {
          testFn = solo_test;
        }
        testFn(t['name'], () {
          final b = e(0, gen(t['children']));

          final patch = a.diff(b);

          expect(patch, isNotNull);
          checkInnerHtml(a, b, patch);
          expect(patch.attributesPatch, isNull);
          expect(patch.stylesPatch, isNull);
          expect(patch.classListPatch, isNull);
          expect(patch.childrenPatch, isNotNull);
          expect(patch.childrenPatch.insertedNodes, isNotNull);
          expect(patch.childrenPatch.insertedPositions, isNotNull);
          expect(patch.childrenPatch.modifiedNodes, isNull);
          expect(patch.childrenPatch.modifiedPositions, isNull);
          expect(patch.childrenPatch.movedPositions, isNull);
          expect(patch.childrenPatch.removedPositions, isNull);
          expect(
              patch.childrenPatch.insertedNodes.length,
              t['children'].length);
          expect(
              patch.childrenPatch.insertedPositions,
              equals(t['positions']));
        });
      }
    });

    group('Into one element list', () {
      final a = e(0, gen([999]));

      final tests = [{
          'name': 'Prepend one item',
          'children': [1, 999],
          'positions': [0]
        }, {
          'name': 'Append one item',
          'children': [999, 1],
          'positions': [1]
        }, {
          'name': 'Prepend two items',
          'children': [4, 9, 999],
          'positions': [0, 0]
        }, {
          'name': 'Append two items',
          'children': [999, 4, 9],
          'positions': [1, 1]
        }, {
          'name': 'Prepend five items',
          'children': [9, 3, 6, 1, 0, 999],
          'positions': [0, 0, 0, 0, 0]
        }, {
          'name': 'Append five items',
          'children': [999, 9, 3, 6, 1, 0],
          'positions': [1, 1, 1, 1, 1]
        }, {
          'name': 'Prepend and append one item',
          'children': [0, 999, 1],
          'positions': [0, 1]
        }, {
          'name': 'Prepend and append two items',
          'children': [0, 3, 999, 1, 4],
          'positions': [0, 0, 1, 1]
        }, {
          'name': 'Prepend one and append three items',
          'children': [0, 999, 1, 4, 5],
          'positions': [0, 1, 1, 1]
        }];

      for (var t in tests) {
        var testFn = test;
        if (t['solo'] == true) {
          testFn = solo_test;
        }
        testFn(t['name'], () {
          final b = e(0, gen(t['children']));

          final patch = a.diff(b);

          expect(patch, isNotNull);
          checkInnerHtml(a, b, patch);
          expect(patch.attributesPatch, isNull);
          expect(patch.stylesPatch, isNull);
          expect(patch.classListPatch, isNull);
          expect(patch.childrenPatch, isNotNull);
          expect(patch.childrenPatch.insertedNodes, isNotNull);
          expect(patch.childrenPatch.insertedPositions, isNotNull);
          expect(patch.childrenPatch.modifiedNodes, isNull);
          expect(patch.childrenPatch.modifiedPositions, isNull);
          expect(patch.childrenPatch.movedPositions, isNull);
          expect(patch.childrenPatch.removedPositions, isNull);
          expect(
              patch.childrenPatch.insertedNodes.length,
              t['positions'].length);
          expect(
              patch.childrenPatch.insertedPositions,
              equals(t['positions']));
        });
      }
    });
    group('Into two elements list', () {
      final a = e(0, gen([998, 999]));

      final tests = [{
          'name': 'Prepend 1 item',
          'children': [1, 998, 999],
          'positions': [0]
        }, {
          'name': 'Append 1 item',
          'children': [998, 999, 1],
          'positions': [2]
        }, {
          'name': 'Insert betweem 1 item',
          'children': [998, 1, 999],
          'positions': [1]
        }, {
          'name': 'Prepend 2 items',
          'children': [1, 2, 998, 999],
          'positions': [0, 0]
        }, {
          'name': 'Append 2 items',
          'children': [998, 999, 1, 2],
          'positions': [2, 2]
        }, {
          'name': 'Prepend and append 1 item',
          'children': [1, 998, 999, 2],
          'positions': [0, 2]
        }, {
          'name': 'Prepend, append and insert between 1 item',
          'children': [1, 998, 2, 999, 3],
          'positions': [0, 1, 2]
        }, {
          'name': 'Prepend, append and insert between 2 items',
          'children': [1, 4, 998, 2, 5, 999, 3, 6],
          'positions': [0, 0, 1, 1, 2, 2]
        }, {
          'name': 'Prepend and insert between 1 item',
          'children': [1, 998, 2, 999],
          'positions': [0, 1]
        }, {
          'name': 'Append and insert between 1 item',
          'children': [998, 1, 999, 2],
          'positions': [1, 2]
        }, {
          'name': 'Prepend and insert between 2 items',
          'children': [1, 2, 998, 3, 4, 999],
          'positions': [0, 0, 1, 1]
        }, {
          'name': 'Append and insert between 2 items',
          'children': [998, 1, 2, 999, 3, 4],
          'positions': [1, 1, 2, 2]
        }, {
          'name': 'Prepend 10 items',
          'children': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 998, 999],
          'positions': [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        }, {
          'name': 'Append 10 items',
          'children': [998, 999, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          'positions': [2, 2, 2, 2, 2, 2, 2, 2, 2, 2]
        }, {
          'name': 'Prepend and append 5 items',
          'children': [0, 1, 2, 3, 4, 998, 999, 5, 6, 7, 8, 9],
          'positions': [0, 0, 0, 0, 0, 2, 2, 2, 2, 2]
        }, {
          'name': 'Prepend, append 3 items and insert between 4 items',
          'children': [0, 1, 2, 998, 3, 4, 5, 6, 999, 7, 8, 9],
          'positions': [0, 0, 0, 1, 1, 1, 1, 2, 2, 2]
        }, {
          'name': 'Prepend and insert between 5 items',
          'children': [0, 1, 2, 3, 4, 998, 5, 6, 7, 8, 9, 999],
          'positions': [0, 0, 0, 0, 0, 1, 1, 1, 1, 1]
        }, {
          'name': 'Append and insert between 5 items',
          'children': [998, 0, 1, 2, 3, 4, 999, 5, 6, 7, 8, 9],
          'positions': [1, 1, 1, 1, 1, 2, 2, 2, 2, 2]
        }];

      for (var t in tests) {
        var testFn = test;
        if (t['solo'] == true) {
          testFn = solo_test;
        }
        testFn(t['name'], () {
          final b = e(0, gen(t['children']));

          final patch = a.diff(b);

          expect(patch, isNotNull);
          checkInnerHtml(a, b, patch);
          expect(patch.attributesPatch, isNull);
          expect(patch.stylesPatch, isNull);
          expect(patch.classListPatch, isNull);
          expect(patch.childrenPatch, isNotNull);
          expect(patch.childrenPatch.insertedNodes, isNotNull);
          expect(patch.childrenPatch.insertedPositions, isNotNull);
          expect(patch.childrenPatch.modifiedNodes, isNull);
          expect(patch.childrenPatch.modifiedPositions, isNull);
          expect(patch.childrenPatch.movedPositions, isNull);
          expect(patch.childrenPatch.removedPositions, isNull);
          expect(
              patch.childrenPatch.insertedNodes.length,
              t['positions'].length);
          expect(
              patch.childrenPatch.insertedPositions,
              equals(t['positions']));
        });
      }
    });
  });

  group('Basic removes', () {
    group('1 item', () {
      final tests = [{
          'name': 'From 1-sized list',
          'a': [1],
          'b': [],
          'positions': [0]
        }, {
          'name': 'Front item from 2-sized list',
          'a': [1, 2],
          'b': [2],
          'positions': [0]
        }, {
          'name': 'Back item from 2-sized list',
          'a': [1, 2],
          'b': [1],
          'positions': [1]
        }, {
          'name': 'Front item from 3-sized list',
          'a': [1, 2, 3],
          'b': [2, 3],
          'positions': [0]
        }, {
          'name': 'Back item from 3-sized list',
          'a': [1, 2, 3],
          'b': [1, 2],
          'positions': [2]
        }, {
          'name': 'Middle item from 3-sized list',
          'a': [1, 2, 3],
          'b': [1, 3],
          'positions': [1]
        }, {
          'name': 'Front item from 5-sized list',
          'a': [1, 2, 3, 4, 5],
          'b': [2, 3, 4, 5],
          'positions': [0]
        }, {
          'name': 'Back item from 5-sized list',
          'a': [1, 2, 3, 4, 5],
          'b': [1, 2, 3, 4],
          'positions': [4]
        }, {
          'name': 'Middle item from 5-sized list',
          'a': [1, 2, 3, 4, 5],
          'b': [1, 2, 4, 5],
          'positions': [2]
        }];

      for (var t in tests) {
        var testFn = test;
        if (t['solo'] == true) {
          testFn = solo_test;
        }
        testFn(t['name'], () {
          final a = e(0, gen(t['a']));
          final b = e(0, gen(t['b']));

          final patch = a.diff(b);

          expect(patch, isNotNull);
          checkInnerHtml(a, b, patch);
          expect(patch.attributesPatch, isNull);
          expect(patch.stylesPatch, isNull);
          expect(patch.classListPatch, isNull);
          expect(patch.childrenPatch, isNotNull);
          expect(patch.childrenPatch.removedPositions, isNotNull);
          expect(patch.childrenPatch.insertedNodes, isNull);
          expect(patch.childrenPatch.insertedPositions, isNull);
          expect(patch.childrenPatch.modifiedNodes, isNull);
          expect(patch.childrenPatch.modifiedPositions, isNull);
          expect(patch.childrenPatch.movedPositions, isNull);
          expect(
              patch.childrenPatch.removedPositions,
              equals(t['positions']));
        });
      }
    });

    group('2 items', () {
      final tests = [{
          'name': 'From 2-sized list',
          'a': [1, 2],
          'b': [],
          'positions': [0, 1]
        }, {
          'name': 'Front items from 3-sized list',
          'a': [1, 2, 3],
          'b': [3],
          'positions': [0, 1]
        }, {
          'name': 'Back items from 3-sized list',
          'a': [1, 2, 3],
          'b': [1],
          'positions': [1, 2]
        }, {
          'name': 'Front items from 4-sized list',
          'a': [1, 2, 3, 4],
          'b': [3, 4],
          'positions': [0, 1]
        }, {
          'name': 'Back items from 4-sized list',
          'a': [1, 2, 3, 4],
          'b': [1, 2],
          'positions': [2, 3]
        }, {
          'name': 'Middle items from 4-sized list',
          'a': [1, 2, 3, 4],
          'b': [1, 4],
          'positions': [1, 2]
        }, {
          'name': 'Front and back items from 6-sized list',
          'a': [1, 2, 3, 4, 5, 6],
          'b': [2, 3, 4, 5],
          'positions': [0, 5]
        }, {
          'name': 'Front and middle items from 6-sized list',
          'a': [1, 2, 3, 4, 5, 6],
          'b': [2, 3, 5, 6],
          'positions': [0, 3]
        }, {
          'name': 'Back and middle items from 6-sized list',
          'a': [1, 2, 3, 4, 5, 6],
          'b': [1, 2, 3, 5],
          'positions': [3, 5]
        }, {
          'name': 'Front items from 10-sized list',
          'a': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          'b': [2, 3, 4, 5, 6, 7, 8, 9],
          'positions': [0, 1]
        }, {
          'name': 'Back items from 10-sized list',
          'a': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          'b': [0, 1, 2, 3, 4, 5, 6, 7],
          'positions': [8, 9]
        }, {
          'name': 'Front and middle items from 10-sized list',
          'a': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          'b': [1, 2, 3, 4, 6, 7, 8, 9],
          'positions': [0, 5]
        }, {
          'name': 'Back and middle items from 10-sized list',
          'a': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          'b': [0, 1, 2, 3, 4, 6, 7, 8],
          'positions': [5, 9]
        }, {
          'name': 'Middle items from 10-sized list',
          'a': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          'b': [0, 1, 2, 4, 6, 7, 8, 9],
          'positions': [3, 5]
        }];

      for (var t in tests) {
        var testFn = test;
        if (t['solo'] == true) {
          testFn = solo_test;
        }
        testFn(t['name'], () {
          final a = e(0, gen(t['a']));
          final b = e(0, gen(t['b']));

          final patch = a.diff(b);

          expect(patch, isNotNull);
          checkInnerHtml(a, b, patch);
          expect(patch.attributesPatch, isNull);
          expect(patch.stylesPatch, isNull);
          expect(patch.classListPatch, isNull);
          expect(patch.childrenPatch, isNotNull);
          expect(patch.childrenPatch.removedPositions, isNotNull);
          expect(patch.childrenPatch.insertedNodes, isNull);
          expect(patch.childrenPatch.insertedPositions, isNull);
          expect(patch.childrenPatch.modifiedNodes, isNull);
          expect(patch.childrenPatch.modifiedPositions, isNull);
          expect(patch.childrenPatch.movedPositions, isNull);
          expect(
              patch.childrenPatch.removedPositions,
              equals(t['positions']));
        });
      }
    });
  });

  group('Basic moves', () {
    final tests = [{
        'name': 'Swap 2 items in 2-items list',
        'a': [0, 1],
        'b': [1, 0],
        'moves': [1, 0]
      }, {
        'name': 'Reverse 4-items list',
        'a': [0, 1, 2, 3],
        'b': [3, 2, 1, 0],
        'moves': [1, 0, 2, 1, 3, 2]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [1, 2, 3, 4, 0],
        'moves': [0, 5]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [4, 0, 1, 2, 3],
        'moves': [4, 0]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [1, 0, 2, 3, 4],
        'moves': [1, 0]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [2, 0, 1, 3, 4],
        'moves': [2, 0]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [0, 1, 4, 2, 3],
        'moves': [4, 2]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [0, 1, 3, 4, 2],
        'moves': [2, 5]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [0, 1, 3, 2, 4],
        'moves': [3, 2]
      }, {
        'a': [0, 1, 2, 3, 4, 5, 6],
        'b': [2, 1, 0, 3, 4, 5, 6],
        'moves': [1, 0, 2, 1]
      }, {
        'a': [0, 1, 2, 3, 4, 5, 6],
        'b': [0, 3, 4, 1, 2, 5, 6],
        'moves': [4, 1, 3, 4]
      }, {
        'a': [0, 1, 2, 3, 4, 5, 6],
        'b': [0, 2, 3, 5, 6, 1, 4],
        'moves': [4, 7, 1, 4]
      }, {
        'a': [0, 1, 2, 3, 4, 5, 6],
        'b': [0, 1, 5, 3, 2, 4, 6],
        'moves': [3, 2, 5, 3]
      }, {
        'a': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        'b': [8, 1, 3, 4, 5, 6, 0, 7, 2, 9],
        'moves': [2, 9, 0, 7, 8, 1]
      }, {
        'a': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
        'b': [9, 5, 0, 7, 1, 2, 3, 4, 6, 8],
        'moves': [7, 1, 5, 0, 9, 5]
      }];

    for (var t in tests) {
      final a0 = t['a'];
      final b0 = t['b'];
      final name = t['name'] == null ? '$a0 => $b0' : t['name'];

      var testFn = test;
      if (t['solo'] == true) {
        testFn = solo_test;
      }
      testFn(name, () {
        final a = e(0, gen(a0));
        final b = e(0, gen(b0));

        final patch = a.diff(b);

        expect(patch, isNotNull);
        checkInnerHtml(a, b, patch);
        expect(patch.attributesPatch, isNull);
        expect(patch.stylesPatch, isNull);
        expect(patch.classListPatch, isNull);
        expect(patch.childrenPatch, isNotNull);
        expect(patch.childrenPatch.removedPositions, isNull);
        expect(patch.childrenPatch.insertedNodes, isNull);
        expect(patch.childrenPatch.insertedPositions, isNull);
        expect(patch.childrenPatch.modifiedNodes, isNull);
        expect(patch.childrenPatch.modifiedPositions, isNull);
        expect(patch.childrenPatch.movedPositions, t['moves']);
        expect(patch.childrenPatch.removedPositions, isNull);
      });
    }
  });

  group('Insert and Move', () {
    final tests = [{
        'a': [0, 1],
        'b': [2, 1, 0],
        'movedPositions': [1, 0],
        'insertedPositions': [0]
      }, {
        'a': [0, 1],
        'b': [1, 0, 2],
        'movedPositions': [1, 0],
        'insertedPositions': [2]
      }, {
        'a': [0, 1, 2],
        'b': [3, 0, 2, 1],
        'movedPositions': [2, 1],
        'insertedPositions': [0]
      }, {
        'a': [0, 1, 2],
        'b': [0, 2, 1, 3],
        'movedPositions': [2, 1],
        'insertedPositions': [3]
      }, {
        'a': [0, 1, 2],
        'b': [0, 2, 3, 1],
        'movedPositions': [2, 1],
        'insertedPositions': [2]
      }, {
        'a': [0, 1, 2],
        'b': [1, 2, 3, 0],
        'movedPositions': [0, 3],
        'insertedPositions': [2]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [5, 4, 3, 2, 1, 0],
        'movedPositions': [1, 0, 2, 1, 3, 2, 4, 3],
        'insertedPositions': [0]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [5, 4, 3, 6, 2, 1, 0],
        'movedPositions': [1, 0, 2, 1, 3, 2, 4, 3],
        'insertedPositions': [0, 2]
      }, {
        'a': [0, 1, 2, 3, 4],
        'b': [5, 4, 3, 6, 2, 1, 0, 7],
        'movedPositions': [1, 0, 2, 1, 3, 2, 4, 3],
        'insertedPositions': [0, 2, 5]
      }];
    for (var t in tests) {
      final a0 = t['a'];
      final b0 = t['b'];
      final name = t['name'] == null ? '$a0 => $b0' : t['name'];

      var testFn = test;
      if (t['solo'] == true) {
        testFn = solo_test;
      }
      testFn(name, () {
        final a = e(0, gen(a0));
        final b = e(0, gen(b0));

        final patch = a.diff(b);

        expect(patch, isNotNull);
        checkInnerHtml(a, b, patch);
        expect(patch.attributesPatch, isNull);
        expect(patch.stylesPatch, isNull);
        expect(patch.classListPatch, isNull);
        expect(patch.childrenPatch, isNotNull);
        expect(patch.childrenPatch.removedPositions, isNull);
        expect(patch.childrenPatch.insertedNodes, isNotNull);
        expect(patch.childrenPatch.insertedPositions, isNotNull);
        expect(patch.childrenPatch.modifiedNodes, isNull);
        expect(patch.childrenPatch.modifiedPositions, isNull);
        expect(patch.childrenPatch.movedPositions, t['movedPositions']);
        expect(patch.childrenPatch.insertedPositions, t['insertedPositions']);
        expect(patch.childrenPatch.removedPositions, isNull);
      });
    }
  });

  group('Remove and Move', () {
    final tests = [{
        'a': [0, 1, 2],
        'b': [1, 0],
        'movedPositions': [1, 0],
        'removedPositions': [2]
      }, {
        'a': [2, 0, 1],
        'b': [1, 0],
        'movedPositions': [1, 0],
        'removedPositions': [0]
      }, {
        'a': [7, 0, 1, 8, 2, 3, 4, 5, 9],
        'b': [7, 5, 4, 8, 3, 2, 1, 0],
        'movedPositions': [1, -1, 2, 1, 5, 4, 6, 3, 7, 6],
        'removedPositions': [8]
      }, {
        'a': [7, 0, 1, 8, 2, 3, 4, 5, 9],
        'b': [5, 4, 8, 3, 2, 1, 0, 9],
        'movedPositions': [0, 7, 1, 0, 4, 3, 5, 2, 6, 5],
        'removedPositions': [0]
      }, {
        'a': [7, 0, 1, 8, 2, 3, 4, 5, 9],
        'b': [7, 5, 4, 3, 2, 1, 0, 9],
        'movedPositions': [2, 1, 3, 2, 4, 3, 5, 4, 6, 5],
        'removedPositions': [3]
      }, {
        'a': [7, 0, 1, 8, 2, 3, 4, 5, 9],
        'b': [5, 4, 3, 2, 1, 0, 9],
        'movedPositions': [1, 0, 2, 1, 3, 2, 4, 3, 5, 4],
        'removedPositions': [0, 3]
      }, {
        'a': [7, 0, 1, 8, 2, 3, 4, 5, 9],
        'b': [5, 4, 3, 2, 1, 0],
        'movedPositions': [1, 0, 2, 1, 3, 2, 4, 3, 5, 4],
        'removedPositions': [0, 3, 8]
      }];

    for (var t in tests) {
      final a0 = t['a'];
      final b0 = t['b'];
      final name = t['name'] == null ? '$a0 => $b0' : t['name'];

      var testFn = test;
      if (t['solo'] == true) {
        testFn = solo_test;
      }
      testFn(name, () {
        final a = e(0, gen(a0));
        final b = e(0, gen(b0));

        final patch = a.diff(b);

        expect(patch, isNotNull);
        checkInnerHtml(a, b, patch);
        expect(patch.attributesPatch, isNull);
        expect(patch.stylesPatch, isNull);
        expect(patch.classListPatch, isNull);
        expect(patch.childrenPatch, isNotNull);
        expect(patch.childrenPatch.removedPositions, isNotNull);
        expect(patch.childrenPatch.insertedNodes, isNull);
        expect(patch.childrenPatch.insertedPositions, isNull);
        expect(patch.childrenPatch.modifiedNodes, isNull);
        expect(patch.childrenPatch.modifiedPositions, isNull);
//        expect(patch.childrenPatch.movedPositions, t['movedPositions']);
        expect(patch.childrenPatch.removedPositions, t['removedPositions']);
      });
    }
  });

  group('Insert and Remove', () {
    final tests = [{
        'a': [0],
        'b': [1],
        'removedPositions': [0],
        'insertedPositions': [0]
      }, {
        'a': [0],
        'b': [1, 2],
        'removedPositions': [0],
        'insertedPositions': [0, 0]
      }, {
        'a': [0, 2],
        'b': [1],
        'removedPositions': [0, 1],
        'insertedPositions': [0]
      }, {
        'a': [0, 2],
        'b': [1, 2],
        'removedPositions': [0],
        'insertedPositions': [0]
      }, {
        'a': [0, 2],
        'b': [2, 1],
        'removedPositions': [0],
        'insertedPositions': [1]
      }, {
        'a': [0, 1, 2],
        'b': [3, 4, 5],
        'removedPositions': [0, 1, 2],
        'insertedPositions': [0, 0, 0]
      }, {
        'a': [0, 1, 2],
        'b': [2, 4, 5],
        'removedPositions': [0, 1],
        'insertedPositions': [1, 1]
      }, {
        'a': [0, 1, 2, 3, 4, 5],
        'b': [6, 7, 8, 9, 10, 11],
        'removedPositions': [0, 1, 2, 3, 4, 5],
        'insertedPositions': [0, 0, 0, 0, 0, 0]
      }, {
        'a': [0, 1, 2, 3, 4, 5],
        'b': [6, 1, 7, 3, 4, 8],
        'removedPositions': [0, 2, 5],
        'insertedPositions': [0, 1, 3]
      }, {
        'a': [0, 1, 2, 3, 4, 5],
        'b': [6, 7, 3, 8],
        'removedPositions': [0, 1, 2, 4, 5],
        'insertedPositions': [0, 0, 1]
      }];


    for (var t in tests) {
      final a0 = t['a'];
      final b0 = t['b'];
      final name = t['name'] == null ? '$a0 => $b0' : t['name'];

      var testFn = test;
      if (t['solo'] == true) {
        testFn = solo_test;
      }
      testFn(name, () {
        final a = e(0, gen(a0));
        final b = e(0, gen(b0));

        final patch = a.diff(b);

        expect(patch, isNotNull);
        checkInnerHtml(a, b, patch);
        expect(patch.attributesPatch, isNull);
        expect(patch.stylesPatch, isNull);
        expect(patch.classListPatch, isNull);
        expect(patch.childrenPatch, isNotNull);
        expect(patch.childrenPatch.removedPositions, isNotNull);
        expect(patch.childrenPatch.insertedNodes, isNotNull);
        expect(patch.childrenPatch.insertedPositions, isNotNull);
        expect(patch.childrenPatch.modifiedNodes, isNull);
        expect(patch.childrenPatch.modifiedPositions, isNull);
        expect(patch.childrenPatch.movedPositions, isNull);
        expect(patch.childrenPatch.removedPositions, t['removedPositions']);
        expect(patch.childrenPatch.insertedPositions, t['insertedPositions']);
      });
    }
  });

  group('Insert, Remove and Move', () {
    final tests = [{
        'a': [0, 1, 2],
        'b': [3, 2, 1],
        'movedPositions': [1, 0],
        'removedPositions': [0],
        'insertedPositions': [0]
      }, {
        'a': [0, 1, 2],
        'b': [2, 1, 3],
        'movedPositions': [1, 0],
        'removedPositions': [0],
        'insertedPositions': [3]
      }, {
        'a': [1, 2, 0],
        'b': [2, 1, 3],
        'movedPositions': [1, 0],
        'removedPositions': [2],
        'insertedPositions': [3]
      }, {
        'a': [1, 2, 0],
        'b': [3, 2, 1],
        'movedPositions': [1, 0],
        'removedPositions': [2],
        'insertedPositions': [0]
      }, {
        'a': [0, 1, 2, 3, 4, 5],
        'b': [6, 1, 3, 2, 4, 7],
        'movedPositions': [2, 1],
        'removedPositions': [0, 5],
        'insertedPositions': [0, 6]
      }, {
        'a': [0, 1, 2, 3, 4, 5],
        'b': [6, 1, 7, 3, 2, 4],
        'movedPositions': [2, 1],
        'removedPositions': [0, 5],
        'insertedPositions': [0, 1]
      }, {
        'a': [0, 1, 2, 3, 4, 5],
        'b': [6, 7, 3, 2, 4],
        'movedPositions': [1, 0],
        'removedPositions': [0, 1, 5],
        'insertedPositions': [0, 0]
      }, {
        'a': [0, 2, 3, 4, 5],
        'b': [6, 1, 7, 3, 2, 4],
        'movedPositions': [1, 0],
        'removedPositions': [0, 4],
        'insertedPositions': [0, 0, 0]
      }];
    for (var t in tests) {
      final a0 = t['a'];
      final b0 = t['b'];
      final name = t['name'] == null ? '$a0 => $b0' : t['name'];

      var testFn = test;
      if (t['solo'] == true) {
        testFn = solo_test;
      }
      testFn(name, () {
        final a = e(0, gen(a0));
        final b = e(0, gen(b0));

        final patch = a.diff(b);

        expect(patch, isNotNull);
        checkInnerHtml(a, b, patch);
        expect(patch.attributesPatch, isNull);
        expect(patch.stylesPatch, isNull);
        expect(patch.classListPatch, isNull);
        expect(patch.childrenPatch, isNotNull);
        expect(patch.childrenPatch.removedPositions, isNotNull);
        expect(patch.childrenPatch.insertedNodes, isNotNull);
        expect(patch.childrenPatch.insertedPositions, isNotNull);
        expect(patch.childrenPatch.modifiedNodes, isNull);
        expect(patch.childrenPatch.modifiedPositions, isNull);
        expect(patch.childrenPatch.movedPositions, isNotNull);
        expect(patch.childrenPatch.removedPositions, t['removedPositions']);
        expect(patch.childrenPatch.movedPositions, t['movedPositions']);
        expect(patch.childrenPatch.insertedPositions, t['insertedPositions']);
      });
    }
  });

  group('Modified children', () {
    final tests = [{
        'a': [[0, [0]]],
        'b': [0],
        'movedPositions': null,
        'modifiedPositions': [0],
        'removedPositions': null,
        'insertedPositions': null
      }, {
        'a': [0, 1, [2, [0]]],
        'b': [2],
        'movedPositions': null,
        'modifiedPositions': [2],
        'removedPositions': [0, 1],
        'insertedPositions': null
      }, {
        'a': [0],
        'b': [1, 2, [0, [0]]],
        'movedPositions': null,
        'modifiedPositions': [0],
        'removedPositions': null,
        'insertedPositions': [0, 0]
      }, {
        'a': [0, [1, [0, 1]], 2],
        'b': [3, 2, [1, [1, 0]]],
        'movedPositions': [1, 0],
        'modifiedPositions': [1],
        'removedPositions': [0],
        'insertedPositions': [0]
      }, {
        'a': [0, [1, [0, 1]], 2],
        'b': [2, [1, [1, 0]], 3],
        'movedPositions': [1, 0],
        'modifiedPositions': [1],
        'removedPositions': [0],
        'insertedPositions': [3]
      }, {
        'a': [[1, [0, 1]], [2, [0, 1]], 0],
        'b': [[2, [1, 0]], [1, [1, 0]], 3],
        'movedPositions': [1, 0],
        'modifiedPositions': [0, 1],
        'removedPositions': [2],
        'insertedPositions': [3]
      }, {
        'a': [[1, [0, 1]], 2, 0],
        'b': [3, [2, [1, 0]], 1],
        'movedPositions': [1, 0],
        'modifiedPositions': [0, 1],
        'removedPositions': [2],
        'insertedPositions': [0]
      }, {
        'a': [0, 1, 2, [3, [1, 0]], 4, 5],
        'b': [6, [1, [0, 1]], 3, 2, 4, 7],
        'movedPositions': [2, 1],
        'modifiedPositions': [1, 3],
        'removedPositions': [0, 5],
        'insertedPositions': [0, 6]
      }, {
        'a': [0, 1, 2, 3, 4, 5],
        'b': [6, [1, [1]], 7, [3, [1]], [2, [1]], [4, [1]]],
        'movedPositions': [2, 1],
        'modifiedPositions': [1, 2, 3, 4],
        'removedPositions': [0, 5],
        'insertedPositions': [0, 1]
      }, {
        'a': [0, 1, [2, [0]], 3, [4, [0]], 5],
        'b': [6, 7, 3, 2, 4],
        'movedPositions': [1, 0],
        'modifiedPositions': [2, 4],
        'removedPositions': [0, 1, 5],
        'insertedPositions': [0, 0]
      }, {
        'a': [0, [2, [0]], [3, [0]], [4, [0]], 5],
        'b': [6, 1, 7, 3, 2, 4],
        'movedPositions': [1, 0],
        'modifiedPositions': [1, 2, 3],
        'removedPositions': [0, 4],
        'insertedPositions': [0, 0, 0]
      }];
    for (var t in tests) {
      final a0 = t['a'];
      final b0 = t['b'];
      final name = t['name'] == null ? '$a0 => $b0' : t['name'];

      var testFn = test;
      if (t['solo'] == true) {
        testFn = solo_test;
      }
      testFn(name, () {
        final aChildren = gen(a0);
        final bChildren = gen(b0);
        final a = e(0, aChildren);
        final b = e(0, bChildren);

        final patch = a.diff(b);

        expect(patch, isNotNull);
        checkInnerHtml(a, b, patch);
        expect(patch.attributesPatch, isNull);
        expect(patch.stylesPatch, isNull);
        expect(patch.classListPatch, isNull);
        expect(patch.childrenPatch, isNotNull);
        expect(patch.childrenPatch.removedPositions, t['removedPositions']);
        expect(patch.childrenPatch.movedPositions, t['movedPositions']);
        expect(patch.childrenPatch.modifiedPositions, t['modifiedPositions']);
        expect(patch.childrenPatch.insertedPositions, t['insertedPositions']);
      });
    }
  });
}
