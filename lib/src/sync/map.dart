// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.sync;

void updateMap(Map a, Map b, Map n) {
  if (identical(a, b)) {
    return null;
  }

  if (a != null && a.length > 0) {
    if (b == null || b.length == 0) {
      // all keys removed
      n.clear();
    } else {
      // find all modified and removed
      a.forEach((key, value) {
        final bValue = b[key];
        if (bValue == null) {
          n.remove(key);
        } else if (value != bValue) {
          n[key] = value;
        }
      });

      // find all inserted
      b.forEach((key, value) {
        if (!a.containsKey(key)) {
          n[key] = value;
        }
      });
    }
  } else if (b != null && b.length > 0) {
    // all keys inserted
    n.addAll(b);
  }
}
