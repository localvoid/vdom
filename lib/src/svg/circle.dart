// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.svg.circle;

import 'dart:svg' as svg;
import '../context.dart';
import '../node.dart';
import 'shape.dart';

class VSvgCircle extends VSvgShapeElement<svg.CircleElement> {
  final int cx;
  final int cy;
  final int r;

  VSvgCircle(
      {Object key,
       this.cx,
       this.cy,
       this.r,
       String transform,
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
          transform: transform,
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

  void create(Context context) {
    ref = new svg.CircleElement();
  }

  void render(Context context) {
    super.render(context);

    if (cx != null) {
      ref.setAttribute('cx', cx.toString());
    }

    if (cy != null) {
      ref.setAttribute('cy', cy.toString());
    }

    if (r != null) {
      ref.setAttribute('r', r.toString());
    }
  }

  void update(VSvgCircle other, Context context) {
    super.update(other, context);

    if (cx != other.cx) {
      ref.setAttribute('cx', other.cx.toString());
    }

    if (cy != other.cy) {
      ref.setAttribute('cy', other.cy.toString());
    }

    if (r != other.r) {
      ref.setAttribute('r', other.r.toString());
    }
  }
}
