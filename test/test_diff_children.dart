import 'dart:collection';
import 'package:unittest/unittest.dart';
import 'package:unittest/html_enhanced_config.dart';
import 'package:vdom/src/vdom.dart';

class TestNode extends LinkedListEntry {
  final int key;

  TestNode(this.key);

  String toString() => key.toString();
}

LinkedList<TestNode> generateTestNodes(List<int> items) {
  final keyIndex = new HashMap();
  final result = new LinkedList();

  for (var key in items) {
    assert(keyIndex.containsKey(key) == false);
    keyIndex[key] = true;

    final node = new TestNode(key);
    result.add(node);
  }

  return result;
}

void checkTestNodes(LinkedList<TestNode> nodes, List<int> items) {
  var i = 0;
  for (var node in nodes) {
    if (node.key != items[i]) {
      throw new TestFailure(
          '[$i] Expected: <${node.key}> Actual: <${items[i]}> Nodes: ${nodes}');
    }
    expect(node.key, equals(items[i]));
    i++;
  }
}

void applyMoves(LinkedList<TestNode> nodes, List<int> moves) {
  final moveOperationsCount = moves.length >> 1;
  final moveSources = new List(moveOperationsCount);
  final moveTargets = new List(moveOperationsCount);

  for (var i = 0; i < moveOperationsCount; i++) {
    final offset = i << 1;
    final source = moves[offset];
    final target = moves[offset + 1];
    moveSources[i] = nodes.elementAt(source);
    moveTargets[i] = target != -1 ? nodes.elementAt(target) : -1;
  }

  for (var i = 0; i < moveOperationsCount; i++) {
    final source = moveSources[i];
    final target = moveTargets[i];

    source.unlink();
    if (target != -1) {
      target.insertBefore(source);
    } else {
      nodes.add(source);
    }
  }
}

/**
 * Generates list of [VNode] elements with source/target properties
 * from list of integers.
 */
List<VNode> generateVNodes(List<int> a, List<int> b) {
  // [a] and [b] lists should have the same length
  assert(a.length == b.length);

  final result = [];
  final keyIndex = new HashMap();

  for (var i = 0; i < a.length; i++) {
    final key = a[i].toString();
    final node = new VElement('div', key);
    node.source = i;

    result.add(node);
    keyIndex[key] = node;
  }

  for (var i = 0; i < b.length; i++) {
    final key = b[i].toString();
    final node = keyIndex[key];

    // all nodes from the list [b] should be in the list [a]
    assert(node != null);

    node.target = i;
  }

  return result;
}

final PrecomputedMoves = [{
    'name': 'No Moves',
    'a': [0, 1, 2, 3, 4],
    'b': [0, 1, 2, 3, 4],
    'moves': []
  }, {
    'name': 'Reverse',
    'a': [0, 1, 2, 3],
    'b': [3, 2, 1, 0],
    'moves': [0, -1, 1, 0, 2, 1]
  }, {
    'a': [0, 1],
    'b': [1, 0],
    'moves': [0, -1]
  }, {
    'a': [0, 1, 2, 3, 4],
    'b': [1, 2, 3, 4, 0],
    'moves': [0, -1]
  }, {
    'a': [0, 1, 2, 3, 4],
    'b': [4, 0, 1, 2, 3],
    'moves': [4, 0]
  }, {
    'a': [0, 1, 2, 3, 4],
    'b': [1, 0, 2, 3, 4],
    'moves': [0, 2]
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
    'moves': [2, -1]
  }, {
    'a': [0, 1, 2, 3, 4],
    'b': [0, 1, 3, 2, 4],
    'moves': [2, 4]
  }, {
    'a': [0, 1, 2, 3, 4, 5, 6],
    'b': [2, 1, 0, 3, 4, 5, 6],
    'moves': [0, 3, 1, 0]
  }, {
    'a': [0, 1, 2, 3, 4, 5, 6],
    'b': [0, 3, 4, 1, 2, 5, 6],
    'moves': [2, 5, 1, 2]
  }, {
    'a': [0, 1, 2, 3, 4, 5, 6],
    'b': [0, 2, 3, 5, 6, 1, 4],
    'moves': [4, -1, 1, 4]
  }, {
    'a': [0, 1, 2, 3, 4, 5, 6],
    'b': [0, 1, 5, 3, 2, 4, 6],
    'moves': [2, 4, 5, 3]
  }, {
    'a': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    'b': [8, 1, 3, 4, 5, 6, 0, 7, 2, 9],
    'moves': [2, 9, 0, 7, 8, 1]
  }, {
    'a': [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
    'b': [9, 5, 0, 7, 1, 2, 3, 4, 6, 8],
    'moves': [7, 1, 5, 0, 9, 5]
  }];


void main() {
  useHtmlEnhancedConfiguration();

  group('Test nodes', () {
    test('Generate Empty', () {
      final a = [];
      final nodes = generateTestNodes(a);
      checkTestNodes(nodes, a);
    });

    test('Generate One Node', () {
      final a = [1];
      final nodes = generateTestNodes(a);
      checkTestNodes(nodes, a);
    });

    test('Generate Two Nodes', () {
      final a = [2, 3];
      final nodes = generateTestNodes(a);
      checkTestNodes(nodes, a);
    });

    test('Generate Multiple Nodes', () {
      final a = [1, 2, 5, 7, 9];
      final nodes = generateTestNodes(a);
      checkTestNodes(nodes, a);
    });
  });

  group('Apply moves', () {
    for (var m in PrecomputedMoves) {
      final a = m['a'];
      final b = m['b'];
      final moves = m['moves'];
      final name = m['name'] == null ? '$a => $b | $moves' : m['name'];
      test(name, () {
        final nodes = generateTestNodes(a);
        applyMoves(nodes, moves);
        checkTestNodes(nodes, b);
      });
    }
  });

  group('Forward Diff', () {
    for (var m in PrecomputedMoves) {
      final a = m['a'];
      final b = m['b'];
      final name = m['name'] == null ? '$a => $b' : m['name'];
      test(name, () {
        final testNodes = generateTestNodes(a);
        final nodes = generateVNodes(a, b);
        final diff = new ChildrenPositionsDiff(a, b, nodes);
        final result = diff.runForward();
        applyMoves(testNodes, result);
        checkTestNodes(testNodes, b);
      });
    }
  });

  group('Linear Diff', () {
    for (var m in PrecomputedMoves) {
      final a = m['a'];
      final b = m['b'];
      final name = m['name'] == null ? '$a => $b' : m['name'];
      test(name, () {
        final testNodes = generateTestNodes(a);
        final nodes = generateVNodes(a, b);
        final diff = new ChildrenPositionsDiff(a, b, nodes);
        final result = diff.runLinear();
        applyMoves(testNodes, result);
        checkTestNodes(testNodes, b);
      });
    }
  });

}
