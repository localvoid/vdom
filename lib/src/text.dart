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
  void sync(Text other, bool isAttached) {
    other.ref = ref;
    if (data != other.data) {
      (ref as html.Text).data = other.data;
    }
  }

  /// Render [html.Text]
  html.Text render() {
    ref = new html.Text(data);
    return ref;
  }

  /// Inject into container
  void inject(html.Element container, bool isAttached) {
    ref = new html.Text(data);
    container.append(ref);
  }

  /// Inject into container before [nextRef] node
  void injectBefore(html.Element container, html.Node nextRef,
                    bool isAttached) {
    ref = new html.Text(data);
    container.insertBefore(ref, nextRef);
  }

  String toString() => '$data';
}
