# v0.3.0 (2014-09-19)

- [BREAKING CHANGE] Removed V prefix from class names.
- Longest Common Subsequence (Myers' diff) algorithm to find Shortest
  Edit Script for children repositioning replaced with Longest
  Increasing Subsequence algorithm. LIS algorithm works much faster in
  the worst case scenarios.

# v0.2.0 (2014-09-03)

- [BREAKING CHANGE] Changed VElement constructor argument order
- New subclasses VSingletonElement and VSingletonText that stores
  references to their html nodes