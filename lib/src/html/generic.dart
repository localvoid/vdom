// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.generic;

import 'dart:html' as html;
import '../context.dart';
import '../node.dart';
import 'element.dart';

/// Generic Virtual Html Element
class VHtmlGenericElement extends VHtmlElement<html.Element> {
  /// tag name
  final String tag;

  VHtmlGenericElement(this.tag,
      {Object key,
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

  void create(Context context) {
    ref = new html.Element.tag(tag);
  }

  bool sameType(VNode other) =>
      super.sameType(other) && tag == (other as VHtmlGenericElement).tag;

  String toString() => '<$tag key="$key">${children.join()}</$tag>';
}
