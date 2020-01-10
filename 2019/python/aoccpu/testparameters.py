import unittest
import parameters

class TestParameters(unittest.TestCase):
    def test_position(self):
        program = [1,7]
        self.assertEqual(1, parameters.memoryParameter(program, 0))
        self.assertEqual(7, parameters.memoryParameter(program, 1))
        self.assertListEqual([1, 7], program)

    def test_positionSet(self):
        program = [0, 0]
        self.assertEqual(1, parameters.memoryParameter(program, 0, True, 1))
        self.assertListEqual([1, 0], program)
    
    def test_value(self):
        program = [2]
        self.assertEqual(5, parameters.valueParameter(program, 5))
        self.assertListEqual([2], program)
    
    def test_valueCannotSet(self):
        try:
            program = [2]
            parameters.valueParameter(program, 0, True, 2)
            self.fail("Should have thrown")
        except parameters.InvalidInteraction:
            pass
        except Exception as e:
            self.fail(f"Wrong exception {e}")
