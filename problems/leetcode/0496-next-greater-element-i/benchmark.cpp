// Timing benchmark for Next Greater Element I.
// Run with: make bench DIR=problems/<platform>/<slug>
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
        // Worst case for the stack and the map: nums2 is a "valley" of distinct values, first
        // descending (h-1..0, so the stack grows to depth h), then ascending (h..n-1, so the first
        // big value pops the whole stack and every later value pops one). Every value except the
        // last gets a map entry (n-1 inserts). nums1 is all of nums2 in reverse order (n lookups,
        // every one a hit). solve() takes const references, so the input is built once.
        int h = n / 2;
        std::vector<int> nums2;
        nums2.reserve(n);
        for (int v = h - 1; v >= 0; v--) nums2.push_back(v);
        for (int v = h; v < n; v++) nums2.push_back(v);
        std::vector<int> nums1(nums2.rbegin(), nums2.rend());
        Keep(solve(nums1, nums2));  // warmup
        std::vector<double> times;
        for (int r = 0; r < kRepeats; r++) {
            auto start = std::chrono::steady_clock::now();
            Keep(solve(nums1, nums2));
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
