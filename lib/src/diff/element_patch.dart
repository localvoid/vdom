// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Comments are outdated.
part of vdom.diff;

/// [ElementPatch]
class ElementPatch extends NodePatch {
  final MapPatch attributesPatch;
  final MapPatch stylesPatch;
  final UnorderedListPatch classListPatch;
  final ElementChildrenPatch childrenPatch;

  ElementPatch(this.attributesPatch, this.stylesPatch, this.classListPatch,
      this.childrenPatch);

  void apply(html.Element node, Context context) {
    if (attributesPatch != null) {
      _applyAttributesPatch(attributesPatch, node);
    }
    if (classListPatch != null) {
      _applyClassListPatch(classListPatch, node);
    }
    if (stylesPatch != null) {
      _applyStylesPatch(stylesPatch, node);
    }
    if (childrenPatch != null) {
      applyChildrenPatch(childrenPatch, node, context);
    }
  }
}

/// [ElementChildrenPatch] contains modifications to the childNodes list.
///
/// [ElementChildrenPatch] should be applied in the following order:
///
/// * save references to all [removedPositions] nodes
/// * save references to all [movedPositions] source and target nodes
/// * remove elements using saved references
/// * move elements using saved references
/// * insert [insertedNodes] nodes at [insertedPositions]
/// * apply patch recursively on [modifiedNodes] at [modifiedPositions]
///
class ElementChildrenPatch {
  final List<Node> removedNodes;

  /// [removedPositions] is a list of positions to the nodes from the source
  /// childNodes list that should be removed.
  final List<int> removedPositions;

  /// [movedPositions] is a list of positions to the nodes from the source
  /// childNodes list followed by the position of the element that should be
  /// be next to it, the target position is also from the source childNodes
  /// list.
  ///
  /// Here is an example on how to retrieve source and target locations
  ///
  /// ```dart
  ///     for (var i = 0; i < movedPositions.length / 2; i++) {
  ///       final offset = i * 2;
  ///       final source = movedPositions[offset];
  ///       final target = movedPositions[offset + 1];
  ///     }
  /// ```
  ///
  /// Target locations isn't an exact position where the item should be
  /// placed, it is a position of the next element. So, before applying this
  /// patch it is necessary to save all references and then just insert source
  /// nodes before target nodes. If target node is equal to `-1`, the node
  /// should be appended to the list.
  ///
  /// Modifications should be applied by traversing source/target list from left
  /// to right.
  ///
  /// It is stored in such bizarre way to make diff algorithm slightly more
  /// efficient without calculating their target positions after moving previous
  /// item.
  ///
  final List<int> movedPositions;

  /// [insertedNodes] is a list of new [Node] objects that should be placed at
  /// the corresponding positions from the [insertedPositions] list.
  final List<Node> insertedNodes;

  /// [insertedPositions] is a list of positions where new [Node] objects
  /// should be placed.
  final List<int> insertedPositions;

  /// [modifiedNodes] is a list of [NodePatch] patches that should be applied
  /// recursively to the nodes at the corresponding positions from the
  /// [modifiedPositions] list.
  final List<NodePatch> modifiedNodes; // TODO: rename to modifiedPatches?

  /// [modifiedPositions] is a list of positions to the modified nodes.
  final List<int> modifiedPositions;

  ElementChildrenPatch(this.removedNodes, this.removedPositions, this.movedPositions,
      this.insertedNodes, this.insertedPositions, this.modifiedNodes,
      this.modifiedPositions);
}

void _applyAttributesPatch(MapPatch patch, html.Element node) {
  final keys = patch.keys;
  final values = patch.values;

  for (var i = 0; i < keys.length; i++) {
    final k = keys[i];
    final v = values[i];
    node.setAttribute(k, v == null ? '' : v);
  }
}

void _applyStylesPatch(MapPatch patch, html.Element node) {
  final keys = patch.keys;
  final values = patch.values;
  final style = node.style;

  for (var i = 0; i < keys.length; i++) {
    final k = keys[i];
    final v = values[i];
    if (v == null) {
      style.removeProperty(k);
    } else {
      style.setProperty(k, v);
    }
  }
}

void _applyClassListPatch(UnorderedListPatch patch, html.Element node) {
  final classes = node.classes;
  if (patch.removed != null) {
    classes.removeAll(patch.removed);
  }
  if (patch.inserted != null) {
    classes.addAll(patch.inserted);
  }
}

void applyChildrenPatch(ElementChildrenPatch patch, html.Node node, Context context) {
  final children = node.childNodes;
  final removedNodes = patch.removedNodes;
  final removedPositions = patch.removedPositions;
  final movedPositions = patch.movedPositions;
  final insertedNodes = patch.insertedNodes;
  final insertedPositions = patch.insertedPositions;
  final modifiedNodes = patch.modifiedNodes;
  final modifiedPositions = patch.modifiedPositions;

  if (removedPositions != null) {
    if (removedPositions.length == children.length) {
      var c = children.first;
      while (c != null) {
        final next = c.nextNode;
        c.remove();
        c = next;
      }
    } else {
      final cached = removedPositions.length > 1 ? new List.from(children) : children;
      for (var i = 0; i < removedPositions.length; i++) {
        cached[removedPositions[i]].remove();
        if (context.isAttached) {
          removedNodes[i].detached();
        }
      }
    }
  }

  if (modifiedPositions != null || movedPositions != null) {
    var isCached = false;
    var cached = children;
    if (modifiedPositions != null && modifiedPositions.length > 16) {
      cached = new List.from(children);
      isCached = true;
    }
    final cachedLength = cached.length;

    if (modifiedPositions != null) {
      for (var i = 0; i < modifiedPositions.length; i++) {
        final vNode = modifiedNodes[i];
        final node = cached[modifiedPositions[i]];
        vNode.apply(node, context);
      }
    }

    if (movedPositions != null) {
      final moveOperationsCount = movedPositions.length >> 1;
      if (moveOperationsCount > 16 && !isCached) {
        cached = new List.from(children);
        for (var i = 0; i < moveOperationsCount; i++) {
          final offset = i << 1;
          final source = cached[movedPositions[offset]];
          final p = movedPositions[offset + 1];
          final target = p < cachedLength ? cached[p] : null;
          node.insertBefore(source, target);
        }
      } else {
        final sources = new List(moveOperationsCount);
        final targets = new List(moveOperationsCount);
        for (var i = 0; i < moveOperationsCount; i++) {
          final offset = i << 1;
          final source = cached[movedPositions[offset]];
          final p = movedPositions[offset + 1];
          final target = p < cachedLength ? cached[p] : null;
          sources[i] = source;
          targets[i] = target;
        }
        for (var i = 0; i < moveOperationsCount; i++) {
          node.insertBefore(sources[i], targets[i]);
        }
      }
    }
  }

  if (insertedPositions != null) {
    if (children.length == 0) {
      for (var i = 0; i < insertedPositions.length; i++) {
        final newNode = insertedNodes[i];
        final e = newNode.create(context);
        node.append(e);
        if (context.isAttached) {
          newNode.attached();
        }
        newNode.render(e, context);
      }
    } else {
      final cachedLength = children.length;
      final insertedPositionsCached = new List(insertedPositions.length);
      for (var i = 0; i < insertedPositions.length; i++) {
        final p = insertedPositions[i];
        insertedPositionsCached[i] = p < cachedLength ? children[p] : null;
      }
      for (var i = 0; i < insertedPositions.length; i++) {
        final newNode = insertedNodes[i];
        final e = newNode.create(context);
        node.insertBefore(e, insertedPositionsCached[i]);
        if (context.isAttached) {
          newNode.attached();
        }
        newNode.render(e, context);
      }
    }
  }
}
