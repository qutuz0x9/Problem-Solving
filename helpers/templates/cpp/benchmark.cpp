// Lightweight timing benchmark for {{TITLE}}.
#include <chrono>
#include <cstdio>

#include "solution.h"

int main() {
    const int n = 1000;
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < n; i++) {
        solve();
    }
    auto end = std::chrono::high_resolution_clock::now();
    std::chrono::duration<double, std::milli> ms = end - start;
    std::printf("%d iterations: %.3f ms\n", n, ms.count());
    return 0;
}
