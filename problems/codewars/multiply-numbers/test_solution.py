import pytest

from solution import solve


@pytest.mark.parametrize(
    "numbers,expected",
    [
        ([1, 2, 3], 6),
        ([0, 1, 2], 0),
        ([-2, 4], -8),
        ([5], 5),
    ],
)
def test_solve(numbers, expected):
    assert solve(numbers) == expected
