// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.extra.input.slider;

import 'dart:html' as html;
import '../../../context.dart';
import 'value_input_base.dart';

/// Virtual Html Element `<input type="range">`
class VSlider extends VValueInputBase {
  final int max;
  final int min;
  final int step;

  VSlider({
    Object key,
    String value,
    this.max,
    this.min,
    this.step,
    bool disabled,
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

  void create(Context context) { ref = new html.InputElement(type: 'range'); }

  void render(Context context) {
    super.render(context);
    if (max != null) {
      ref.max = max.toString();
    }
    if (min != null) {
      ref.min = min.toString();
    }
    if (step != null) {
      ref.step = step.toString();
    }
  }

  void update(VSlider other, Context context) {
    super.update(other, context);
    if (max != other.max) {
      ref.max = other.max.toString();
    }
    if (min != other.min) {
      ref.min = other.min.toString();
    }
    if (step != other.step) {
      ref.step = other.step.toString();
    }
  }
}
