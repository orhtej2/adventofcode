import unittest
from aoc2019 import number_utilities

def runTest(assertion, cases):
    for case in cases:
        assertion(number_utilities.isLowerOrEqual(
            number_utilities.asArray(case[0]),
            number_utilities.asArray(case[1])
        ), f'first={case[0]}, second={case[1]}')

class UtilitiesTest(unittest.TestCase):
    def test_lower(self):
        cases = [
            ("1", "1"),
            ("1", "2"),
            ("1", "10"),
            ("111199", "111200"),
            ("11", "12")
        ]

        runTest(self.assertTrue, cases)

    def test_greater(self):
        cases = [
            ("2", "1"),
            ("20", "2"),
            ("100", "10"),
            ("21", "12"),
            ("21", "20")
        ]

        runTest(self.assertFalse, cases)
