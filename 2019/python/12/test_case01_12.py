import unittest
from aoc2019_12 import planet, case01, runner

class Case01Tests(unittest.TestCase):
    def test_step(self):
        input=[planet.Planet(-1, 0, 2),
               planet.Planet(2, -10, -7),
               planet.Planet(4, -8, 8),
               planet.Planet(3, 5, -1)]

        expected=[planet.Planet(2, -1, 1, 3, -1, -1),
               planet.Planet(3, -7, -4, 1, 3, 3),
               planet.Planet(1, -7, 5, -3, 1, -3),
               planet.Planet(2, 2, 0, -1, -3, 1)]
        
        runner.step(input)
        self.assertListEqual(expected, input)

    def test_energy(self):
        input=[planet.Planet(-1, 0, 2),
               planet.Planet(2, -10, -7),
               planet.Planet(4, -8, 8),
               planet.Planet(3, 5, -1)]
        
        case01.run(input, 10)
        self.assertEqual(179, case01.energy(input))