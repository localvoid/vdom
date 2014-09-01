// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;

/**
 * [VElementPatch]
 */
class VElementPatch extends VNodePatch {
  final MapPatch attributesPatch;
  final MapPatch stylesPatch;
  final UnorderedListPatch classListPatch;
  final VElementChildrenPatch childrenPatch;

  VElementPatch(this.attributesPatch, this.stylesPatch, this.classListPatch,
      this.childrenPatch);

  void apply(html.Element node) {
    if (childrenPatch != null) {
      _applyChildrenPatch(childrenPatch, node);
    }
    if (attributesPatch != null) {
      _applyAttributesPatch(attributesPatch, node);
    }
    if (classListPatch != null) {
      _applyClassListPatch(classListPatch, node);
    }
    if (stylesPatch != null) {
      _applyStylesPatch(stylesPatch, node);
    }
  }
}

/**
 * [VElementChildrenPatch] contains modifications to the childNodes list.
 *
 * Child Nodes Patch should be executed in the following order:
 *
 * - save references to all [removedPositions] nodes
 * - save references to all [movedPositions] source and target nodes
 * - remove elements using saved references
 * - move elements using saved references
 * - insert [insertedNodes] nodes at [insertedPositions]
 * - apply patch recursively on [modifiedNodes] at [modifiedPositions]
 */
class VElementChildrenPatch {
  /**
   * [removedPositions] is a list of positions to the nodes from the source
   * childNodes list that should be removed.
   */
  final List<int> removedPositions;

  /**
   * [movedPositions] is a list of positions to the nodes from the source
   * childNodes list followed by the position of the element that should be
   * be next to it, the target position is also from the source childNodes
   * list.
   *
   * Here is an example on how to retrieve source and target locations
   *
   * ```dart
   *     for (var i = 0; i < movedPositions.length / 2; i++) {
   *       final offset = i * 2;
   *       final source = movedPositions[offset];
   *       final target = movedPositions[offset + 1];
   *     }
   * ```
   *
   * Target locations isn't an exact position where the item should be
   * placed, it is a position of the next element. So, before applying this
   * patch it is necessary to save all references and then just insert source
   * nodes before target nodes. If target node is equal to `-1`, the node
   * should be appended to the list.
   *
   * Modifications should be applied by traversing source/target list from left
   * to right.
   *
   * It is stored in such bizarre way to make diff algorithm slightly more
   * efficient without calculating their target positions after moving previous
   * item.
   *
   */
  final List<int> movedPositions;

  /**
   * [insertedNodes] is a list of new [VNode] objects that should be placed at
   * the corresponding positions from the [insertedPositions] list.
   */
  final List<html.Node> insertedNodes;

  /**
   * [insertedPositions] is a list of positions where new [VNode] objects
   * should be placed.
   */
  final List<int> insertedPositions;

  /**
   * [modifiedNodes] is a list of [VNodePatch] patches that should be applied
   * recursively to the nodes at the corresponding positions from the
   * [modifiedPositions] list.
   */
  final List<VNodePatch> modifiedNodes; // TODO: rename to modifiedPatches?

  /**
   * [modifiedPositions] is a list of positions to the modified nodes.
   */
  final List<int> modifiedPositions;

  VElementChildrenPatch(this.removedPositions, this.movedPositions,
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
  classes.removeAll(patch.removed);
  classes.addAll(patch.inserted);
}

void _applyChildrenPatch(VElementChildrenPatch patch, html.Node node) {
  final children = node.childNodes;
  final removedPositions = patch.removedPositions;
  final movedPositions = patch.movedPositions;
  final insertedNodes = patch.insertedNodes;
  final insertedPositions = patch.insertedPositions;
  final modifiedNodes = patch.modifiedNodes;
  final modifiedPositions = patch.modifiedPositions;

  if (modifiedPositions != null) {
    for (var i = 0; i < modifiedPositions.length; i++) {
      final vNode = modifiedNodes[i];
      final node = children[modifiedPositions[i]];
      vNode.apply(node);
    }
  }

  if (removedPositions != null) {
    final removedElements = new List(removedPositions.length);
    for (var i = 0; i < removedPositions.length; i++) {
      removedElements[i] = children[removedPositions[i]];
    }
    for (var el in removedElements) {
      el.remove();
    }
  }

  if (movedPositions != null) {
    final moveOperationsCount = movedPositions.length >> 1;
    final moveSources = new List(moveOperationsCount);
    final moveTargets = new List(moveOperationsCount);

    for (var i = 0; i < moveOperationsCount; i++) {
      final offset = i << 1;
      final source = movedPositions[offset];
      final target = movedPositions[offset + 1];
      moveSources[i] = children[source];
      moveTargets[i] = target != -1 ? children[target] : -1;
    }

    for (var i = 0; i < moveOperationsCount; i++) {
      final source = moveSources[i];
      final target = moveTargets[i];

      if (target != -1) {
        node.insertBefore(source, target);
      } else {
        node.append(source);
      }
    }
  }

  if (insertedPositions != null) {
    for (var i = 0; i < insertedPositions.length; i++) {
      final newNode = insertedNodes[i];
      final nextPosition = insertedPositions[i];

      if (nextPosition != children.length) {
        node.insertBefore(newNode, children[nextPosition]);
      } else {
        node.append(newNode);
      }
    }
  }
}
