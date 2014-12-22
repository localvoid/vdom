// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.svg.polygon;

import 'dart:svg' as svg;
import '../context.dart';
import '../node.dart';
import 'shape.dart';

class VSvgPolygon extends VSvgShapeElement<svg.PolygonElement> {
  final String points;

  VSvgPolygon(
      {Object key,
       this.points,
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
    ref = new svg.PolygonElement();
  }

  void render(Context context) {
    super.render(context);

    if (points != null) {
      ref.setAttribute('points', points);
    }
  }

  void update(VSvgPolygon other, Context context) {
    super.update(other, context);

    if (points != other.points) {
      ref.setAttribute('points', other.points);
    }
  }
}
