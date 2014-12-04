// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom;

/// [VContext] object is used to propagate additional data in virtual tree.
class VContext {
  final bool _isAttached;

  /// [VContext] is attached to the html document.
  bool get isAttached => _isAttached;

  const VContext(this._isAttached);
}
