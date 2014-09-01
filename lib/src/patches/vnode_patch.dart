// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;

/**
 * Abstract base class for patches that applied to nodes.
 */
abstract class VNodePatch {

  /**
   * Apply patch to the [node]
   */
  void apply(html.Node node);
}
