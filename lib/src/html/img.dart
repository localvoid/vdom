// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.img;

import 'dart:html' as html;
import '../context.dart';
import '../node.dart';
import 'element.dart';

/// Virtual DOM Image Element helper for images.
class VImg extends VHtmlElement<html.ImageElement> {
  final String src;
  final String alt;
  final String title;

  VImg({
    Object key,
    this.src,
    this.alt,
    this.title,
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

  void create(Context context) { ref = new html.ImageElement(); }

  void render(Context context) {
    super.render(context);
    if (src != null) {
      ref.src = src;
    }
    if (alt != null) {
      ref.alt = alt;
    }
    if (title != null) {
      ref.title = title;
    }
  }

  void update(VImg other, Context context) {
    super.update(other, context);
    if (other.src != src) {
      ref.src = other.src;
    }
    if (other.alt != alt) {
      ref.alt = other.alt;
    }
    if (other.title != title) {
      ref.title = other.title;
    }
  }
}
