// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.svg.svg;

import 'dart:svg' as svg;
import '../node.dart';
import '../context.dart';
import 'element.dart';

class VSvgSvg extends VSvgElement<svg.SvgSvgElement> {
  VSvgSvg(
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
    ref = new svg.SvgSvgElement();
  }
}
