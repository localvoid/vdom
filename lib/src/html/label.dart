// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.label;

import 'dart:html' as html;
import '../context.dart';
import '../node.dart';
import 'element.dart';

/// Virtual DOM Label Element
class VLabel extends VHtmlElement<html.LabelElement> {
  final String htmlFor;

  VLabel({
    Object key,
    this.htmlFor,
    List<VNode> children,
    String id,
    String type,
    Map<String, String> attributes,
    List<String> classes,
    Map<String, String> styles})
    : super(
        key: key,
        children: children,
        id: id,
        type: type,
        attributes: attributes,
        classes: classes,
        styles: styles);

  void create(Context context) { ref = new html.LabelElement(); }

  void render(Context context) {
    super.render(context);
    if (htmlFor != null) {
      ref.htmlFor = htmlFor;
    }
  }

  void update(VLabel other, Context context) {
    super.update(other, context);
    if (other.htmlFor != htmlFor) {
      ref.htmlFor = other.htmlFor;
    }
  }
}
