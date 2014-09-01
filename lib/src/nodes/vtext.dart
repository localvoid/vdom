// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;

/**
 * Virtual Text Node.
 */
class VText extends VNode {
  /**
   * Text data
   */
  String data;

  /**
   * Create a new [VText]
   */
  VText(String key, this.data) : super(key);

  /**
   * Run diff against [other] [VElement]
   */
  VTextPatch diff(VText other) {
    if (data == other.data) {
      return null;
    }
    return new VTextPatch(other.data);
  }

  /**
   * Render [html.Text]
   */
  html.Text render() {
    return new html.Text(data);
  }

  String toString() => 'VText $key';
}
