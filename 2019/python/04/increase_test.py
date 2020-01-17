import unittest
from aoc2019_04 import number_utilities

class UtilitiesTest(unittest.TestCase):
    def test_lower(self):
        cases = [
            ("1", "2"),
            ("11", "12"),
            ("9", "10"),
            ("111199", "111200"),
            ("9999", "10000")
        ]

        for case in cases:
            result = number_utilities.increase(number_utilities.asArray(case[0]))
            self.assertListEqual(
                result,
                number_utilities.asArray(case[1]),
                 f'first={case[0]}, second={case[1]}, result={result}')
