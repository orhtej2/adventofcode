import unittest
from aoc2019 import parser, case01

class Case01Tests(unittest.TestCase):
    def test_sample1(self):
        input = [
            ".#..#",
            ".....",
            "#####",
            "....#",
            "...##"
        ]

        parsed = parser.parse(input)

        self.assertEqual(8, case01.count_visible(parsed, (3,4)))

    def test_sample2(self):
        input = [
            "......#.#.",
            "#..#.#....",
            "..#######.",
            ".#.#.###..",
            ".#..#.....",
            "..#....#.#",
            "#..#....#.",
            ".##.#..###",
            "##...#..#.",
            ".#....####"
        ]

        parsed = parser.parse(input)

        self.assertEqual(33, case01.count_visible(parsed, (5,8)))

    def test_sample3(self):
        input = [
            "#.#...#.#.",
            ".###....#.",
            ".#....#...",
            "##.#.#.#.#",
            "....#.#.#.",
            ".##..###.#",
            "..#...##..",
            "..##....##",
            "......#...",
            ".####.###."
        ]

        parsed = parser.parse(input)

        self.assertEqual(35, case01.count_visible(parsed, (1,2)))

    def test_sample4(self):
        input = [
            ".#..#..###",
            "####.###.#",
            "....###.#.",
            "..###.##.#",
            "##.##.#.#.",
            "....###..#",
            "..#.#..#.#",
            "#..#.#.###",
            ".##...##.#",
            ".....#.#.."
        ]

        parsed = parser.parse(input)

        self.assertEqual(41, case01.count_visible(parsed, (6,3)))


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

        parsed = parser.parse(input)

        self.assertEqual(210, case01.count_visible(parsed, (11, 13)))