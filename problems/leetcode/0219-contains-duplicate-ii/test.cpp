// Minimal assert-based test runner (no external test framework dependency).
#include <cassert>
#include <cstdio>
#include <vector>

#include "solution.h"

int main() {
    // Examples from the problem statement.
    assert(solve({1, 2, 3, 1}, 3) == true);
    assert(solve({1, 0, 1, 1}, 1) == true);
    assert(solve({1, 2, 3, 1, 2, 3}, 2) == false);

    // Single element: no pair of distinct indices exists.
    assert(solve({1}, 0) == false);
    assert(solve({1}, 100000) == false);

    // k = 0: distinct indices are always at least 1 apart, so the answer is always false.
    assert(solve({1, 1}, 0) == false);
    assert(solve({1, 2, 1}, 0) == false);
    assert(solve({7, 7, 7, 7}, 0) == false);

    // Adjacent duplicates with k = 1.
    assert(solve({1, 1}, 1) == true);
    assert(solve({5, 6, 6}, 1) == true);

    // Boundary: distance exactly k is allowed, k + 1 is not.
    assert(solve({1, 2, 3, 1}, 3) == true);
    assert(solve({1, 2, 3, 1}, 2) == false);
    assert(solve({9, 8, 7, 6, 9}, 4) == true);
    assert(solve({9, 8, 7, 6, 9}, 3) == false);

    // k larger than the array acts like "any duplicate".
    assert(solve({1, 2, 3, 4, 1}, 100000) == true);
    assert(solve({1, 2, 3, 4, 5}, 100000) == false);

    // All distinct: never true.
    assert(solve({1, 2, 3, 4, 5}, 1) == false);

    // All equal: true whenever k >= 1.
    assert(solve({4, 4, 4, 4, 4}, 1) == true);

    // Must compare against the most recent occurrence, not the first one:
    // 1 at indices 0, 5, 6; the far pair (0, 5) is too far but (5, 6) is within k = 1.
    assert(solve({1, 2, 3, 4, 5, 1, 1}, 1) == true);
    // Plausible bug: keeping only the first index would miss the close later pair.
    assert(solve({1, 9, 9, 9, 9, 1, 1}, 1) == true);
    // Every equal pair is at distance 3 or more except the zeros at (1, 2).
    assert(solve({2, 0, 0, 2, 0, 0, 2}, 2) == true);  // (1, 2) distance 1
    // Equal pairs at distance exactly 3 only, so k = 2 is false.
    assert(solve({2, 3, 4, 2, 5, 6, 2}, 2) == false);

    // Duplicate of a different value farther away must not mask a valid pair.
    assert(solve({1, 2, 1, 3, 2}, 2) == true);
    assert(solve({1, 2, 3, 1, 2, 3}, 3) == true);

    // Negative numbers and extreme values.
    assert(solve({-1, -1}, 1) == true);
    assert(solve({-1, 1, -1}, 1) == false);
    assert(solve({-1, 1, -1}, 2) == true);
    assert(solve({-1000000000, 1000000000, -1000000000}, 2) == true);
    assert(solve({-1000000000, 1000000000, -1000000000}, 1) == false);
    assert(solve({0, 0}, 1) == true);

    // Largest sizes: n = 10^5, k = 10^5.
    {
        const int n = 100000;
        std::vector<int> distinct(n);
        for (int i = 0; i < n; i++) distinct[i] = i;
        assert(solve(distinct, 100000) == false);

        // Only duplicate is the first and last element, at distance n - 1.
        std::vector<int> ends = distinct;
        ends[n - 1] = 0;
        assert(solve(ends, n - 1) == true);
        assert(solve(ends, n - 2) == false);

        std::vector<int> equal(n, 3);
        assert(solve(equal, 1) == true);
        assert(solve(equal, 0) == false);
    }

    std::printf("All tests passed\n");
    return 0;
}
