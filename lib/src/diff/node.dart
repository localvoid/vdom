// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.diff;

/// Abstract [Node] class
abstract class Node {
  /// Key is used in matching algorithm to identify node positions in children
  /// lists.
  ///
  /// Key should be unique among its siblings.
  final Object key;

  Node(this.key);

  /// Create html Node
  html.Node create(Context context);

  /// Render contents
  void render(html.Node ref, Context context) {}

  NodePatch diff(Node other);

  void attached() {}
  void detached() {}
}
