# Contains Duplicate II

- **Platform:** leetcode
- **Language:** cpp
- **Link:** <https://leetcode.com/problems/contains-duplicate-ii/>
- **Difficulty:** Easy
- **Tags:** Array, Hash Table, Sliding Window

## Problem

Given an integer array `nums` and an integer `k`, return `true` if some value appears at two different indices `i`
and `j` that are at most `k` apart (`nums[i] == nums[j]` and `abs(i - j) <= k`), and `false` otherwise.

### Examples

**Example 1:**

```txt
Input: nums = [1,2,3,1], k = 3
Output: true
```

**Example 2:**

```txt
Input: nums = [1,0,1,1], k = 1
Output: true
```

**Example 3:**

```txt
Input: nums = [1,2,3,1,2,3], k = 2
Output: false
```

### Constraints

- `1 <= nums.length <= 10^5`
- `-10^9 <= nums[i] <= 10^9`
- `0 <= k <= 10^5`

## Approach

Use a hash map to track the most recent index of each value encountered so far. Iterate through the array once: for each element, check if it exists in the map and if the distance to its last occurrence is at most `k`. If so, return `true` immediately. Otherwise, update the map with the current index. If the loop completes without finding a valid pair, return `false`.

The key insight is that we only care about the *last* occurrence of each value (the most recent one), not earlier ones, because we want to minimize the distance between two equal values to maximize the chance of staying within the `k` bound.

## Complexity

- Time: O(n), where n is the length of the array. We iterate through each element once and perform O(1) hash map lookups and insertions.
- Space: O(min(n, m)), where m is the number of distinct values in the array. The hash map stores at most one entry per distinct value.
