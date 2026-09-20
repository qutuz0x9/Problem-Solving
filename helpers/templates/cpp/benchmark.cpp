// Timing benchmark for {{TITLE}}.
// Run with: make bench DIR=problems/<platform>/<slug>
#include <algorithm>
#include <chrono>
#include <cstdio>
#include <vector>

#include "solution.h"

// Input sizes to measure (lower them for slow solutions).
static const int kSizes[] = {10, 1000, 100000};
// Timed runs per size; the minimum and the median are reported.
static const int kRepeats = 7;

// Stops the compiler from deleting a call whose result is unused (GCC/Clang).
template <class T>
static void Keep(const T& value) {
    asm volatile("" : : "g"(&value) : "memory");
}

int main() {
    std::printf("%-12s%12s%14s\n", "size", "min ms", "median ms");
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
        std::printf("%-12d%12.6f%14.6f\n", n, times.front(), times[times.size() / 2]);
    }
    return 0;
}
