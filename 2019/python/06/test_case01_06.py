import unittest
from aoc2019_06 import case01

class Case01Test(unittest.TestCase):
    def test_count1(self):
        input = { 'COM': ['B'] }

        self.assertEqual(1, case01.count_suborbits(input, 'COM', 0))

    def test_count2(self):
        input = { 'COM': ['B'],
                  'B': ['C'] }

        self.assertEqual(3, case01.count_suborbits(input, 'COM', 0))

    def test_count3(self):
        input = { 'COM': ['B'],
                  'B': ['C', 'D'] }

        self.assertEqual(5, case01.count_suborbits(input, 'COM', 0))

    def test_count4(self):
        input = { 'COM': ['B'],
                  'B': ['C', 'D'],
                  'C': ['E'] }

        self.assertEqual(8, case01.count_suborbits(input, 'COM', 0))

    def test_countModel(self):
        input = { 'COM': ['B'],
                   'B': ['C', 'G'],
                   'C': ['D'],
                   'D': ['E', 'I'],
                   'E': ['F', 'J'],
                   'G': ['H'],
                   'J': ['K'],
                   'K': ['L']
        }

        self.assertEqual(42, case01.count_suborbits(input, 'COM', 0))