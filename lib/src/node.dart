// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

/// Abstract [Node] class
abstract class Node<T extends html.Node> {
  /// Key is used in matching algorithm to identify node positions in children
  /// lists.
  ///
  /// Key should be unique amongst its siblings.
  final Object key;

  /// Reference to the actual html Node.
  T ref;

  /// [Node] constructor.
  Node(this.key);

  /// Create root-level html Node.
  ///
  /// Do not add attributes, or styles to the created Node here.
  /// Attributes, or styles should be added in the [render] method, because
  /// [Node] can be mounted on top of existing html Node with [mount] method.
  void create(Context context);

  /// Mount on top of existing html Node.
  void mount(T node, Context context) {
    ref = node;
  }

  /// Render attributes, styles, classes, children, etc.
  void render(Context context) {}

  /// Update attributes, styles, clasess, children, etc.
  void update(Node other, Context context) {
    other.ref = ref;
  }

  /// Remove node
  void dispose(Context context) {
    ref.remove();
    if (context.isAttached) {
      detached();
    }
  }

  /// [Node] were inserted into the [Container] inside of the attached
  /// [Context].
  void attached() {}

  /// [Node] were removed from the [Container] inside of the attached
  /// [Context].
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
