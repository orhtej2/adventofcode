import unittest
import isGreaterOrEqual_test
import increase_test
import case01_04_test
import case02_04_test

if __name__ == '__main__':
    suite = unittest.TestSuite()
    suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(isGreaterOrEqual_test.UtilitiesTest))
    suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(increase_test.UtilitiesTest))
    suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(case01_04_test.Case01Tests))
    suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(case02_04_test.Case02Tests))
    runner = unittest.TextTestRunner(descriptions=True, verbosity=2)
    runner.run(suite)
