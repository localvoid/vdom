// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.sync;

/// Virtual Text Node
class Text extends Node {
  String data;

  Text(Object key, this.data) : super(key);

  void create(Context context) {
    ref = new html.Text(data);
  }

  void update(Text other, Context context) {
    other.ref = ref;
    if (data != other.data) {
      (ref as html.Text).data = other.data;
    }
  }

  String toString() => '$data';
}
