import unittest
from aoc2019_07 import case01

class TestCase01(unittest.TestCase):    
    def test_sample1(self):
        testcase = {0:3,1:15,2:3,3:16,4:1002,5:16,6:10,7:16,8:1,9:16,10:15,11:15,12:4,13:15,14:99,15:0,16:0}
        configuration = [4,3,2,1,0]
        self.assertEqual(43210, case01.Chain(testcase, configuration)())

    def test_sample2(self):
        testcase = {0:3,1:23,2:3,3:24,4:1002,5:24,6:10,7:24,8:1002,9:23,10:-1,11:23,12:101,13:5,14:23,15:23,16:1,17:24,18:23,19:23,20:4,21:23,22:99,23:0,24:0}
        configuration = [0,1,2,3,4]
        self.assertEqual(54321, case01.Chain(testcase, configuration)())

    def test_sample3(self):
        testcase = {0:3,1:31,2:3,3:32,4:1002,5:32,6:10,7:32,8:1001,9:31,10:-2,11:31,12:1007,13:31,14:0,15:33,16:1002,17:33,18:7,19:33,20:1,21:33,22:31,
                    23:31,24:1,25:32,26:31,27:31,28:4,29:31,30:99,31:0,32:0,33:0}
        configuration = [1,0,4,3,2]
        self.assertEqual(65210, case01.Chain(testcase, configuration)())