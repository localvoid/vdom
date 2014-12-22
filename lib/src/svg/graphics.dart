// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.svg.graphics;

import 'dart:html' as html;
import '../node.dart';
import 'element.dart';

abstract class VSvgGraphicsElement<T extends html.Element> extends VSvgElement<T> {
  final String color;
  final String fill;
  final num fillOpacity;
  final num opacity;
  final String stroke;
  final num strokeOpacity;
  final num strokeWidth;

  VSvgGraphicsElement(
      {Object key,
       this.color,
       this.fill,
       this.fillOpacity,
       this.opacity,
       this.stroke,
       this.strokeOpacity,
       this.strokeWidth,
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
}
