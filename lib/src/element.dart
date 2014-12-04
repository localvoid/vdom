// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

/// Base class for Nodes with [id], [attributes], [classes] and
/// [styles] properties.
abstract class VElementBase<T extends html.Element> extends VNode<T> {
  String id;
  Map<String, String> attributes;
  List<String> classes;
  Map<String, String> styles;

  VElementBase(Object key, this.id, this.attributes, this.classes, this.styles)
       : super(key);

  void render(VContext context) {
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
  }

  void update(VElementBase other, VContext context) {
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
  }
}

/// Base class for Container Elements
abstract class VElementContainerBase<T extends html.Element> extends VElementBase<T> with VContainer<T> {
  /// Element children
  List<VNode> children;

  html.Element get container => ref;

  VElementContainerBase(Object key,
      this.children,
      String id,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, id, attributes, classes, styles);

  VElementContainerBase<T> call(children) {
    if (children is List) {
      this.children = children;
    } else if (children is String) {
      this.children = [new VText(children)];
    } else {
      this.children = [children];
    }
    return this;
  }

  void mount(html.Element node, VContext context) {
    super.mount(node, context);
    for (var i = 0; i < node.childNodes.length; i++) {
      children[i].mount(node.childNodes[i], context);
    }
  }

  void init() {
    for (var i = 0; i < children.length; i++) {
      children[i].init();
    }
  }

  void update(VElementContainerBase other, VContext context) {
    super.update(other, context);
    if (children != null || other.children != null) {
      updateChildren(children, other.children, context);
    }
  }

  void render(VContext context) {
    super.render(context);
    if (children != null) {
      renderChildren(children, context);
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
class VElement extends VElementContainerBase<html.Element> {
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

  void create(VContext context) {
    ref = html.document.createElement(tag);
  }

  bool sameType(VNode other) => super.sameType(other) && tag == (other as VElement).tag;

  String toString() => '<$tag key="$key">${children.join()}</$tag>';
}
