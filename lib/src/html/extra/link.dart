// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.extra.link;

import 'dart:html' as html;
import '../../context.dart';
import '../../node.dart';
import '../element.dart';

/// Virtual DOM Anchor Element helper for links.
class VLink extends VHtmlElement<html.AnchorElement> {
  final String href;
  final String title;

  VLink({
    Object key,
    this.href,
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

  void create(Context context) { ref = new html.AnchorElement(); }

  void render(Context context) {
    super.render(context);
    if (href != null) {
      ref.href = href;
    }
    if (title != null) {
      ref.title = title;
    }
  }

  void update(VLink other, Context context) {
    super.update(other, context);
    if (other.href != href) {
      ref.href = other.href;
    }
    if (other.title != title) {
      ref.title = other.title;
    }
  }
}
