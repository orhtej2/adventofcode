import unittest
from aoc2019_03 import case02

class Case01(unittest.TestCase):
    def test_example(self):
        result = case02.main(
            "R8,U5,L5,D3",
            "U7,R6,D4,L4"
        )

        self.assertEqual(30, result)

    def test_sample01(self):
        result = case02.main(
            "R75,D30,R83,U83,L12,D49,R71,U7,L72",
            "U62,R66,U55,R34,D71,R55,D58,R83"
        )

        self.assertEqual(610, result)

    def test_sample02(self):
        result = case02.main(
            "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51",
            "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
        )

        self.assertEqual(410, result)

if __name__ == '__main__':
    unittest.main()