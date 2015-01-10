// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.html.video;

import 'dart:html' as html;
import '../context.dart';
import '../node.dart';
import 'element.dart';

/// Virtual Html Element `<video>`
class VVideo extends VHtmlElement<html.VideoElement> {
  final String src;
  final String title;
  final bool autoplay;
  final bool controls;
  final bool loop;
  final bool muted;
  final String preload;

  VVideo({
    Object key,
    this.src,
    this.title,
    this.autoplay,
    this.controls,
    this.loop,
    this.muted,
    this.preload,
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

  void create(Context context) { ref = new html.VideoElement(); }

  void render(Context context) {
    super.render(context);
    if (src != null) {
      ref.src = src;
    }
    if (title != null) {
      ref.title = title;
    }
    if (autoplay != null) {
      ref.autoplay = autoplay;
    }
    if (controls != null) {
      ref.controls = controls;
    }
    if (loop != null) {
      ref.loop = loop;
    }
    if (muted != null) {
      ref.muted = muted;
    }
    if (preload != null) {
      ref.preload = preload;
    }
  }

  void update(VVideo other, Context context) {
    super.update(other, context);
    if (other.src != src) {
      ref.src = other.src;
    }
    if (other.title != title) {
      ref.title = other.title;
    }
    if (other.autoplay != autoplay) {
      ref.autoplay = other.autoplay;
    }
    if (other.controls != controls) {
      ref.controls = other.controls;
    }
    if (other.loop != loop) {
      ref.loop = other.loop;
    }
    if (other.muted != muted) {
      ref.muted = other.muted;
    }
    if (other.preload != preload) {
      ref.preload = other.preload;
    }
  }
}
