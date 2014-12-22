// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.svg.shape;

import 'dart:html' as html;
import '../context.dart';
import '../node.dart';
import 'graphics.dart';

abstract class VSvgShapeElement<T extends html.Element> extends VSvgGraphicsElement<T> {
  final String transform;

  VSvgShapeElement(
      {Object key,
       this.transform,
       String color,
       String fill,
       num fillOpacity,
       num opacity,
       String stroke,
       num strokeOpacity,
       num strokeWidth,
       List<VNode> children,
       String id,
       String type,
       Map<String, String> attributes,
       List<String> classes,
       Map<String, String> styles})
      : super(
          key: key,
          color: color,
          fill: fill,
          fillOpacity: fillOpacity,
          opacity: opacity,
          stroke: stroke,
          strokeOpacity: strokeOpacity,
          strokeWidth: strokeWidth,
          children: children,
          id: id,
          type: type,
          attributes: attributes,
          classes: classes,
          styles: styles);

  void render(Context context) {
    super.render(context);

    if (transform != null) {
      ref.setAttribute(transform, transform);
    }
  }
}
