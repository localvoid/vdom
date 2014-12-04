// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

/// Abstract [VNode] class
///
/// Lifecycle:
/// - create() -> init() -> attached() -> render() -> update() -> detached()
/// - mount() -> init() -> attached() -> update() -> detached()
abstract class VNode<T extends html.Node> {
  /// Key is used in matching algorithm to identify node positions in children
  /// lists.
  ///
  /// Key should be unique amongst its siblings.
  final Object key;

  /// Reference to the actual html Node.
  T ref;

  /// [VNode] constructor.
  VNode(this.key);

  /// Create root-level html Node.
  void create(VContext context);

  /// Mount on top of existing html Node
  void mount(T node, VContext context) { this.ref = node; }

  /// Initialize node
  void init() {}

  /// Render attributes, styles, classes, children, etc.
  void render(VContext context) {}

  /// Update attributes, styles, clasess, children, etc.
  void update(VNode other, VContext context) { other.ref = ref; }

  /// Remove node
  void dispose(VContext context) {
    ref.remove();
    if (context.isAttached) {
      detached();
    }
  }

  /// [VNode] were inserted into the [VContainer] inside of the attached
  /// [VContext].
  void attached() {}

  /// [VNode] were removed from the [VContainer] inside of the attached
  /// [VContext].
  void detached() {}

  /// [attach] method should be called when [VNode] is attached to the attached
  /// [VContext] after it is rendered.
  ///
  /// ```dart
  /// var n = new Node();
  /// n.create();
  /// n.render();
  /// document.body.append(n.ref);
  /// n.attach();
  /// ```
  ///
  /// If [VNode] is attached before render method is executed, it is better
  /// to call [attached] method directly.
  ///
  /// ```dart
  /// var n = new Node();
  /// n.create();
  /// document.body.append(n.ref);
  /// n.attached();
  /// n.render();
  /// ```
  void attach() { attached(); }

  /// Check if [other] [VNode] has the same type and it can be updated,
  /// it is used when children list is using implicit keys.
  bool sameType(VNode other) => runtimeType == other.runtimeType;
}
