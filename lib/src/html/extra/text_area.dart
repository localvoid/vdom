// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.extra.text_area;

import 'dart:html' as html;
import '../../context.dart';
import '../element.dart';

/// Virtual Html Element `<textarea>`
class VTextArea extends VHtmlElement<html.TextAreaElement> {
  final String _value;
  final String placeholder;
  final bool autofocus;

  String get value => ref.value;

  VTextArea({
    Object key,
    String value,
    this.placeholder,
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

  void create(Context context) { ref = new html.TextAreaElement(); }

  void render(Context context) {
    super.render(context);
    if (_value != null) {
      ref.value = _value;
    }
    if (placeholder != null) {
      ref.placeholder = placeholder;
    }
    if (autofocus != null) {
      ref.autofocus = autofocus;
    }
  }

  void update(VTextArea other, Context context) {
    super.update(other, context);
    if (other._value != null && ref.value != other._value) {
      ref.value = other._value;
    }
    if (other.placeholder != placeholder) {
      ref.placeholder = other.placeholder;
    }
    // no need to update autofocus when element is already created.
  }
}
