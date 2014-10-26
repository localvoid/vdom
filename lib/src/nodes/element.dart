// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;


/// Virtual Dom Element
class Element extends Node {
  /// [Element] tag name
  final String tag;

  /// [Element] attributes
  Map<String, String> attributes;

  /// [Element] styles
  Map<String, String> styles;

  /// Element classes
  List<String> classes;

  /// Element children
  List<Node> children;

  /// Create a new [Element]
  Element(Object key, this.tag, [this.children = null, this.attributes =
      null, this.classes = null, this.styles = null]) : super(key);

  /// Run diff against [other] [Element] and return [ElementPatch] or [null] if
  /// nothing is changed
  ElementPatch diff(Element other) {
    final attributeChanges = mapDiff(attributes, other.attributes);
    final styleChanges = mapDiff(styles, other.styles);
    final classesChanges = unorderedListDiff(classes, other.classes);
    final childrenChanges = _diffChildren(children, other.children);

    if (attributeChanges == null &&
        styleChanges == null &&
        classesChanges == null &&
        childrenChanges == null) {
      return null;
    }

    return new ElementPatch(
        attributeChanges,
        styleChanges,
        classesChanges,
        childrenChanges);
  }

  /// Render [Element] and return [html.Element]
  html.Element render() {
    var result = html.document.createElement(tag);

    if (attributes != null) {
      attributes.forEach((key, value) {
        result.setAttribute(key, value);
      });
    }
    if (styles != null) {
      styles.forEach((key, value) {
        result.style.setProperty(key, value);
      });
    }
    if (classes != null) {
      result.classes.addAll(classes);
    }

    if (children != null) {
      for (var i = 0; i < children.length; i++) {
        result.append(children[i].render());
      }
    }

    return result;
  }

  String toString() => '<$tag key="$key">${children.join()}</$tag>';
}

ElementChildrenPatch _diffChildren(List<Node> a, List<Node> b) {
  if (a != null && a.isNotEmpty) {
    if (b == null || b.isEmpty) {
      // when [b] is empty, it means that all childrens from list [a] were
      // removed
      final removedPositions = new List(a.length);
      for (var i = 0; i < a.length; i++) {
        removedPositions[i] = i;
      }
      return new ElementChildrenPatch(
          removedPositions,
          null,
          null,
          null,
          null,
          null);

    } else {
      if (a.length == 1 && b.length == 1) {
        // fast path when [a] and [b] have just 1 child
        //
        // if both lists have child with the same key, then just diff them,
        // otherwise return patch with [a] child removed and [b] child inserted
        final aNode = a.first;
        final bNode = b.first;

        if (aNode.key == bNode.key) {
          var modified = aNode.diff(bNode);

          if (modified != null) {
            return new ElementChildrenPatch(
                null,
                null,
                null,
                null,
                [modified],
                [0]);
          }
          return null;
        }

        return new ElementChildrenPatch(
            [0],
            null,
            [bNode],
            [0],
            null,
            null);

      } else if (a.length == 1) {
        // fast path when [a] have 1 child

        final aNode = a.first;
        final insertedNodes = new List();
        final insertedPositions = new List();
        var removedPositions;
        var modifiedNodes;
        var modifiedPositions;

        // [a] child position
        // if it is -1, then the child is removed
        var unchangedPosition = -1;

        for (var i = 0; i < b.length; i++) {
          final bNode = b[i];
          if (aNode.key == bNode.key) {
            unchangedPosition = i;
            break;
          } else {
            insertedNodes.add(bNode);
            insertedPositions.add(i);
          }
        }

        if (unchangedPosition != -1) {
          for (var i = unchangedPosition + 1; i < b.length; i++) {
            insertedNodes.add(b[i]);
            insertedPositions.add(i);
          }
          final patch = aNode.diff(b[unchangedPosition]);
          if (patch != null) {
            modifiedNodes = [patch];
            modifiedPositions = [0];
          }
        } else {
          removedPositions = [0];
        }

        return new ElementChildrenPatch(
            removedPositions,
            null,
            insertedNodes,
            insertedPositions,
            modifiedNodes,
            modifiedPositions);
      } else if (b.length == 1) {
        // fast path when [b] have 1 child

        final bNode = b.first;
        final removedPositions = new List();
        var insertedNodes;
        var insertedPositions;
        var modifiedNodes;
        var modifiedPositions;

        // [a] child position
        // if it is -1, then the child is inserted
        var unchangedPosition = -1;

        for (var i = 0; i < a.length; i++) {
          final aNode = a[i];
          if (aNode.key == bNode.key) {
            unchangedPosition = i;
            break;
          } else {
            removedPositions.add(i);
          }
        }

        if (unchangedPosition != -1) {
          for (var i = unchangedPosition + 1; i < a.length; i++) {
            removedPositions.add(i);
          }
          final patch = a[unchangedPosition].diff(bNode);
          if (patch != null) {
            modifiedNodes = [patch];
            modifiedPositions = [unchangedPosition];
          }
        } else {
          insertedNodes = [bNode];
          insertedPositions = [0];
        }

        return new ElementChildrenPatch(
            removedPositions,
            null,
            insertedNodes,
            insertedPositions,
            modifiedNodes,
            modifiedPositions);

      } else {
        // both [a] and [b] have more than 1 child, so we should handle
        // more complex situations with inserting/removing and repositioning
        // childrens
        return _diffChildren2(a, b);
      }
    }
  } else if (b != null && b.length > 0) {
    // all childrens from list [b] were inserted
    final bLength = b.length;

    final insertedNodes = new List(bLength);
    final insertedPositions = new List(bLength);
    for (var i = 0; i < bLength; i++) {
      insertedNodes[i] = b[i];
      insertedPositions[i] = i;
    }
    return new ElementChildrenPatch(
        null,
        null,
        insertedNodes,
        insertedPositions,
        null,
        null);
  }

  return null;
}

ElementChildrenPatch _diffChildren2(List<Node> a, List<Node> b) {
  final unchangedSourcePositions = new List<int>();
  final unchangedTargetPositions = new List<int>();
  final removedPositions = new List<int>();
  final insertedNodes = new List<Node>();
  final insertedPositions = new List<int>();

  final sources = new List<int>.filled(b.length, -1);

  var moved = false;
  var changesCounter = 0;

  // when both lists are small, the join operation is much faster with simple
  // MxN list search instead of hashmap join
  if (a.length * b.length <= 16) {
    var lastTarget = 0;
    var removeOffset = 0;

    for (var i = 0; i < a.length; i++) {
      final aNode = a[i];
      var removed = true;

      for (var j = 0; j < b.length; j++) {
        final bNode = b[j];
        if (aNode.key == bNode.key) {
          sources[j] = i - removeOffset;

          // check if items in wrong order
          if (lastTarget > j) {
            moved = true;
          } else {
            lastTarget = j;
          }

          unchangedSourcePositions.add(i);
          unchangedTargetPositions.add(j);

          removed = false;
          break;
        }
      }

      if (removed) {
        removedPositions.add(i);
        removeOffset++;
        changesCounter++;
      }
    }

  } else {
    final keyIndex = new HashMap<Object, int>();
    var lastTarget = 0;
    var removeOffset = 0;

    // index nodes from list [b]
    for (var i = 0; i < b.length; i++) {
      final node = b[i];
      keyIndex[node.key] = i;
    }

    // index nodes from list [a] and check if they're removed
    for (var i = 0; i < a.length; i++) {
      final sourceNode = a[i];
      final targetIndex = keyIndex[sourceNode.key];
      if (targetIndex != null) {
        final targetNode = b[targetIndex];

        sources[targetIndex] = i - removeOffset;

        // check if items in wrong order
        if (lastTarget > targetIndex) {
          moved = true;
        } else {
          lastTarget = targetIndex;
        }

        unchangedSourcePositions.add(i);
        unchangedTargetPositions.add(targetIndex);
      } else {
        removedPositions.add(i);
        removeOffset++;
        changesCounter++;
      }
    }
  }

  var movedPositions;

  if (moved) {
    // create new list without removed/inserted nodes
    // and use source position ids instead of vnodes
    final c = new List<int>.filled(a.length - removedPositions.length, 0);

    // fill new lists and find all inserted/unchanged nodes
    var insertedOffset = 0;
    for (var i = 0; i < b.length; i++) {
      final node = b[i];
      if (sources[i] == -1) {
        insertedNodes.add(node);
        insertedPositions.add(i);
        insertedOffset++;
        changesCounter++;
      } else {
        c[i - insertedOffset] = sources[i];
      }
    }

    final seq = _lis(c);

    movedPositions = [];
    var i = c.length - 1;
    var j = seq.length - 1;

    while (i >= 0) {
      if (j < 0 || i != seq[j]) {
        var t;
        if (i + 1 == c.length) {
          t = -1;
        } else {
          t = c[i + 1];
        }
        movedPositions.add(c[i]);
        movedPositions.add(t);
      } else {
        j--;
      }
      i--;
    }

    changesCounter += movedPositions.length;
  } else {
    for (var i = 0; i < b.length; i++) {
      final node = b[i];
      if (sources[i] == -1) {
        insertedNodes.add(node);
        insertedPositions.add(i);
        changesCounter++;
      }
    }
  }

  final modifiedPositions = [];
  final modifiedNodes = [];

  for (var i = 0; i < unchangedSourcePositions.length; i++) {
    final source = unchangedSourcePositions[i];
    final target = unchangedTargetPositions[i];
    final node = a[source];
    final patch = node.diff(b[target]);
    if (patch != null) {
      modifiedPositions.add(source);
      modifiedNodes.add(patch);
      changesCounter++;
    }
  }

  if (changesCounter == 0) {
    return null;
  }

  return new ElementChildrenPatch(
      removedPositions.isEmpty ? null : removedPositions,
      movedPositions,
      insertedNodes.isEmpty ? null : insertedNodes,
      insertedPositions.isEmpty ? null : insertedPositions,
      modifiedNodes.isEmpty ? null : modifiedNodes,
      modifiedPositions.isEmpty ? null : modifiedPositions);
}

/// Algorithm that finds longest increasing subsequence.
List<int> _lis(List<int> a) {
  List<int> p = new List<int>.from(a);
  List<int> result = new List<int>();

  result.add(0);

  for (var i = 0; i < a.length; i++) {
    if (a[result.last] < a[i]) {
      p[i] = result.last;
      result.add(i);
      continue;
    }

    var u = 0;
    var v = result.length - 1;
    while (u < v) {
      int c = (u + v) ~/ 2;

      if (a[result[c]] < a[i]) {
        u = c + 1;
      } else {
        v = c;
      }
    }

    if (a[i] < a[result[u]]) {
      if (u > 0) {
        p[i] = result[u - 1];
      }

      result[u] = i;
    }
  }
  var u = result.length;
  var v = result.last;

  while (u-- > 0) {
    result[u] = v;
    v = p[v];
  }

  return result;
}
