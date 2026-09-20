"""Lightweight timing benchmark for {{TITLE}}.

Run with: python benchmark.py
"""
import timeit

# TODO: remove the noqa once the benchmark below calls solve(...)
from solution import solve  # noqa: F401

if __name__ == "__main__":
    # TODO: pass real arguments to solve(...)
    elapsed = timeit.timeit(lambda: None, number=1000)
    print(f"1000 iterations: {elapsed:.6f}s")
