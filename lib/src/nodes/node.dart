// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;

/// Abstract [Node] class
abstract class Node {
  /// Key used in matching algorithm to identify node positions in children lists.
  /// Key should be unique among its siblings.
  final Object key;

  const Node(this.key);

  /// Run diff against [other] [Node]
  NodePatch diff(Node other);

  /// Render [html.Node]
  html.Node render();
}
