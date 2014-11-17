// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

abstract class ElementBase extends Node {
  Map<String, String> attributes;
  List<String> classes;
  Map<String, String> styles;

  ElementBase(Object key, this.attributes, this.classes, this.styles)
       : super(key);

  void render(Context context) {
    final html.Element e = ref;
    if (attributes != null) {
      attributes.forEach((key, value) {
        e.setAttribute(key, value);
      });
    }
    if (styles != null) {
      styles.forEach((key, value) {
        e.style.setProperty(key, value);
      });
    }
    if (classes != null) {
      e.classes.addAll(classes);
    }
  }

  void update(ElementBase other, Context context) {
    other.ref = ref;
    html.Element e = ref;
    if (attributes != null || other.attributes != null) {
      updateMap(attributes, other.attributes, e.attributes);
    }
    if (styles != null || other.styles != null) {
      updateStyle(styles, other.styles, e.style);
    }
    if (classes != null || other.classes != null) {
      updateSet(classes, other.classes, e.classes);
    }
  }
}

abstract class ElementContainerBase extends ElementBase with Container {
  /// Element children
  List<Node> children;

  ElementContainerBase(Object key,
      this.children,
      Map<String, String> attributes,
      List<String> classes,
      Map<String, String> styles)
      : super(key, attributes, classes, styles);

  void update(Element other, Context context) {
    super.update(other, context);
    if (children != null || other.children != null) {
      updateChildren(children, other.children, context);
    }
  }

  /// Mount on top of existing element
  void render(Context context) {
    super.render(context);
    if (children != null) {
      for (var i = 0; i < children.length; i++) {
        insertBefore(children[i], null, context);
      }
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
class Element extends ElementContainerBase {
  /// [Element] tag name
  final String tag;

  html.Element get container => ref;

  /// Create a new [Element]
  Element(Object key,
      this.tag,
      List<Node> children,
      {Map<String, String> attributes: null,
       List<String> classes: null,
       Map<String, String> styles: null})
      : super(key, children, attributes, classes, styles);

  void create(Context context) {
    ref = html.document.createElement(tag);
  }

  String toString() => '<$tag key="$key">${children.join()}</$tag>';
}
