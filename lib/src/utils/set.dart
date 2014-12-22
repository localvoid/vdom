// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library vdom.utils.set;

import 'dart:collection';

/// Find changes between Lists [a] and [b] and apply this changes to Set [n].
void updateSet(List a, List b, Set n) {
  if (identical(a, b)) {
    return null;
  }

  if (a != null && a.length > 0) {
    if (b == null || b.length == 0) {
      n.removeAll(a);
    } else {
      final aLength = a.length;
      final bLength = b.length;

      if (aLength * bLength <= 16) {
        final visited = new List(bLength);

        for (var aItem in a) {
          var removed = true;

          for (var i = 0; i < bLength; i++) {
            final bItem = b[i];

            if (aItem == bItem) {
              removed = false;
              visited[i] = true;
              break;
            }
          }
          if (removed) {
            n.remove(aItem);
          }
        }
        for (var i = 0; i < bLength; i++) {
          if (visited[i] != true) {
            n.add(b[i]);
          }
        }
      } else {
        final bIndex = new HashMap();

        for (var bItem in b) {
          bIndex[bItem] = false;
        }

        for (var aItem in a) {
          if (!bIndex.containsKey(aItem)) {
            n.remove(aItem);
          } else {
            bIndex[aItem] = true;
          }
        }

        bIndex.forEach((k, v) {
          if (v == false) {
            n.add(k);
          }
        });
      }
    }
  } else if (b != null && b.length > 0) {
    n.addAll(b);
  }
  return null;
}
