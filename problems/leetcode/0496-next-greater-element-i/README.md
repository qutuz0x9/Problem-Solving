# Next Greater Element I

- **Platform:** leetcode
- **Language:** cpp
- **Link:** <https://leetcode.com/problems/next-greater-element-i/>
- **Difficulty:** Easy
- **Tags:** Array, Hash Table, Stack, Monotonic Stack

## Problem

The next greater element of a value in an array is the first larger value to its right. You get two arrays of distinct
numbers, `nums1` and `nums2`, where every value of `nums1` also appears in `nums2`. For each value in `nums1`, find it
in `nums2` and report its next greater element there, or `-1` if there is none. Return the answers in the order of
`nums1`. Follow-up: can it be done in `O(nums1.length + nums2.length)` time?

### Examples

**Example 1:**

```txt
Input: nums1 = [4,1,2], nums2 = [1,3,4,2]
Output: [-1,3,-1]
Explanation: The next greater element for each value of nums1 is as follows:
- 4 is underlined in nums2 = [1,3,4,2]. There is no next greater element, so the answer is -1.
- 1 is underlined in nums2 = [1,3,4,2]. The next greater element is 3.
- 2 is underlined in nums2 = [1,3,4,2]. There is no next greater element, so the answer is -1.
```

**Example 2:**

```txt
Input: nums1 = [2,4], nums2 = [1,2,3,4]
Output: [3,-1]
Explanation: The next greater element for each value of nums1 is as follows:
- 2 is underlined in nums2 = [1,2,3,4]. The next greater element is 3.
- 4 is underlined in nums2 = [1,2,3,4]. There is no next greater element, so the answer is -1.
```

### Constraints

- `1 <= nums1.length <= nums2.length <= 1000`
- `0 <= nums1[i], nums2[i] <= 10^4`
- All integers in `nums1` and `nums2` are **unique**.
- All the integers of `nums1` also appear in `nums2`.

**Follow up:** Could you find an `O(nums1.length + nums2.length)` solution?

## Approach

Use a monotonic stack to scan `nums2` and find each value's next greater element in a single pass. Maintain a decreasing
stack of values still waiting for their next greater element. For each value `x` in `nums2`, pop all smaller waiting
values (their next greater element is `x`) and record them in a hash map, then push `x` onto the stack. After this pass,
use the hash map to look up each value from `nums1` and report the answer (or -1 if not found). This achieves the
follow-up's O(n1 + n2) time complexity.

## Complexity

- Time: O(n1 + n2), where n1 = `nums1.length` and n2 = `nums2.length`. Each element in `nums2` is pushed and popped
  once (O(n2)), plus O(n1) lookups in the hash map.
- Space: O(n2) for the hash map storing next greater elements for each value in `nums2`.
