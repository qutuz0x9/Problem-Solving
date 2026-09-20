// Timing benchmark for Contains Duplicate II.
// Run with: make bench DIR=problems/leetcode/0219-contains-duplicate-ii
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <vector>

#include "solution.h"

// Input sizes to measure, 10x apart so the growth is easy to see (lower them for slow solutions).
static const int kSizes[] = {10, 100, 1000, 10000, 100000};
// Timed runs per size; the minimum and the median are reported.
static const int kRepeats = 7;

// Stops the compiler from deleting a call whose result is unused (GCC/Clang).
template <class T>
static void Keep(const T& value) {
    asm volatile("" : : "g"(&value) : "memory");
}

int main() {
    std::printf("%-12s%12s%14s%10s\n", "size", "min ms", "median ms", "growth");
    double previous = 0;
    for (int n : kSizes) {
        // All values distinct: the worst case, because no pair ever matches and there is no early
        // exit. k = n, so the distance limit never rules a pair out either.
        std::vector<int> nums(n);
        for (int i = 0; i < n; i++) nums[i] = i;
        const int k = n;

        Keep(solve(nums, k));  // warmup
        std::vector<double> times;
        for (int r = 0; r < kRepeats; r++) {
            auto start = std::chrono::steady_clock::now();
            Keep(solve(nums, k));
            std::chrono::duration<double, std::milli> ms = std::chrono::steady_clock::now() - start;
            times.push_back(ms.count());
        }
        std::sort(times.begin(), times.end());
        double fastest = times.front();
        char growth[16] = "-";  // time versus the previous size
        if (previous > 0) std::snprintf(growth, sizeof growth, "x%.1f", fastest / previous);
        std::printf("%-12d%12.6f%14.6f%10s\n", n, fastest, times[times.size() / 2], growth);
        previous = fastest;
    }
    return 0;
}
