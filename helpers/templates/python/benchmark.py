"""Lightweight timing benchmark for {{TITLE}}.

Run with: python benchmark.py
"""
import timeit

from solution import solve

if __name__ == "__main__":
    # TODO: pass real arguments to solve(...)
    elapsed = timeit.timeit(lambda: None, number=1000)
    print(f"1000 iterations: {elapsed:.6f}s")
