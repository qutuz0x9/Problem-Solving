// Timing benchmark for Intersection of Two Arrays.
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
        // TODO: build the input for size n (ideally worst case) once, here, and pass it to
        // solve(...) below. If solve() changes its input, copy it inside the timed loop.
        (void)n;
        Keep(solve());  // warmup
        std::vector<double> times;
        for (int r = 0; r < kRepeats; r++) {
            auto start = std::chrono::steady_clock::now();
            Keep(solve());
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
