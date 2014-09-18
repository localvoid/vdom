part of vdom.internal;

/**
 * Singleton [VElement] contains reference to the rendered [node], and when
 * it is diffed against other element, it copies reference to other element.
 */
class SingletonElement extends Element {
  /**
   * Reference to the rendered [node]
   */
  html.Element node;

  SingletonElement(String key, String tag, [List<Node> children = null]) :
      super(
      key,
      tag,
      children);

  ElementPatch diff(Element other) {
    if (other is SingletonElement) {
      other.node = node;
    }
    return super.diff(other);
  }

  html.Element render() {
    if (node != null) {
      return node;
    }
    final result = super.render();
    node = result;
    return result;
  }
}

/**
 * Singleton [Text] contains reference to the rendered [node], and when
 * it is diffed against other text, it copies reference to other text.
 */
class VSingletonText extends Text {
  /**
   * Reference to the rendered [node]
   */
  html.Text node;

  VSingletonText(String key, String data) : super(key, data);

  TextPatch diff(Text other) {
    if (other is VSingletonText) {
      other.node = node;
    }
    return super.diff(other);
  }

  html.Text render() {
    if (node != null) {
      return node;
    }

    final result = super.render();
    node = result;
    return result;
  }
}
