// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.svg.generic;

import 'dart:svg' as svg;
import '../context.dart';
import '../node.dart';
import 'element.dart';

/// Virtual Dom Element
class VSvgGenericElement extends VSvgElement<svg.SvgElement> {
  /// [VSvgGenericElement] tag name
  final String tag;

  /// Create a new [VSvgGenericElement]
  VSvgGenericElement(this.tag,
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
    ref = new svg.SvgElement.tag(tag);
  }

  bool sameType(VNode other) =>
      super.sameType(other) && tag == (other as VSvgGenericElement).tag;

  String toString() => '<$tag key="$key">${children.join()}</$tag>';
}
