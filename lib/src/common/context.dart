part of vdom.common;

class Context {
  final bool _isAttached;
  bool get isAttached => _isAttached;

  const Context(this._isAttached);
}
