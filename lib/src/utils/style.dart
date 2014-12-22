// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.utils.style;

import 'dart:html' as html;

/// Find changes between maps [a] and [b] and apply this changes to CssStyleDeclaration [n].
void updateStyle(Map a, Map b, html.CssStyleDeclaration n) {
  if (identical(a, b)) {
    return null;
  }

  if (a != null && a.length > 0) {
    if (b == null || b.length == 0) {
      // all keys removed
      for (final i in a.keys) {
        n.removeProperty(i);
      }
    } else {
      // find all modified and removed
      a.forEach((key, value) {
        final bValue = b[key];
        if (bValue == null) {
          n.removeProperty(key);
        } else if (value != bValue) {
          n.setProperty(key, bValue);
        }
      });

      // find all inserted
      b.forEach((key, value) {
        if (!a.containsKey(key)) {
          n.setProperty(key, value);
        }
      });
    }
  } else if (b != null && b.length > 0) {
    // all keys inserted
    b.forEach((key, value) {
      n.setProperty(key, value);
    });
  }
}
