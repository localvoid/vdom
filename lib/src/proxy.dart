part of vdom;

abstract class NodeProxy implements Node {
  final Node node;

  Object get key => node.key;
  html.Node get ref => node.ref;
  set ref(html.Node newRef) {
    node.ref = newRef;
  }

  NodeProxy(this.node);

  void create(Context context) {
    node.create(context);
  }

  void mount(html.Node node, Context context) {
    this.node.mount(node, context);
  }

  void render(Context context) {
    node.render(context);
  }

  void update(Node other, Context context) {
    node.update(other, context);
  }

  void dispose(Context context) {
    node.dispose(context);
  }

  void attached() { node.attached(); }
  void detached() { node.detached(); }
}
