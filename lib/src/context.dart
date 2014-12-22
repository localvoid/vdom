// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.context;

/// [Context] object is used to propagate additional data in virtual tree.
class Context {
  final bool _isAttached;

  /// [Context] is attached to the html document.
  bool get isAttached => _isAttached;

  const Context(this._isAttached);
}
