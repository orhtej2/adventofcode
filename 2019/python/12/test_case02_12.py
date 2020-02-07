import unittest
from aoc2019_12 import planet, case02

class Case02Tests(unittest.TestCase):
    def test_loop(self):
        input=[planet.Planet(-1, 0, 2),
               planet.Planet(2, -10, -7),
               planet.Planet(4, -8, 8),
               planet.Planet(3, 5, -1)]
        
        self.assertEqual(2772, case02.loop(input))

    #@unittest.skip
    def test_loop_long(self):
        input=[planet.Planet(-8, -10, 0),
               planet.Planet(5, 5, 10),
               planet.Planet(2, -7, 3),
               planet.Planet(9, -8, -3)]
        
        self.assertEqual(4686774924, case02.loop(input))