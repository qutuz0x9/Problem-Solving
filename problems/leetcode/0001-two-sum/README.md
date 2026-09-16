# Two Sum

- **Platform:** leetcode
- **Language:** go
- **Link:** https://leetcode.com/problems/two-sum/
- **Difficulty:** Easy
- **Tags:** array, hash-map

## Problem

Given an array of integers `nums` and an integer `target`, return the indices of
the two numbers such that they add up to `target`. Assume exactly one solution
exists, and the same element can't be used twice.

## Approach

Single pass with a hash map from value -> index. For each number, check whether
`target - num` was already seen; if so, return the stored index and the current
index.

## Complexity

- Time: O(n)
- Space: O(n)
