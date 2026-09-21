// Minimal assert-based test runner (no external test framework dependency).
#include <algorithm>
#include <cassert>
#include <cstddef>
#include <cstdio>
#include <numeric>
#include <random>
#include <vector>

#include "solution.h"

namespace {

using Vec = std::vector<int>;

// Obvious O(n * m) reference: locate each value in nums2, scan to its right.
Vec brute_force(const Vec& nums1, const Vec& nums2) {
    Vec answer;
    for (int x : nums1) {
        std::size_t pos = std::find(nums2.begin(), nums2.end(), x) - nums2.begin();
        int found = -1;
        for (std::size_t j = pos + 1; j < nums2.size(); ++j) {
            if (nums2[j] > x) {
                found = nums2[j];
                break;
            }
        }
        answer.push_back(found);
    }
    return answer;
}

void check(const Vec& nums1, const Vec& nums2, const Vec& expected) {
    Vec got = solve(nums1, nums2);
    assert(got == expected);
}

}  // namespace

int main() {
    // Statement examples.
    check({4, 1, 2}, {1, 3, 4, 2}, {-1, 3, -1});
    check({2, 4}, {1, 2, 3, 4}, {3, -1});

    // Single element: nothing to the right.
    check({1}, {1}, {-1});
    check({0}, {0}, {-1});

    // Value bounds 0 and 10^4.
    check({0}, {0, 10000}, {10000});
    check({10000}, {0, 10000}, {-1});
    check({10000}, {10000, 0}, {-1});
    check({0}, {10000, 0}, {-1});
    check({0, 10000}, {5000, 0, 10000}, {10000, -1});

    // nums1 == nums2: 5 -> 8, 3 -> 8, 8 -> none, 1 -> none.
    check({5, 3, 8, 1}, {5, 3, 8, 1}, {8, 8, -1, -1});

    // Strictly increasing nums2: each value's answer is its right neighbour.
    check({1, 2, 3, 4, 5}, {1, 2, 3, 4, 5}, {2, 3, 4, 5, -1});
    check({3}, {1, 2, 3, 4, 5}, {4});

    // Strictly decreasing nums2: nothing is ever greater to the right.
    check({5, 4, 3, 2, 1}, {5, 4, 3, 2, 1}, {-1, -1, -1, -1, -1});
    check({3, 1}, {5, 4, 3, 2, 1}, {-1, -1});

    // nums1 is a subset of nums2 in a different order.
    // 3 -> 5, 1 -> 2, 5 -> none (only 4 follows it).
    check({3, 1, 5}, {6, 1, 2, 3, 5, 4}, {5, 2, -1});
    // 9 -> none, 3 -> 9, 1 -> 5, 7 -> 9, 2 -> 7.
    check({9, 3, 1, 7, 2}, {2, 7, 1, 5, 3, 9}, {-1, 9, 5, 9, 7});

    // The answer is the first larger value, not the largest or the next value:
    // 5 -> 6, 1 -> 2, 2 -> 6.
    check({2, 1, 5}, {5, 1, 2, 6}, {6, 2, 6});
    // A larger value on the left must not count: 4 -> none, 2 -> 3.
    check({4, 2}, {4, 1, 2, 3}, {-1, 3});
    // Nearest larger, not the biggest: 1 -> 2 although 9 comes later.
    check({1}, {1, 2, 9}, {2});

    // Duplicates in nums1 are not allowed by the constraints, so none are tested.

    // Larger cases, n = 1000, checked against the brute force.
    std::mt19937 rng(496);

    // Sorted ascending 0..999 and descending, nums1 == nums2.
    Vec ascending(1000);
    std::iota(ascending.begin(), ascending.end(), 0);
    Vec expected_ascending(1000);
    for (int i = 0; i < 1000; ++i) {
        expected_ascending[i] = i + 1 < 1000 ? i + 1 : -1;
    }
    check(ascending, ascending, expected_ascending);

    Vec descending(ascending.rbegin(), ascending.rend());
    check(descending, descending, Vec(1000, -1));

    // Values up to 10^4 spread across the range, always including 0 and 10^4.
    for (int round = 0; round < 20; ++round) {
        Vec pool(10001);
        std::iota(pool.begin(), pool.end(), 0);
        std::shuffle(pool.begin(), pool.end(), rng);
        if (round == 0) {
            // Swap (not overwrite) so the values stay distinct.
            std::iter_swap(pool.begin(), std::find(pool.begin(), pool.end(), 10000));
            std::iter_swap(pool.begin() + 999, std::find(pool.begin(), pool.end(), 0));
        }
        Vec nums2(pool.begin(), pool.begin() + 1000);

        // nums1 == nums2.
        assert(solve(nums2, nums2) == brute_force(nums2, nums2));

        // nums1 == nums2 in a different order.
        Vec shuffled = nums2;
        std::shuffle(shuffled.begin(), shuffled.end(), rng);
        assert(solve(shuffled, nums2) == brute_force(shuffled, nums2));

        // nums1 is a random subset of nums2 of a few sizes.
        for (std::size_t size : {std::size_t{1}, std::size_t{10}, std::size_t{500}}) {
            Vec subset(shuffled.begin(), shuffled.begin() + size);
            assert(solve(subset, nums2) == brute_force(subset, nums2));
        }
    }

    std::printf("All tests passed\n");
    return 0;
}
