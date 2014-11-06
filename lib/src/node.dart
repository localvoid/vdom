// Copyright (c) 2014, the vsync project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

/// Abstract [Node] class
abstract class Node {
  /// Key is used in matching algorithm to identify node positions in children
  /// lists.
  ///
  /// Key should be unique among its siblings.
  final Object key;
  html.Node ref;

  Node(this.key);

  void sync(Node other, bool isAttached);

  html.Node render();

  void inject(html.Element container, bool isAttached);
  void injectBefore(html.Element container, html.Node nextRef,
                    bool isAttached);

  void dispose(bool isAttached) {
    ref.remove();
    if (isAttached) {
      detached();
    }
  }

  void attached() {}
  void detached() {}

  void propagateAttached() {}
  void propagateDetached() {}
}
