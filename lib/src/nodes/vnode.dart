// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;

/**
 * Abstract [VNode] class
 */
abstract class VNode {
  /**
   * Key used in matching algorithm to identify node positions in children lists.
   * Key should be unique among its siblings.
   */
  final String key;

  /**
   * Used by diff algorithm.
   *
   * TODO: make it private.
   */
  int source = -1;

  /**
   * Used by diff algorithm.
   *
   * TODO: make it private.
   */
  int target = -1;

  VNode(this.key);

  /**
   * Run diff against [other] [VNode]
   */
  VNodePatch diff(VNode other);

  /**
   * Render [html.Node]
   */
  html.Node render();

  String toString() => 'VNode $key';
}
