import unittest
from . import decoder as d

class DecoderTests(unittest.TestCase):
    def test_getParameterMode(self):
        cases = [
            (100, 1, 1),
            (100, 2, 0),
            (1100, 2, 1),
        ]

        for case in cases:
            self.assertEqual(d.getParameterMode(case[0], case[1]), case[2], case)

    def test_decode(self):
        cases = [
            (101, (1, 1, 0, 0)),
            (10121, (21, 1, 0, 1)),
            (2, (2, 0, 0, 0)),
        ]

        for case in cases:
            self.assertEqual(d.decode(case[0]), case[1], case)


if __name__ == "__main__":
    unittest.main()