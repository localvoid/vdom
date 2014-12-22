// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.extra.check_box;

import 'dart:html' as html;
import '../../context.dart';
import '../element.dart';

/// Virtual DOM CheckBox Element
class VCheckBox extends VHtmlElement<html.CheckboxInputElement> {
  final bool _checked;

  bool get checked => ref.checked;

  VCheckBox({
    Object key,
    bool checked,
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

  void create(Context context) { ref = new html.CheckboxInputElement(); }

  void render(Context context) {
    super.render(context);
    if (_checked != null) {
      ref.checked = _checked;
    }
  }

  void update(VCheckBox other, Context context) {
    super.update(other, context);
    if (other._checked != null && ref.checked != other._checked) {
      ref.checked = other._checked;
    }
  }
}
