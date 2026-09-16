"""Multiply Numbers (codewars)
https://www.codewars.com/kata/57a2f2f512af636650000019
"""


def solve(numbers: list[float]) -> float:
    """Returns the product of all numbers in the given list."""
    result = 1.0
    for n in numbers:
        result *= n
    return result
