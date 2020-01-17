import unittest
from aoc2019_04 import case02

class Case02Tests(unittest.TestCase):
    def test_valid(self):
        cases = [
            [1, 2, 2, 3, 4, 5],
            [0, 0, 1, 1, 2, 3],
            [3, 3, 7, 7, 7, 9],
            [3, 3, 3, 7, 7, 9],
            [3, 3, 7, 7, 7, 7],
            [1, 1, 3, 7, 7, 9],
            [1, 1, 4, 4, 4, 4],
            [2, 2, 2, 2, 3, 3]
        ]

        for case in cases:
            self.assertTrue(case02.isValid(case), f"{case}")

    def test_invalid(self):
        cases = [
            [1, 2, 3, 4, 4, 4],
            [1, 2, 3, 4, 5, 6],
            [1, 1, 1, 1, 2, 3],
            [5, 3, 3, 7, 7, 0],
            [1, 3, 3, 3, 7, 0]
        ]

        for case in cases:
            self.assertFalse(case02.isValid(case), f"{case}")
