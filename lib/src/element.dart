// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

abstract class VElementBase<T extends html.Element> extends VNode<T> with VContainer<T> {
  List<VNode> children;
  String id;
  Map<String, String> attributes;
  List<String> classes;
  Map<String, String> styles;

  html.Element get container => ref;

  VElementBase(Object key, this.children, this.id, this.attributes,
      this.classes, this.styles) : super(key);

  VElementBase<T> call(children) {
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
      // TODO: check performance for childNodes iteration
      for (var i = 0; i < node.childNodes.length; i++) {
        children[i].mount(node.childNodes[i], context);
      }
    }
  }

  void render(Context context) {
    if (id != null) {
      ref.id = id;
    }
    if (attributes != null) {
      attributes.forEach((key, value) {
        ref.setAttribute(key, value);
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

  void update(VElementBase other, Context context) {
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
}

/// Virtual Dom Element
class VElement extends VElementBase<html.Element> {
  /// [VElement] tag name
  final String tag;

  /// Create a new [VElement]
  VElement(this.tag,
      {Object key,
       List<VNode> children,
       String id,
       Map<String, String> attributes,
       List<String> classes,
       Map<String, String> styles})
      : super(key, children, id, attributes, classes, styles);

  void create(Context context) {
    ref = html.document.createElement(tag);
  }

  bool sameType(VNode other) => super.sameType(other) && tag == (other as VElement).tag;

  String toString() => '<$tag key="$key">${children.join()}</$tag>';
}
