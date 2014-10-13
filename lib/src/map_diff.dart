// Copyright (c) 2014, the VDom project authors. Please see the AUTHORS file for
// details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

part of vdom.internal;

class MapPatch {
  /**
   * Keys that should be modified. Their values are stored in the
   * corresponding positions in the [values] list.
   */
  final List keys;

  /**
   * Values.
   */
  final List values;

  MapPatch(this.keys, this.values);
}

MapPatch mapDiff(Map a, Map b) {
  if (identical(a, b)) {
    return null;
  }

  if (a != null && a.length > 0) {
    if (b == null || b.length == 0) {
      // all keys removed
      final modifiedKeys = new List(a.length);
      final modifiedValues = new List(a.length);
      var i = 0;
      a.forEach((k, v) {
        modifiedKeys[i] = k;
        modifiedValues[i] = null;
        i++;
      });
      return new MapPatch(modifiedKeys, modifiedValues);
    } else {
      final modifiedKeys = new List();
      final modifiedValues = new List();

      // find all modified and removed
      a.forEach((key, value) {
        final bValue = b[key];
        if (value != bValue) {
          modifiedKeys.add(key);
          modifiedValues.add(bValue);
        }
      });

      // find all inserted
      b.forEach((key, value) {
        if (!a.containsKey(key)) {
          modifiedKeys.add(key);
          modifiedValues.add(value);
        }
      });

      if (modifiedKeys.length > 0) {
        return new MapPatch(modifiedKeys, modifiedValues);
      }
    }
  } else if (b != null && b.length > 0) {
    // all keys inserted
    final modifiedKeys = new List<String>(b.length);
    final modifiedValues = new List<String>(b.length);

    var i = 0;
    b.forEach((k, v) {
      modifiedKeys[i] = k;
      modifiedValues[i] = v;
      i++;
    });

    return new MapPatch(modifiedKeys, modifiedValues);
  }

  return null;
}
