// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// Virtual DOM diff/patch
library vdom;

import 'package:vdom/src/vdom.dart';

export 'package:vdom/src/vdom.dart' show Node, Element, Text, NodePatch,
    ElementPatch, TextPatch, diffChildren, applyChildrenPatch;

part 'package:vdom/src/api.dart';
