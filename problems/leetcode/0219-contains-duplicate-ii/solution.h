#pragma once
#include <cstdlib>
#include <unordered_map>
#include <vector>

// Returns true if there are two distinct indices i and j with nums[i] == nums[j] and abs(i - j) <=
// k.
bool solve(const std::vector<int>& nums, int k);
