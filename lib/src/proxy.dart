// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

abstract class VNodeProxy<T extends html.Node, E extends VNode> implements VNode<T> {
  final E node;

  Object get key => node.key;
  T get ref => node.ref;
  set ref(T newRef) {
    node.ref = newRef;
  }

  VNodeProxy(this.node);

  void create(Context context) {
    node.create(context);
  }

  void render(Context context) {
    node.render(context);
  }

  void update(VNode other, Context context) {
    node.update(other, context);
  }

  void dispose(Context context) {
    node.dispose(context);
  }

  void attached() { node.attached(); }
  void detached() { node.detached(); }
}
