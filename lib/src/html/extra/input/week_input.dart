// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.extra.week_input;

import 'dart:html' as html;
import '../../../context.dart';
import 'value_input_base.dart';

/// Virtual Html Element `<input type="week">`
class VWeekInput extends VValueInputBase {
  VWeekInput({
    Object key,
    String value,
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

  void create(Context context) { ref = new html.InputElement(type: 'week'); }
}
