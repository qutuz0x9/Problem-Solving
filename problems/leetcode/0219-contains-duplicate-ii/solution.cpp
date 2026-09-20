// Contains Duplicate II (leetcode)
//
#include "solution.h"

// Remembers the last index of each value; the nearest earlier equal value is always the last one
// seen.
bool solve(const std::vector<int>& nums, int k) {
    std::unordered_map<int, int> last_index;

    for (int i = 0; i < static_cast<int>(nums.size()); i++) {
        auto it = last_index.find(nums[i]);
        if (it != last_index.end() && i - it->second <= k) return true;
        last_index[nums[i]] = i;
    }

    return false;
}
