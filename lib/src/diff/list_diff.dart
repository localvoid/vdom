// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.diff;

class UnorderedListPatch {
  final List removed;
  final List inserted;

  UnorderedListPatch(this.removed, this.inserted);
}

UnorderedListPatch unorderedListDiff(List a, List b) {
  if (identical(a, b)) {
    return null;
  }

  if (a != null && a.length > 0) {
    if (b == null || b.length == 0) {
      return new UnorderedListPatch(new List.from(a), null);
    } else {
      final aLength = a.length;
      final bLength = b.length;
      final removedResult = new List();
      final insertedResult = new List();

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
            removedResult.add(aItem);
          }
        }
        for (var i = 0; i < bLength; i++) {
          if (visited[i] != true) {
            insertedResult.add(b[i]);
          }
        }
      } else {
        final bIndex = new HashMap();

        for (var bItem in b) {
          bIndex[bItem] = false;
        }

        for (var aItem in a) {
          if (!bIndex.containsKey(aItem)) {
            removedResult.add(aItem);
          } else {
            bIndex[aItem] = true;
          }
        }

        bIndex.forEach((k, v) {
          if (v == false) {
            insertedResult.add(k);
          }
        });
      }

      if (removedResult.isEmpty && insertedResult.isEmpty) {
        return null;
      }

      return new UnorderedListPatch(
          removedResult.isEmpty ? null : removedResult,
          insertedResult.isEmpty ? null : removedResult);

    }
  } else if (b != null && b.length > 0) {
    return new UnorderedListPatch(null, new List.from(b));
  }
  return null;
}
