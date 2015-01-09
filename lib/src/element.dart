// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.element;

import 'dart:html' as html;
import 'context.dart';
import 'node.dart';
import 'utils/container.dart';
import 'text.dart';
import 'utils/map.dart';
import 'utils/set.dart';
import 'utils/style.dart';

abstract class VElement<T extends html.Element> extends VNode<T> with Container<T> {
  List<VNode> children;
  String id;
  String type;
  Map<String, String> attributes;
  List<String> classes;
  Map<String, String> styles;

  html.Element get container => ref;

  VElement(
      {Object key,
       this.children,
       this.id,
       this.type,
       this.attributes,
       this.classes,
       this.styles})
       : super(key);

  VElement<T> call(children) {
    if (children is List) {
      this.children = children;
    } else if (children is Iterable) {
      this.children = children.toList();
    } else if (children is String) {
      this.children = [new VText(children)];
    } else {
      this.children = [children];
    }
    return this;
  }

  void mount(html.Element node, Context context) {
    super.mount(node, context);
    if (children != null) {
      mountChildren(children, node, context);
    }
  }

  void render(Context context) {
    if (id != null) {
      ref.id = id;
    }

    if (type != null) {
      ref.classes.add(type);
    }

    if (attributes != null) {
      attributes.forEach((k, v) {
        ref.setAttribute(k, v);
      });
    }

    if (styles != null) {
      styles.forEach((key, value) {
        ref.style.setProperty(key, value);
      });
    }

    if (classes != null) {
      ref.classes.addAll(classes);
    }

    if (children != null) {
      renderChildren(children, context);
    }
  }

  void update(VElement other, Context context) {
    super.update(other, context);

    if (other.id == null) {
      other.id = id;
    } else if (id != other.id) {
      ref.id = other.id;
    }

    if (attributes != null || other.attributes != null) {
      updateMap(attributes, other.attributes, ref.attributes);
    }

    if (styles != null || other.styles != null) {
      updateStyle(styles, other.styles, ref.style);
    }
    if (classes != null || other.classes != null) {
      updateSet(classes, other.classes, ref.classes);
    }

    if (children != null || other.children != null) {
      updateChildren(children, other.children, context);
    }
  }

  void detached() {
    if (children != null) {
      for (var i = 0; i < children.length; i++) {
        children[i].detached();
      }
    }
  }

  bool sameType(VNode other) =>
      super.sameType(other) && type == (other as VElement).type;
}
