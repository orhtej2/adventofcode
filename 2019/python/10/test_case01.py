import unittest
from aoc2019_10 import utils, case01

class Case01Tests(unittest.TestCase):
    def test_sample1(self):
        input = [
            ".#..#",
            ".....",
            "#####",
            "....#",
            "...##"
        ]

        parsed = utils.parse(input)

        self.assertEqual(8, case01.count_visible(parsed, (3,4)))
        self.assertEqual(((3,4), 8), case01.find_optimal(parsed))

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

        parsed = utils.parse(input)

        self.assertEqual(33, case01.count_visible(parsed, (5,8)))
        self.assertEqual(((5,8), 33), case01.find_optimal(parsed))

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

        parsed = utils.parse(input)

        self.assertEqual(35, case01.count_visible(parsed, (1,2)))
        self.assertEqual(((1,2), 35), case01.find_optimal(parsed))

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

        parsed = utils.parse(input)

        self.assertEqual(41, case01.count_visible(parsed, (6,3)))
        self.assertEqual(((6,3), 41), case01.find_optimal(parsed))


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

        self.assertEqual(210, case01.count_visible(parsed, (11, 13)))
        self.assertEqual(((11,13), 210), case01.find_optimal(parsed))
