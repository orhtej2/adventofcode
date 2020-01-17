import unittest
from aoc2019_10 import utils, case02

class Case02Tests(unittest.TestCase):
    def test_sample1(self):
        input = [
            ".#....#####...#..",
            "##...##.#####..##",
            "##...#...#.#####.",
            "..#.....#...###..",
            "..#.#.....#....##"
        ]

        parsed = utils.parse(input)
        expected = [(8, 1), (9, 0), (9,1), (10, 0), (9, 2), (11, 1), (12,1), (11,2), (15,1), 
                    (12,2), (13,2), (14,2), (15,2), (12,3), (16,4), (15,4), (10,4), (4,4), 
                    (2,4), (2, 3), (0,2), (1,2), (0,1), (1,1), (5,2), (1,0), (5,1),
                    (6, 1), (6, 0), (7,0), (8,0), (10,1), (14,0), (16, 1), (13,3), (14,3)]
        self.assertEqual(expected, 
        list(case02.sweep(parsed, (8, 3))))

    def test_sample5(self):
        input = [
            ".#..##.###...#######",
            "##.############..##.",
            ".#.######.########.#",
            ".###.#######.####.#.",
            "#####.##.#.##.###.##",
            "..#####..#.#########",
            "####################",
            "#.####....###.#.#.##",
            "##.#################",
            "#####.##.###..####..",
            "..######..##.#######",
            "####.##.####...##..#",
            ".#####..#.######.###",
            "##...#.##########...",
            "#.##########.#######",
            ".####.#.###.###.#.##",
            "....##.##.###..#####",
            ".#.#.###########.###",
            "#.#.#.#####.####.###",
            "###.##.####.##.#..##"
        ]

        parsed = utils.parse(input)

        result = case02.sweep(parsed, (11, 13))
        expected = [(11,12), (12,1), (12,2)]
        self.assertEqual(expected, result[:3])
        self.assertEqual((12,8), result[9])
        self.assertEqual((16,9), result[49])
        self.assertEqual((10,16), result[99])
        self.assertEqual((11,1), result[298])

        expected = [(9,6), (8,2), (10,9)]
        self.assertEqual(expected, result[198:201])