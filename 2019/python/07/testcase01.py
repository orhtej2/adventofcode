import unittest
from utilities import case01

class TestCase01(unittest.TestCase):    
    def test_sample1(self):
        testcase = [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
        configuration = [4,3,2,1,0]
        self.assertEqual(43210, case01.Chain(testcase, configuration)())

    def test_sample2(self):
        testcase = [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
        configuration = [0,1,2,3,4]
        self.assertEqual(54321, case01.Chain(testcase, configuration)())

    def test_sample3(self):
        testcase = [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
        configuration = [1,0,4,3,2]
        self.assertEqual(65210, case01.Chain(testcase, configuration)())