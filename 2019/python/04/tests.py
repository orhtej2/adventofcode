import unittest
import isGreaterOrEqualTests
import increaseTests
import case01tests
import case02tests

if __name__ == '__main__':
    suite = unittest.TestSuite()
    suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(isGreaterOrEqualTests.UtilitiesTest))
    suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(increaseTests.UtilitiesTest))
    suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(case01tests.Case01Tests))
    suite.addTests(unittest.defaultTestLoader.loadTestsFromTestCase(case02tests.Case02Tests))
    runner = unittest.TextTestRunner(descriptions=True, verbosity=2)
    runner.run(suite)
