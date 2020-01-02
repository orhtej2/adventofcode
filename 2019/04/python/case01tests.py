import unittest
from aoc2019 import case01

class Case01Tests(unittest.TestCase):
    def test_valid(self):
        cases = [
            [1, 2, 2, 3, 4, 5],
            [1, 1, 1, 1, 2, 3],
            [3, 3, 5, 7, 7, 9]
        ]

        for case in cases:
            self.assertTrue(case01.isValid(case), f"{case}")

    def test_invalid(self):
        cases = [
            [1, 2, 3, 4, 5, 6],
            [1, 2, 1, 1, 2, 3],
            [3, 3, 5, 7, 7, 0]
        ]

        for case in cases:
            self.assertFalse(case01.isValid(case), f"{case}")
