// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.extra.input.checked_input_base;

import 'dart:html' as html;
import '../../../context.dart';
import '../../element.dart';

/// Base class for Input Elements with [checked] property.
abstract class VCheckedInputBase extends VHtmlElement<html.InputElement> {
  final bool _checked;
  final bool disabled;

  bool get checked => ref.checked;

  VCheckedInputBase({
    Object key,
    bool checked,
    this.disabled,
    String id,
    String type,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : _checked = checked,
      super(
        key: key,
        children: null,
        id: id,
        type: type,
        attributes: attributes,
        classes: classes,
        styles: styles);

  void render(Context context) {
    super.render(context);
    if (_checked != null) {
      ref.checked = _checked;
    }
    if (disabled != null) {
      ref.disabled = disabled;
    }
  }

  void update(VCheckedInputBase other, Context context) {
    super.update(other, context);
    if (other._checked != null && ref.checked != other._checked) {
      ref.checked = other._checked;
    }
    if (other.disabled != null && ref.disabled != other.disabled) {
      ref.disabled = other.disabled;
    }
  }
}
