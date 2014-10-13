// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;

/**
 * Virtual Dom Element
 */
class Element extends Node {
  /**
   * Element tag name
   */
  final String tag;

  /**
   * Element attributes
   */
  Map<String, String> attributes;

  /**
   * Element styles
   */
  Map<String, String> styles;

  /**
   * Element classes
   */
  List<String> classes;

  /**
   * Element children
   */
  List<Node> children;

  /**
   * Create a new [VElement]
   */
  Element(Object key, this.tag, [this.children = null, this.attributes = null,
      this.classes = null, this.styles = null]) : super(
      key);

  /**
   * Run diff against [other] [VElement]
   */
  ElementPatch diff(Element other) {
    if (identical(this, other)) {
      return null;
    }

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

  /**
   * Render [html.Element]
   */
  html.Element render() {
    var result = new html.Element.tag(tag);
    if (children != null) {
      for (var c in children) {
        result.append(c.render());
      }
    }
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

    return result;
  }

  String toString() => 'VElement $key';
}

ElementChildrenPatch _diffChildren(List<Node> a, List<Node> b) {
  if (a != null && a.length > 0) {
    if (b == null || b.length == 0) {
      // all childrens from list [a] were removed
      final aLength = a.length;

      final removedPositions = new List(aLength);
      for (var i = 0; i < aLength; i++) {
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
      final aLength = a.length;
      final bLength = b.length;

      if (aLength == 1 && bLength == 1) {
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
            [bNode.render()],
            [0],
            null,
            null);
      } else if (aLength == 1) {
        final aNode = a.first;
        final insertedNodes = new List();
        final insertedPositions = new List();
        var removedPositions;
        var modifiedNodes;
        var modifiedPositions;
        var unchangedPosition = -1;

        for (var i = 0; i < bLength; i++) {
          final bNode = b[i];
          if (aNode.key == bNode.key) {
            unchangedPosition = i;
            break;
          } else {
            insertedNodes.add(bNode.render());
            insertedPositions.add(i);
          }
        }
        if (unchangedPosition != -1) {
          for (var i = unchangedPosition + 1; i < bLength; i++) {
            insertedNodes.add(b[i].render());
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
      } else if (bLength == 1) {
        final bNode = b[0];
        final removedPositions = new List();
        var insertedNodes;
        var insertedPositions;
        var modifiedNodes;
        var modifiedPositions;
        var unchangedPosition = -1;

        for (var i = 0; i < aLength; i++) {
          final aNode = a[i];
          if (aNode.key == bNode.key) {
            unchangedPosition = i;
            break;
          } else {
            removedPositions.add(i);
          }
        }
        if (unchangedPosition != -1) {
          for (var i = unchangedPosition + 1; i < aLength; i++) {
            removedPositions.add(i);
          }
          final patch = a[unchangedPosition].diff(bNode);
          if (patch != null) {
            modifiedNodes = [patch];
            modifiedPositions = [unchangedPosition];
          }
        } else {
          insertedNodes = [bNode.render()];
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
        return _diffChildren2(a, b);
      }
    }
  } else if (b != null && b.length > 0) {
    // all childrens from list [b] were inserted
    final bLength = b.length;

    final insertedNodes = new List(bLength);
    final insertedPositions = new List(bLength);
    for (var i = 0; i < bLength; i++) {
      insertedNodes[i] = b[i].render();
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
  final insertedNodes = new List<html.Node>();
  final insertedPositions = new List<int>();
  final aLength = a.length;
  final bLength = b.length;

  var moved = false;
  var changesCounter = 0;

  // when both lists are small, the join operation is much faster with simple
  // list search instead of hashmap join
  if (aLength * bLength <= 16) {
    var lastTarget = 0;
    var removeOffset = 0;

    for (var i = 0; i < aLength; i++) {
      final aNode = a[i];
      var removed = true;

      for (var j = 0; j < bLength; j++) {
        final bNode = b[j];
        bNode.target = j;
        if (aNode.key == bNode.key) {
          bNode.source = i - removeOffset;

          // check if items in wrong order
          lastTarget = lastTarget > j ? lastTarget : j;
          if (lastTarget > j) {
            moved = true;
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
    final keyIndex = new HashMap<Object, Node>();
    var lastTarget = 0;
    var removeOffset = 0;

    // index nodes from list [b]
    for (var i = 0; i < bLength; i++) {
      final node = b[i];
      node.target = i;
      keyIndex[node.key] = node;
    }

    // index nodes from list [a] and check if they're removed
    for (var i = 0; i < aLength; i++) {
      final sourceNode = a[i];
      final targetNode = keyIndex[sourceNode.key];
      if (targetNode != null) {
        targetNode.source = i - removeOffset;

        unchangedSourcePositions.add(i);
        unchangedTargetPositions.add(targetNode.target);

        // check if items in wrong order
        lastTarget = lastTarget > targetNode.target ?
            lastTarget :
            targetNode.target;
        if (lastTarget > targetNode.target) {
          moved = true;
        }
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
    final c = new List<int>(a.length - removedPositions.length);

    // fill new lists and find all inserted/unchanged nodes
    var insertedOffset = 0;
    for (var i = 0; i < b.length; i++) {
      final node = b[i];
      if (node.source == -1) {
        insertedNodes.add(node.render());
        insertedPositions.add(i);
        insertedOffset++;
        changesCounter++;
      } else {
        c[i - insertedOffset] = node.source;
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
      if (node.source == -1) {
        insertedNodes.add(node.render());
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


/**
 * Algorithm that finds longest increasing subsequence.
 */
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
