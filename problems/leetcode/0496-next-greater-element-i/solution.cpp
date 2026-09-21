// Next Greater Element I (leetcode)
#include "solution.h"

#include <unordered_map>

// Monotonic stack over nums2: each value waits on the stack until a larger value arrives.
std::vector<int> solve(const std::vector<int>& nums1, const std::vector<int>& nums2) {
    std::unordered_map<int, int> next_greater;
    std::vector<int> waiting;

    for (int x : nums2) {
        while (!waiting.empty() && waiting.back() < x) {
            next_greater[waiting.back()] = x;
            waiting.pop_back();
        }
        waiting.push_back(x);
    }

    std::vector<int> answer;
    answer.reserve(nums1.size());
    for (int x : nums1) {
        auto it = next_greater.find(x);
        answer.push_back(it == next_greater.end() ? -1 : it->second);
    }
    return answer;
}
