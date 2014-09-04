// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;

/**
 * Virtual Dom Element
 */
class VElement extends VNode {
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
  List<VNode> children;

  /**
   * Create a new [VElement]
   */
  VElement(String key, this.tag, [this.children = null]) : super(key);

  /**
   * Run diff against [other] [VElement]
   */
  VElementPatch diff(VElement other) {
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

    return new VElementPatch(
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

VElementChildrenPatch _diffChildren(List<VNode> a, List<VNode> b) {
  if (a != null && a.length > 0) {
    if (b == null || b.length == 0) {
      // all childrens from list [a] were removed
      final aLength = a.length;

      final removedPositions = new List(aLength);
      for (var i = 0; i < aLength; i++) {
        removedPositions[i] = i;
      }
      return new VElementChildrenPatch(
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
            return new VElementChildrenPatch(
                null,
                null,
                null,
                null,
                [modified],
                [0]);
          }
          return null;
        }
        return new VElementChildrenPatch([0], null, [bNode.render()], [0], null, null);
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
        return new VElementChildrenPatch(
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
        return new VElementChildrenPatch(
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
    return new VElementChildrenPatch(
        null,
        null,
        insertedNodes,
        insertedPositions,
        null,
        null);
  }

  return null;
}

VElementChildrenPatch _diffChildren2(List<VNode> a, List<VNode> b) {
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
    final keyIndex = new HashMap<String, VNode>();
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
    // create new lists without removed/inserted nodes
    // and use position ids instead of vnodes
    final a2 = new List<int>(a.length - removedPositions.length);
    final b2 = new List<int>(a.length - removedPositions.length);

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
        if (insertedOffset > 0) {
          node.target -= insertedOffset;
        }
        b2[i - insertedOffset] = i;
        a2[node.source] = i;
      }
    }

    final myersDiff = new ChildrenPositionsDiff(a2, b2, b);
    movedPositions = myersDiff.run();
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

  return new VElementChildrenPatch(
      removedPositions.isEmpty ? null : removedPositions,
      movedPositions,
      insertedNodes.isEmpty ? null : insertedNodes,
      insertedPositions.isEmpty ? null : insertedPositions,
      modifiedNodes.isEmpty ? null : modifiedNodes,
      modifiedPositions.isEmpty ? null : modifiedPositions);
}

/**
 * Algorithm that finds Shortest Edit Script that transform positions from
 * children list A into children list B.
 *
 * It is a slight modification of Myer's diff algorithm.
 *
 * For small lists (lower than [ForwardThreshold]) forward greedy algorithm is
 * used, and for larger lists recursive linear algorithm is used.
 */
class ChildrenPositionsDiff {
  static const ForwardThreshold = 100;

  final List<int> a, b;
  final List<VNode> _nodes;
  final List<int> _result = [];

  ChildrenPositionsDiff(this.a, this.b, this._nodes);

  List<int> run() {
    if (a.length < ForwardThreshold) {
      return runForward();
    }
    return runLinear();
  }

  List<int> runForward() {
    var v = _forwardLCS();
    _solveForward(v);
    return _result;
  }

  List<int> runLinear() {
    _linear(0, 0, a.length, a.length);
    return _result;
  }

  void _insert(int x) {
    var n = _nodes[b[x]];
    var t;
    if (x + 1 == a.length) {
      t = -1;
    } else {
      t = _nodes[b[x + 1]].source;
    }
    _result.add(n.source);
    _result.add(t);
  }

  List<List<int>> _forwardLCS() {
    int N = a.length;

    var Vc = [0, 0];
    var Vs = [];

    int iStart = 0;
    int iEnd = 0;

    for (int d = 0; d <= 2 * N; d++) {
      final Vp = Vc;
      final iOutOfBounds = iStart + iEnd;
      final ixStart = iStart;
      final ipStart = Vp[0];
      Vc = new List<int>(d + 2 - iOutOfBounds);
      Vc[0] = iStart;
      Vs.add(Vc);

      for (var i = iStart; i <= d - iEnd; i++) {
        final j = i << 1;
        final k = -d + j;

        int ip;

        int x;
        int y;

        if (i == 0 || i != d && Vp[i - 1 - ipStart + 1] < Vp[i - ipStart + 1]) {
          ip = i;
          x = Vp[ip - ipStart + 1];
        } else {
          ip = i - 1;
          x = Vp[ip - ipStart + 1] + 1;
        }

        final kPrev = ((ip << 1) - (d - 1));
        y = x - k;

        while (x < N && y < N && a[x] == b[y]) {
          x++;
          y++;
        }

        Vc[i - ixStart + 1] = x;

        if (x > N) {
          iEnd++;
        } else if (y > N) {
          iStart++;
        }

        if (x >= N && y >= N) {
          return Vs;
        }
      }
    }
    return Vs;
  }

  void _solveForward(List<List<int>> Vs) {
    final N = a.length;

    var x = N;
    var y = N;

    for (int d = Vs.length - 1; (d > 0) && (x > 0 || y > 0); d--) {
      final Vc = Vs[d];
      final Vp = Vs[d - 1];
      final icOff = 1 - Vc[0];
      final ipOff = 1 - Vp[0];

      final k = x - y;
      final i = (k + d) >> 1;

      bool down = (i == 0 || (i != d && Vp[ipOff + i - 1] < Vp[ipOff + i]));
      final ip = down ? i : i - 1;
      final kp = ((ip << 1) - (d - 1));

      x = Vp[ipOff + ip];
      y = x - kp;

      if (down) {
        _insert(y);
      }
    }
  }

  int _findMiddleSnake(int aOff, int bOff, int aLength, int bLength,
      _MiddleSnake out) {
    int delta = aLength - bLength;
    int front = delta & 1;
    int maxD = (aLength + bLength + 1) ~/ 2;

    // middle snake
    int msx, msy, msu, msv;

    // forward and reverse V arrays
    int vOff = maxD;
    int vLength = vOff << 1 + 1;
    final vf = new List<int>(vLength);
    final vr = new List<int>(vLength);

    vf[vOff + 1] = 0;
    vr[vOff + 1] = 0;

    int kfStart = 0;
    int kfEnd = 0;
    int krStart = 0;
    int krEnd = 0;

    for (int d = 0; d <= maxD; d++) {
      // forward
      for (int k = -d + kfStart; k <= d - kfEnd; k += 2) {
        int kOff = k + vOff;
        int x, y;

        if (k == -d || (k != d && vf[kOff - 1] < vf[kOff + 1])) { // down
          x = vf[kOff + 1];
        } else {
          x = vf[kOff - 1] + 1;
        }
        y = x - k;

        msx = x;
        msy = y;

        while (x < aLength && y < bLength && a[aOff + x] == b[bOff + y]) {
          x++;
          y++;
        }

        vf[kOff] = x;

        if (x > aLength) {
          kfEnd += 2;
        } else if (y > bLength) {
          kfStart += 2;
        } else if (front == 1) {
          int krOff = vOff + delta - k;
          if (krOff >= 0 && krOff < vLength && vr[krOff] != null) {
            int xr = aLength - vr[krOff];
            if (x >= xr) {
              out.x = msx;
              out.y = msy;
              out.u = x;
              out.v = y;
              return (d << 1) - 1;
            }
          }
        }
      }

      // backward
      for (int k = -d + krStart; k <= d - krEnd; k += 2) {
        int kOff = k + vOff;
        int x, y;

        if (k == -d || (k != d && vr[kOff - 1] < vr[kOff + 1])) { // down
          x = vr[kOff + 1];
        } else {
          x = vr[kOff - 1] + 1;
        }
        y = x - k;

        msu = x;
        msv = y;

        while (x < aLength &&
            y < bLength &&
            a[aOff + aLength - x - 1] == b[bOff + bLength - y - 1]) {
          x++;
          y++;
        }

        vr[kOff] = x;
        if (x > aLength) {
          krEnd += 2;
        } else if (y > bLength) {
          krStart += 2;
        } else if (front == 0) {
          int kfOff = vOff + delta - k;
          if (kfOff >= 0 && kfOff < vLength && vf[kfOff] != null) {
            int x1 = vf[kfOff];
            int y1 = vOff + x1 - kfOff;
            int x2 = aLength - x;
            if (x1 >= x2) {
              out.x = x2;
              out.y = bLength - y;
              out.u = aLength - msu;
              out.v = bLength - msv;

              return d << 1;
            }
          }
        }
      }
    }

    return -1; // error
  }

  void _linear(int aOff, int bOff, int n, int m) {
    int d;
    if (n == 0) {
      for (var i = m - 1; i >= 0; i--) {
        _insert(bOff + i);
      }
    } else {
      var s = new _MiddleSnake();
      int d = _findMiddleSnake(aOff, bOff, n, m, s);

      if (d > 1) {
        _linear(aOff + s.u, bOff + s.v, n - s.u, m - s.v);
        _linear(aOff, bOff, s.x, s.y);
      } else if (d == 1) {
        int x = s.x;
        int u = s.u;

        if (m > n) {
          if (x == u) {
            _insert(bOff + (m - 1));
          } else {
            _insert(bOff);
          }
        }
      }
    }
  }
}

/**
 * Middle Snake for linear Myer's Diff algorithm.
 */
class _MiddleSnake {
  int x, y, u, v;
}
