// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
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

  /// Create html Node
  void create(Context context);

  /// Mount on top of existing Node
  void mount(html.Node node, Context context) {
    ref = node;
  }

  /// Render contents
  void render(Context context) {}

  void update(Node other, Context context);

  void dispose(Context context) {
    ref.remove();
    if (context.isAttached) {
      detached();
    }
  }

  void attached() {}
  void detached() {}

  void attach() {}
  void detach() {}
}

void inject(Node n, html.Node parent, Context context) {
  n.create(context);
  parent.append(n.ref);
  if (context.isAttached){
    n.attached();
  }
  n.render(context);
}

void injectBefore(Node n, html.Node parent, html.Node nextRef, Context context) {
  n.create(context);
  parent.insertBefore(n.ref, nextRef);
  if (context.isAttached){
    n.attached();
  }
  n.render(context);
}
