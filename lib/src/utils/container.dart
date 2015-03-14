// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.utils.container;

import 'dart:collection';
import 'dart:html' as html;
import '../context.dart';
import '../node.dart';
import '../utils.dart';

/// [Container] mixin used to extend [VNode]s with the ability to render
/// and update children.
///
/// ```dart
/// class MyNode extends Node with Container {
///   html.DivElement myElement;
///   List<Node> children;
///
///   html.Node get container => myElement;
///
///   MyNode(Object key, this.children) : super(key);
///
///   void create(Context context) {
///     myElement = new DivElement();
///
///     ref = new DivElement()
///       ..append(myElement);
///   }
///
///   void render(Context context) {
///     renderChildren(children, context);
///   }
///
///   void update(MyNode other, Context context) {
///     super.update(other, context);
///     other.myElement = myElement;
///     updateChildren(children, other.children, context);
///   }
/// }
/// ```
abstract class Container<T extends html.Node> {
  /// Container for children.
  T get container;

  /// Insert child before [nextRef]. If [nextRef] is `null`, append it to the
  /// end.
  void insertBefore(VNode node, html.Node nextRef, Context context) {
    node.create(context);
    node.init();
    container.insertBefore(node.ref, nextRef);
    if (context.isAttached){
      node.attached();
    }
    node.render(context);
  }

  /// Move child
  void move(VNode node, html.Node nextRef, Context context) {
    container.insertBefore(node.ref, nextRef);
  }

  /// Remove child
  void removeChild(VNode node, Context context) {
    node.dispose(context);
  }

  /// Mount children inside of [node] element
  void mountChildren(List<VNode> children, html.Element node, Context context) {
    // TODO: check performance for childNodes iteration
    for (var i = 0; i < node.childNodes.length; i++) {
      children[i].mount(node.childNodes[i], context);
    }
  }

  /// Render [children] into [container] node.
  void renderChildren(List<VNode> children, Context context) {
    assert(() {
      if (children.isNotEmpty) {
        final key = children[0].key;
        for (var i = 1; i < children.length; i++) {
          if ((key == null && children[i].key != null) ||
              (key != null && children[i].key == null)) {
            throw
                'All children inside of the Virtual DOM Node should have '
                'either explicit, or implicit keys.\n'
                'Child at position 0 has key $key\n'
                'Child at position $i has key ${children[i].key}\n'
                'Children: $children';
          }
        }
      }
      return true;
    }());

    for (var i = 0; i < children.length; i++) {
      insertBefore(children[i], null, context);
    }
  }

  /// Update children list inside of [container] node.
  void updateChildren(List<VNode> a, List<VNode> b, Context context) {
    if (a != null && a.isNotEmpty) {
      if (b == null || b.isEmpty) {
        // when [b] is empty, it means that all childrens from list [a] were
        // removed
        for (var i = 0; i < a.length; i++) {
          removeChild(a[i], context);
        }
      } else {
        if (a.length == 1 && b.length == 1) {
          // fast path when [a] and [b] have just 1 child
          //
          // if both lists have child with the same key, then just diff them,
          // otherwise return patch with [a] child removed and [b] child
          // inserted
          final aNode = a.first;
          final bNode = b.first;
          assert(invariant(
              (aNode.key == null && bNode.key == null) ||
              (aNode.key != null && bNode.key != null), () =>
              'All children inside of the Virtual DOM Node should have '
              'either explicit, or implicit keys.\n'
              'Child at position old:0 has key ${aNode.key}\n'
              'Child at position new:0 has key ${bNode.key}\n'
              'Old children: $a\n'
              'New children: $b'));

          if ((aNode.key == null && aNode.sameType(bNode)) ||
              aNode.key != null && aNode.key == bNode.key) {
            aNode.update(bNode, context);
          } else {
            removeChild(aNode, context);
            insertBefore(bNode, null, context);
          }
        } else if (a.length == 1) {
          // fast path when [a] have 1 child
          final aNode = a.first;

          // implicit keys
          if (aNode.key == null) {
            assert(() {
              for (var i = 0; i < b.length; i++) {
                if (b[i].key != null) {
                  throw
                      'All children inside of the Virtual DOM Node should have '
                      'either explicit, or implicit keys.\n'
                      'Child at position old:0 has implicit key\n'
                      'Child at position new:$i has explicit key ${b[i].key}\n'
                      'Old children: $a\n'
                      'New children: $b';
                }
              }
              return true;
            }());

            var i = 0;
            var updated = false;
            while(i < b.length) {
              final bNode = b[i++];
              if (aNode.sameType(bNode)) {
                aNode.update(bNode, context);
                updated = true;
                break;
              }
              insertBefore(bNode, aNode.ref, context);
            }

            if (!updated) {
              removeChild(aNode, context);
            } else {
              while (i < b.length) {
                insertBefore(b[i++], null, context);
              }
            }
          } else {
            // [a] child position
            // if it is -1, then the child is removed
            var unchangedPosition = -1;
            assert(() {
              for (var i = 0; i < b.length; i++) {
                if (b[i].key == null) {
                  throw
                      'All children inside of the Virtual DOM Node should have '
                      'either explicit, or implicit keys.\n'
                      'Child at position old:0 has explicit key ${aNode.key}\n'
                      'Child at position new:$i has implicit key\n'
                      'Old children: $a\n'
                      'New children: $b';
                }
              }
              return true;
            }());

            for (var i = 0; i < b.length; i++) {
              final bNode = b[i];
              if (aNode.key == bNode.key) {
                unchangedPosition = i;
                break;
              } else {
                insertBefore(bNode, aNode.ref, context);
              }
            }

            if (unchangedPosition != -1) {
              for (var i = unchangedPosition + 1; i < b.length; i++) {
                insertBefore(b[i], null, context);
              }
              aNode.update(b[unchangedPosition], context);
            } else {
              removeChild(aNode, context);
            }
          }
        } else if (b.length == 1) {
          // fast path when [b] have 1 child
          final bNode = b.first;

          // implicit keys
          if (bNode.key == null) {
            assert(() {
              for (var i = 0; i < a.length; i++) {
                if (a[i].key != null) {
                  throw
                      'All children inside of the Virtual DOM Node should have '
                      'either explicit, or implicit keys.\n'
                      'Child at position old:$i has explicit key ${a[i].key}\n'
                      'Child at position new:0 has implicit key\n'
                      'Old children: $a\n'
                      'New children: $b';
                }
              }
              return true;
            }());

            var i = 0;
            var updated = false;
            while(i < a.length) {
              final aNode = a[i++];
              if (aNode.sameType(bNode)) {
                aNode.update(bNode, context);
                updated = true;
                break;
              }
              removeChild(aNode, context);
            }

            if (!updated) {
              insertBefore(bNode, null, context);
            } else {
              while (i < a.length) {
                removeChild(a[i++], context);
              }
            }
          } else {
            assert(() {
              for (var i = 0; i < a.length; i++) {
                if (a[i].key == null) {
                  throw
                      'All children inside of the Virtual DOM Node should have '
                      'either explicit, or implicit keys.\n'
                      'Child at position old:$i has implicit key\n'
                      'Child at position new:0 has explicit key ${bNode.key}\n'
                      'Old children: $a\n'
                      'New children: $b';
                }
              }
              return true;
            }());

            // [a] child position
            // if it is -1, then the child is inserted
            var unchangedPosition = -1;

            for (var i = 0; i < a.length; i++) {
              final aNode = a[i];
              if (aNode.key == bNode.key) {
                unchangedPosition = i;
                break;
              } else {
                removeChild(aNode, context);
              }
            }

            if (unchangedPosition != -1) {
              for (var i = unchangedPosition + 1; i < a.length; i++) {
                removeChild(a[i], context);
              }
              a[unchangedPosition].update(bNode, context);
            } else {
              insertBefore(bNode, null, context);
            }
          }
        } else {
          // both [a] and [b] have more then 1 child, so we should handle
          // more complex situations with inserting/removing and repositioning
          // childrens.
          assert(() {
            final aKey = a[0].key;
            for (var i = 0; i < b.length; i++) {
              if ((aKey == null && b[i].key != null) ||
                  (aKey != null && b[i].key == null)) {
                throw
                    'All children inside of the Virtual DOM Node should have '
                    'either explicit, or implicit keys.\n'
                    'Child at position old:0 has key $aKey\n'
                    'Child at position new:$i has key ${b[i].key}\n'
                    'Old children: $a\n'
                    'New children: $b';
              }
            }
            return true;
          }());

          if (a.first.key == null) {
            return _updateImplicitChildren(a, b, context);
          }
          return _updateExplicitChildren(a, b, context);
        }
      }
    } else if (b != null && b.length > 0) {
      // all childrens from list [b] were inserted
      assert(() {
        final key = b[0].key;
        for (var i = 0; i < b.length; i++) {
          if ((key == null && b[i].key != null) ||
              (key != null && b[i].key == null)) {
            throw
                'All children inside of the Virtual DOM Node should have '
                'either explicit, or implicit keys.\n'
                'Child at position new:0 has key $key\n'
                'Child at position new:$i has key ${b[i].key}\n'
                'Old children: $a\n'
                'New children: $b';
          }
        }
        return true;
      }());

      for (var i = 0; i < b.length; i++) {
        final n = b[i];
        insertBefore(n, null, context);
      }
    }
  }

  void _updateImplicitChildren(List<VNode> a, List<VNode> b, Context context) {
    int aStart = 0;
    int bStart = 0;
    int aEnd = a.length - 1;
    int bEnd = b.length - 1;

    // Update nodes with the same type at the beginning.
    while (aStart <= aEnd && bStart <= bEnd) {
      final aNode = a[aStart];
      final bNode = b[bStart];

      if (!aNode.sameType(bNode)) {
        break;
      }

      aStart++;
      bStart++;

      aNode.update(bNode, context);
    }

    // Update nodes with the same type at the end.
    while (aStart <= aEnd && bStart <= bEnd) {
      final aNode = a[aEnd];
      final bNode = b[bEnd];

      if (!aNode.sameType(bNode)) {
        break;
      }

      aEnd--;
      bEnd--;

      aNode.update(bNode, context);
    }

    // Iterate through the remaining nodes and if they have the same
    // type, then update, otherwise just remove the old node and insert
    // the new one.
    while (aStart <= aEnd && bStart <= bEnd) {
      final aNode = a[aStart++];
      final bNode = b[bStart++];
      if (aNode.sameType(bNode)) {
        aNode.update(bNode, context);
      } else {
        insertBefore(bNode, aNode.ref, context);
        removeChild(aNode, context);
      }
    }

    // All nodes from [a] are updated, insert the rest from [b].
    while (aStart <= aEnd) {
      removeChild(a[aStart++], context);
    }

    final nextPos = bEnd + 1;
    final next = nextPos < b.length ? b[nextPos].ref : null;

    // All nodes from [b] are updated, remove the rest from [a].
    while (bStart <= bEnd) {
      insertBefore(b[bStart++], next, context);
    }
  }

  void _updateExplicitChildren(List<VNode> a, List<VNode> b, Context context) {
    int aStart = 0;
    int bStart = 0;
    int aEnd = a.length - 1;
    int bEnd = b.length - 1;

    var aStartNode = a[aStart];
    var bStartNode = b[bStart];
    var aEndNode = a[aEnd];
    var bEndNode = b[bEnd];

    bool stop = false;

    // Algorithm that works on simple cases with basic list
    // transformations.
    //
    // It tries to reduce the diff problem by simultaneously iterating
    // from the beginning and the end of both lists, if keys are the
    // same, they're updated, if node is moved from the beginning to the
    // end of the current cursor positions or vice versa it just
    // performs move operation and continues to reduce the diff problem.
    outer: do {
      stop = true;

      // Update nodes with the same key at the beginning.
      while (aStartNode.key == bStartNode.key) {
        aStartNode.update(bStartNode, context);

        aStart++;
        bStart++;
        if (aStart > aEnd || bStart > bEnd) {
          break outer;
        }

        aStartNode = a[aStart];
        bStartNode = b[bStart];

        stop = false;
      }

      // Update nodes with the same key at the end.
      while (aEndNode.key == bEndNode.key) {
        aEndNode.update(bEndNode, context);

        aEnd--;
        bEnd--;
        if (aStart > aEnd || bStart > bEnd) {
          break outer;
        }

        aEndNode = a[aEnd];
        bEndNode = b[bEnd];

        stop = false;
      }

      // Move nodes from left to right.
      while (aStartNode.key == bEndNode.key) {
        aStartNode.update(bEndNode, context);

        final nextPos = bEnd + 1;
        final next = nextPos < b.length ? b[nextPos].ref : null;
        move(bEndNode, next, context);

        aStart++;
        bEnd--;
        if (aStart > aEnd || bStart > bEnd) {
          break outer;
        }

        aStartNode = a[aStart];
        bEndNode = b[bEnd];

        stop = false;
        continue outer;
      }

      // Move nodes from right to left.
      while (aEndNode.key == bStartNode.key) {
        aEndNode.update(bStartNode, context);

        move(aEndNode, a[aStart].ref, context);

        aEnd--;
        bStart++;
        if (aStart > aEnd || bStart > bEnd) {
          break outer;
        }

        aEndNode = a[aEnd];
        bStartNode = b[bStart];

        stop = false;
      }
    } while (!stop && aStart <= aEnd && bStart <= bEnd);

    if (aStart > aEnd) {
      // All nodes from [a] are updated, insert the rest from [b].
      final nextPos = bEnd + 1;
      final next = nextPos < b.length ? b[nextPos].ref : null;
      while (bStart <= bEnd) {
        insertBefore(b[bStart++], next, context);
      }
    } else if (bStart > bEnd) {
      // All nodes from [b] are updated, remove the rest from [a].
      while (aStart <= aEnd) {
        removeChild(a[aStart++], context);
      }
    } else {
      // Perform more complex update algorithm on the remaining nodes.
      //
      // We start by marking all nodes from [b] as inserted, then we try
      // to find all removed nodes and simultaneously perform updates on
      // the nodes that exists in both lists and replacing "inserted"
      // marks with the position of the node from the list [b] in list [a].
      // Then we just need to perform slightly modified LIS algorith,
      // that ignores "inserted" marks and find common subsequence and
      // move all nodes that doesn't belong to this subsequence, or
      // insert if they have "inserted" mark.
      final aLength = aEnd - aStart + 1;
      final bLength = bEnd - bStart + 1;

      // -1 value means that it should be inserted.
      final sources = new List<int>.filled(bLength, -1);

      var moved = false;
      var removeOffset = 0;

      // when both lists are small, we are using naive O(M*N) algorithm to
      // find removed children.
      if (aLength * bLength <= 16) {
        var lastTarget = 0;

        for (var i = aStart; i <= aEnd; i++) {
          bool removed = true;
          final aNode = a[i];

          for (var j = bStart; j <= bEnd; j++) {
            final bNode = b[j];
            if (aNode.key == bNode.key) {
              sources[j - bStart] = i;

              if (lastTarget > j) {
                moved = true;
              } else {
                lastTarget = j;
              }

              aNode.update(bNode, context);

              removed = false;
              break;
            }
          }

          if (removed) {
            removeChild(aNode, context);
            removeOffset++;
          }
        }
      } else {
        final keyIndex = new HashMap<Object, int>();
        var lastTarget = 0;

        for (var i = bStart; i <= bEnd; i++) {
          final node = b[i];
          keyIndex[node.key] = i;
        }

        for (var i = aStart; i <= aEnd; i++) {
          final aNode = a[i];
          final j = keyIndex[aNode.key];
          if (j != null) {
            final bNode = b[j];
            sources[j - bStart] = i;

            if (lastTarget > j) {
              moved = true;
            } else {
              lastTarget = j;
            }

            aNode.update(bNode, context);
          } else {
            removeChild(aNode, context);
            removeOffset++;
          }
        }
      }

      if (moved) {
        final seq = _lis(sources);
        var j = seq.length - 1;

        // All modifications are performed from right to left, so we
        // can use insertBefore method and use reference to the html
        // element from the next VNode. All Nodes on the right side
        // should be in the correct state.
        for (var i = bLength - 1; i >= 0; i--) {
          if (sources[i] == -1) {
            final pos = i + bStart;
            final node = b[pos];
            final nextPos = pos + 1;
            final next = nextPos < b.length ? b[nextPos].ref : null;
            insertBefore(node, next, context);
          } else {
            if (j < 0 || i != seq[j]) {
              final pos = i + bStart;
              final node = a[sources[i]];
              final nextPos = pos + 1;
              final next = nextPos < b.length ? b[nextPos].ref : null;
              move(node, next, context);
            } else {
              j--;
            }
          }
        }
      } else if (aLength - removeOffset != bLength) {
        for (var i = bLength - 1; i >= 0; i--) {
          if (sources[i] == -1) {
            final pos = i + bStart;
            final node = b[pos];
            final nextPos = pos + 1;
            final next = nextPos < b.length ? b[nextPos].ref : null;
            insertBefore(node, next, context);
          }
        }
      }
    }
  }
}

/// Algorithm that finds longest increasing subsequence. With one little
/// modification that it ignores items with -1 value, they're representing
/// items that doesn't exist in the old list.
///
/// It is used to find minimum number of move operations in children list.
///
/// http://en.wikipedia.org/wiki/Longest_increasing_subsequence
List<int> _lis(List<int> a) {
  final p = new List<int>.from(a, growable: false);
  final result = [0];

  for (var i = 0; i < a.length; i++) {
    if (a[i] == -1) {
      continue;
    }
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
