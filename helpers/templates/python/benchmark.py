"""Timing benchmark for {{TITLE}}.

Run with: make bench DIR=problems/<platform>/<slug>   (or: python benchmark.py)
"""

import statistics
import time

from solution import solve

# Input sizes to measure, 10x apart so the growth is easy to see (lower them for slow solutions).
SIZES = [10, 100, 1_000, 10_000, 100_000]
REPEATS = 7  # timed runs per size; the minimum and the median are reported


def make_input(n):
    """Return the arguments for solve() as a tuple, for an input of size n.

    TODO: build a realistic (ideally worst-case) input, e.g. `return (list(range(n)), n)`.
    If solve() changes its input, build a fresh copy inside measure() for every run.
    """
    return ()


def measure(n):
    args = make_input(n)
    solve(*args)  # warmup
    times = []
    for _ in range(REPEATS):
        start = time.perf_counter()
        solve(*args)
        times.append((time.perf_counter() - start) * 1000)
    return min(times), statistics.median(times)


if __name__ == "__main__":
    print(f"{'size':<12}{'min ms':>12}{'median ms':>14}{'growth':>10}")
    previous = 0.0
    for n in SIZES:
        fastest, median = measure(n)
        growth = f"x{fastest / previous:.1f}" if previous > 0 else "-"  # vs the previous size
        print(f"{n:<12}{fastest:>12.6f}{median:>14.6f}{growth:>10}")
        previous = fastest
