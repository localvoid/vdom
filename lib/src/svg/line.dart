// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.svg.line;

import 'dart:svg' as svg;
import '../context.dart';
import '../node.dart';
import 'shape.dart';

class VSvgLine extends VSvgShapeElement<svg.LineElement> {
  final int x1;
  final int x2;
  final int y1;
  final int y2;

  VSvgLine(
      {Object key,
       this.x1,
       this.x2,
       this.y1,
       this.y2,
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
    ref = new svg.LineElement();
  }

  void render(Context context) {
    super.render(context);

    if (x1 != null) {
      ref.setAttribute('x1', x1.toString());
    }

    if (x2 != null) {
      ref.setAttribute('x2', x2.toString());
    }

    if (y1 != null) {
      ref.setAttribute('y1', y1.toString());
    }

    if (y2 != null) {
      ref.setAttribute('y2', y2.toString());
    }
  }

  void update(VSvgLine other, Context context) {
    super.update(other, context);

    if (x1 != other.x1) {
      ref.setAttribute('x1', other.x1.toString());
    }

    if (x2 != other.x2) {
      ref.setAttribute('x2', other.x2.toString());
    }

    if (y1 != other.y1) {
      ref.setAttribute('y1', other.y1.toString());
    }

    if (y2 != other.y2) {
      ref.setAttribute('y2', other.y2.toString());
    }
  }
}
