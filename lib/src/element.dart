// Copyright (c) 2014, the vsync project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

abstract class ElementBase extends Node {
  Map<String, String> attributes;
  List<String> classes;
  Map<String, String> styles;

  ElementBase(Object key,
      {this.attributes: null,
       this.classes: null,
       this.styles: null})
       : super(key);

  void render(Context context) {
    final html.Element e = ref;
    if (attributes != null) {
      attributes.forEach((key, value) {
        e.setAttribute(key, value);
      });
    }
    if (styles != null) {
      styles.forEach((key, value) {
        e.style.setProperty(key, value);
      });
    }
    if (classes != null) {
      e.classes.addAll(classes);
    }
  }

  void update(ElementBase other, Context context) {
    other.ref = ref;
    html.Element e = ref;
    if (attributes != null || other.attributes != null) {
      updateMap(attributes, other.attributes, e.attributes);
    }
    if (styles != null || other.styles != null) {
      updateStyle(styles, other.styles, e.style);
    }
    if (classes != null || other.classes != null) {
      updateSet(classes, other.classes, e.classes);
    }
  }
}

/// Virtual Dom Element
class Element extends ElementBase {
  /// [Element] tag name
  final String tag;

  /// Element children
  List<Node> children;

  /// Create a new [Element]
  Element(Object key, this.tag, this.children,
          {Map<String, String> attributes: null,
           List<String> classes: null,
           Map<String, String> styles: null})
           : super(key, attributes: attributes, classes: classes, styles: styles) {
    assert(children != null);
  }

  void create(Context context) {
    ref = html.document.createElement(tag);
  }

  void update(Element other, Context context) {
    super.update(other, context);
    updateChildren(children, other.children, ref, context);
  }

  /// Mount on top of existing element
  void render(Context context) {
    super.render(context);
    for (var i = 0; i < children.length; i++) {
      inject(children[i], ref, context);
    }
  }

  void detached() {
    for (var i = 0; i < children.length; i++) {
      children[i].detached();
    }
  }

  String toString() => '<$tag key="$key">${children.join()}</$tag>';
}

void updateChildren(List<Node> a, List<Node> b, html.Element parent, Context context) {
  if (a.isNotEmpty) {
    if (b.isEmpty) {
      // when [b] is empty, it means that all childrens from list [a] were
      // removed
      for (var i = 0; i < a.length; i++) {
        a[i].dispose(context);
      }
    } else {
      if (a.length == 1 && b.length == 1) {
        // fast path when [a] and [b] have just 1 child
        //
        // if both lists have child with the same key, then just diff them,
        // otherwise return patch with [a] child removed and [b] child inserted
        final aNode = a.first;
        final bNode = b.first;

        if (aNode.key == bNode.key) {
          var modified = aNode.update(bNode, context);
        } else {
          aNode.dispose(context);
          inject(bNode, parent, context);
        }
      } else if (a.length == 1) {
        // fast path when [a] have 1 child
        final aNode = a.first;

        // [a] child position
        // if it is -1, then the child is removed
        var unchangedPosition = -1;

        for (var i = 0; i < b.length; i++) {
          final bNode = b[i];
          if (aNode.key == bNode.key) {
            unchangedPosition = i;
            break;
          } else {
            injectBefore(bNode, parent, aNode.ref, context);
          }
        }

        if (unchangedPosition != -1) {
          for (var i = unchangedPosition + 1; i < b.length; i++) {
            inject(b[i], parent, context);
          }
          aNode.update(b[unchangedPosition], context);
        } else {
          aNode.dispose(context);
        }
      } else if (b.length == 1) {
        // fast path when [b] have 1 child
        final bNode = b.first;

        // [a] child position
        // if it is -1, then the child is inserted
        var unchangedPosition = -1;

        for (var i = 0; i < a.length; i++) {
          final aNode = a[i];
          if (aNode.key == bNode.key) {
            unchangedPosition = i;
            break;
          } else {
            aNode.dispose(context);
          }
        }

        if (unchangedPosition != -1) {
          for (var i = unchangedPosition + 1; i < a.length; i++) {
            a[i].dispose(context);
          }
          a[unchangedPosition].update(bNode, context);
        } else {
          inject(bNode, parent, context);
        }
      } else {
        // both [a] and [b] have more than 1 child, so we should handle
        // more complex situations with inserting/removing and repositioning
        // childrens
        return _syncChildren2(a, b, parent, context);
      }
    }
  } else if (b.length > 0) {
    // all childrens from list [b] were inserted
    for (var i = 0; i < b.length; i++) {
      final n = b[i];
      inject(n, parent, context);
    }
  }
}

void _syncChildren2(List<Node> a, List<Node> b, html.Element parent, Context context) {
  var aLength = a.length;
  var bLength = b.length;

  final minLength = aLength < bLength ? aLength : bLength;

  var start = 0;

  while(start < minLength) {
    final aNode = a[start];
    final bNode = b[start];
    if (aNode.key != bNode.key) {
      break;
    }
    aNode.update(bNode, context);
    start++;
  }

  if (start == bLength) {
    if (start != aLength) {
      for (var i = start; i < a.length; i++) {
        a[i].dispose(context);
      }
    }
  } else if (start == aLength) {
    for (var i = start; i < b.length; i++) {
      final n = b[i];
      inject(n, parent, context);
    }
  } else {
    var aEnd = a.length - 1;
    var bEnd = b.length - 1;
    while (aEnd >= start && bEnd >= start) {
      final aNode = a[aEnd];
      final bNode = b[bEnd];

      if (aNode.key != bNode.key) {
        break;
      }
      aNode.update(bNode, context);
      aEnd--;
      bEnd--;
    }
    aEnd++;
    bEnd++;

    if (aEnd == start) {
      assert(bEnd != start);
      final aEndRef = a[aEnd].ref;
      for (var i = start; i < bEnd; i++) {
        injectBefore(b[i], parent, aEndRef, context);
      }
    } else if (bEnd == start) {
      for (var i = start; i < aEnd; i++) {
        a[i].dispose(context);
      }
    } else {
      aLength = aEnd - start;
      bLength = bEnd - start;

      final sources = new List<int>.filled(bLength, -1);

      var moved = false;
      var removeOffset = 0;

      // when both lists are small, the join operation is much faster with simple
      // MxN list search instead of hashmap join
      if (aLength * bLength <= 16) {
        var lastTarget = 0;

        for (var i = 0; i < aLength; i++) {
          final iOff = i + start;
          final aNode = a[iOff];
          var removed = true;

          for (var j = 0; j < bLength; j++) {
            final jOff = j + start;
            final bNode = b[jOff];
            if (aNode.key == bNode.key) {
              sources[j] = iOff;

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
            aNode.dispose(context);
            removeOffset++;
          }
        }

      } else {
        final keyIndex = new HashMap<Object, int>();
        var lastTarget = 0;

        for (var i = 0; i < bLength; i++) {
          final node = b[i + start];
          keyIndex[node.key] = i;
        }

        for (var i = 0; i < aLength; i++) {
          final iOff = i + start;
          final aNode = a[iOff];
          final j = keyIndex[aNode.key];
          if (j != null) {
            final jOff = j + start;
            final bNode = b[jOff];
            sources[j] = iOff;

            if (lastTarget > j) {
              moved = true;
            } else {
              lastTarget = j;
            }

            aNode.update(bNode, context);
          } else {
            aNode.dispose(context);
            removeOffset++;
          }
        }
      }

      if (moved) {
        final seq = _lis(sources);
        var j = seq.length - 1;

        for (var i = bLength - 1; i >= 0; i--) {
          if (sources[i] == -1) {
            final pos = i + start;
            final node = b[pos];
            final nextPos = pos + 1;
            final next = nextPos < b.length ? b[nextPos].ref : null;
            injectBefore(node, parent, next, context);
          } else {
            if (j < 0 || i != seq[j]) {
              final pos = i + start;
              final node = a[sources[i]];
              final nextPos = pos + 1;
              final next = nextPos < b.length ? b[nextPos].ref : null;
              parent.insertBefore(node.ref, next);
            } else {
              j--;
            }
          }
        }

      } else if (aLength - removeOffset != bLength) {
        for (var i = bLength - 1; i >= 0; i--) {
          if (sources[i] == -1) {
            final pos = i + start;
            final node = b[pos];
            final nextPos = pos + 1;
            final next = nextPos < b.length ? b[nextPos].ref : null;
            injectBefore(node, parent, next, context);
          }
        }
      }
    }
  }
}

/// Algorithm that finds longest increasing subsequence.
List<int> _lis(List<int> a) {
  final p = new List<int>.from(a);
  final result = new List<int>();

  result.add(0);

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
