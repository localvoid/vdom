// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.svg.rect;

import 'dart:svg' as svg;
import '../context.dart';
import '../node.dart';
import 'shape.dart';

class VSvgRect extends VSvgShapeElement<svg.RectElement> {
  final int x;
  final int y;
  final int width;
  final int height;
  final int rx;
  final int ry;

  VSvgRect(
      {Object key,
       this.x,
       this.y,
       this.width,
       this.height,
       this.rx,
       this.ry,
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
    ref = new svg.RectElement();
  }

  void render(Context context) {
    super.render(context);

    if (x != null) {
      ref.setAttribute('x', x.toString());
    }

    if (y != null) {
      ref.setAttribute('y', y.toString());
    }

    if (width != null) {
      ref.setAttribute('width', width.toString());
    }

    if (height != null) {
      ref.setAttribute('height', height.toString());
    }

    if (rx != null) {
      ref.setAttribute('rx', rx.toString());
    }

    if (ry != null) {
      ref.setAttribute('ry', ry.toString());
    }
  }

  void update(VSvgRect other, Context context) {
    super.update(other, context);

    if (x != other.x) {
      ref.setAttribute('x', other.x.toString());
    }

    if (y != other.y) {
      ref.setAttribute('y', other.y.toString());
    }

    if (width != other.width) {
      ref.setAttribute('width', other.width.toString());
    }

    if (height != other.height) {
      ref.setAttribute('height', other.height.toString());
    }

    if (rx != other.rx) {
      ref.setAttribute('rx', other.rx.toString());
    }

    if (ry != other.ry) {
      ref.setAttribute('ry', other.ry.toString());
    }
  }
}
