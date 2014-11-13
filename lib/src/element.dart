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

/// Virtual Dom Element
class Element extends ElementBase with Container {
  /// [Element] tag name
  final String tag;

  /// Element children
  List<Node> children;

  /// Create a new [Element]
  Element(Object key, this.tag, this.children,
          {Map<String, String> attributes: null,
           List<String> classes: null,
           Map<String, String> styles: null})
           : super(key, attributes, classes, styles) {
    assert(children != null);
  }

  void create(Context context) {
    ref = html.document.createElement(tag);
  }

  void update(Element other, Context context) {
    super.update(other, context);
    updateChildren(children, other.children, context);
  }

  /// Mount on top of existing element
  void render(Context context) {
    super.render(context);
    for (var i = 0; i < children.length; i++) {
      inject(children[i], ref, context);
    }
  }

  void detached() {
    for (var i = 0; i < children.length; i++) {
      children[i].detached();
    }
  }

  void insertBefore(Node node, html.Node nextRef, Context context) {
    injectBefore(node, ref, nextRef, context);
  }

  void move(Node node, html.Node nextRef, Context context) {
    ref.insertBefore(node.ref, nextRef);
  }

  void removeChild(Node node, Context context) {
    node.dispose(context);
  }

  String toString() => '<$tag key="$key">${children.join()}</$tag>';
}
