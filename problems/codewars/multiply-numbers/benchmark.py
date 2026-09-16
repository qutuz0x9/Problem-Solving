"""Lightweight timing benchmark for Multiply Numbers.

Run with: python benchmark.py
"""
import timeit

from solution import solve

if __name__ == "__main__":
    elapsed = timeit.timeit(lambda: solve([1, 2, 3, 4, 5, 6, 7, 8]), number=1000)
    print(f"1000 iterations: {elapsed:.6f}s")
