// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.extra.value_input_base;

import 'dart:html' as html;
import '../../../context.dart';
import '../../element.dart';

/// Virtual DOM Text Input Element
abstract class VValueInputBase extends VHtmlElement<html.InputElement> {
  final String _value;
  final bool disabled;
  final bool autofocus;

  String get value => ref.value;

  VValueInputBase({
    Object key,
    String value,
    this.disabled,
    this.autofocus,
    String id,
    String type,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : _value = value,
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
    if (_value != null) {
      ref.value = _value;
    }
    if (disabled != null) {
      ref.disabled = disabled;
    }
    if (autofocus != null) {
      ref.autofocus = autofocus;
    }
  }

  void update(VValueInputBase other, Context context) {
    super.update(other, context);
    if (other._value != null && ref.value != other._value) {
      ref.value = other._value;
    }
    if (other.disabled != null && ref.disabled != other.disabled) {
      ref.disabled = other.disabled;
    }
    // no need to update autofocus when element is already created.
  }
}
