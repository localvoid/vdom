// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;

/// [TextPatch]
class TextPatch extends NodePatch {
  final String newData;

  TextPatch(this.newData);

  void apply(html.Text node, [bool isAttached = false]) {
    node.data = newData;
  }
}
