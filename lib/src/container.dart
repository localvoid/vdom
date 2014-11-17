part of vdom;

abstract class Container {
  html.Node get container;

  void insertBefore(Node node, html.Node nextRef, Context context) {
    injectBefore(node, container, nextRef, context);
  }

  void move(Node node, html.Node nextRef, Context context) {
    container.insertBefore(node.ref, nextRef);
  }

  void removeChild(Node node, Context context) {
    node.dispose(context);
  }

  void updateChildren(List<Node> a, List<Node> b, Context context) {
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

          if (aNode.key == bNode.key) {
            var modified = aNode.update(bNode, context);
          } else {
            removeChild(aNode, context);
            insertBefore(bNode, null, context);
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
        } else {
          // both [a] and [b] have more than 1 child, so we should handle
          // more complex situations with inserting/removing and repositioning
          // childrens
          return _updateChildren2(a, b, context);
        }
      }
    } else if (b != null && b.length > 0) {
      // all childrens from list [b] were inserted
      for (var i = 0; i < b.length; i++) {
        final n = b[i];
        insertBefore(n, null, context);
      }
    }
  }

  void _updateChildren2(List<Node> a, List<Node> b, Context context) {
    var aLength = a.length;
    var bLength = b.length;

    final minLength = aLength < bLength ? aLength : bLength;

    var start = 0;

    while (start < minLength) {
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
          removeChild(a[i], context);
        }
      }
    } else if (start == aLength) {
      for (var i = start; i < b.length; i++) {
        insertBefore(b[i], null, context);
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
          insertBefore(b[i], aEndRef, context);
        }
      } else if (bEnd == start) {
        for (var i = start; i < aEnd; i++) {
          removeChild(a[i], context);
        }
      } else {
        aLength = aEnd - start;
        bLength = bEnd - start;

        final sources = new List<int>.filled(bLength, -1);

        var moved = false;
        var removeOffset = 0;

        // when both lists are small, the join operation is much
        // faster with simple MxN list search instead of hashmap join
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
              removeChild(aNode, context);
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
              removeChild(aNode, context);
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
              insertBefore(node, next, context);
            } else {
              if (j < 0 || i != seq[j]) {
                final pos = i + start;
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
              final pos = i + start;
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
}

/// Algorithm that finds longest increasing subsequence.
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
