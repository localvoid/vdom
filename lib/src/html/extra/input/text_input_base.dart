// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.extra.text_input_base;

import '../../../context.dart';
import 'value_input_base.dart';

/// Base class for Input Elements that contains text value
abstract class VTextInputBase extends VValueInputBase {
  final String placeholder;
  final int maxLength;

  VTextInputBase({
    Object key,
    String value,
    bool disabled,
    this.placeholder,
    this.maxLength,
    bool autofocus,
    String id,
    String type,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : super(
        key: key,
        value: value,
        disabled: disabled,
        autofocus: autofocus,
        id: id,
        type: type,
        attributes: attributes,
        classes: classes,
        styles: styles);

  void render(Context context) {
    super.render(context);
    if (placeholder != null) {
      ref.placeholder = placeholder;
    }
    if (maxLength != null) {
      ref.maxLength = maxLength;
    }
  }

  void update(VTextInputBase other, Context context) {
    super.update(other, context);
    if (other.placeholder != placeholder) {
      ref.placeholder = other.placeholder;
    }
    if (other.maxLength != maxLength) {
      ref.maxLength = other.maxLength;
    }
  }
}
