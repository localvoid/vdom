part of vdom.internal;

/**
 * Singleton [VElement] contains reference to the rendered [node], and when
 * it is diffed against other element, it copies reference to other element.
 */
class VSingletonElement extends VElement {
  /**
   * Reference to the rendered [node]
   */
  html.Element node;

  VSingletonElement(String key, String tag, [List<VNode> children = null]) :
      super(
      key,
      tag,
      children);

  VElementPatch diff(VElement other) {
    if (other is VSingletonElement) {
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
 * Singleton [VText] contains reference to the rendered [node], and when
 * it is diffed against other text, it copies reference to other text.
 */
class VSingletonText extends VText {
  /**
   * Reference to the rendered [node]
   */
  html.Text node;

  VSingletonText(String key, String data) : super(key, data);

  VTextPatch diff(VText other) {
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
