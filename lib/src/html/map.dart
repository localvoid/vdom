// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.map;

import 'dart:html' as html;
import '../context.dart';
import '../node.dart';
import 'element.dart';

/// Virtual DOM Map Element.
class VMap extends VHtmlElement<html.MapElement> {
  final String name;

  VMap({
    Object key,
    this.name,
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

  void create(Context context) { ref = new html.MapElement(); }

  void render(Context context) {
    super.render(context);
    if (name != null) {
      ref.name = name;
    }
  }

  void update(VMap other, Context context) {
    super.update(other, context);
    if (other.name != name) {
      ref.name = other.name;
    }
  }
}
