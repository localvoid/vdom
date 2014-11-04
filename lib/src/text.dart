// Copyright (c) 2014, the vsync project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

/// Virtual Text Node.
class Text extends Node {
  /// Text data
  String data;

  /// Create a new [Text]
  Text(Object key, this.data) : super(key);

  /// Run diff against [other] [Text]
  void sync(Text other, [bool isAttached = false]) {
    other.ref = ref;
    if (data != other.data) {
      (ref as html.Text).data = other.data;
    }
  }

  /// Render [html.Text]
  html.Text render() {
    final n = new html.Text(data);
    ref = n;
    return n;
  }

  String toString() => '$data';
}
