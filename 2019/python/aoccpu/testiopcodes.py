from unittest import TestCase,mock
import opcodes


class TestOpcodes(TestCase):
    def test_o_add(self):
        program = [0, 0, 0, 0, 0]
        mock1 = mock.MagicMock(return_value = 1)
        mock2 = mock.MagicMock(return_value = 2)
        mock3 = mock.MagicMock()
        self.assertEqual(5, opcodes.o_add(program, 1, mock1, mock2, mock3))
        mock1.assert_called()
        mock2.assert_called()
        mock3.assert_called_once_with(program, 0, True, 3)
 
    def test_o_multiply(self):
        program = [2, 7, 5, 4, 8]
        mock1 = mock.MagicMock(return_value = 3)
        mock2 = mock.MagicMock(return_value = 2)
        mock3 = mock.MagicMock()
        self.assertEqual(5, opcodes.o_multiply(program, 1, mock1, mock2, mock3))
        mock1.assert_called_once_with(program, 5)
        mock2.assert_called_once_with(program, 4)
        mock3.assert_called_once_with(program, 8, True, 6)

    def test_o_input(self):
        program = [0, 0, 7]
        mock1 = mock.MagicMock(return_value = 2)
        mock2 = mock.MagicMock()
        self.assertEqual(3, opcodes.o_input(mock1, program, 1, mock2))
        mock1.assert_called_once_with()
        mock2.assert_called_once_with(program, 7, True, 2)

    def test_o_output(self):
        program = [0, 0, 7]
        mock1 = mock.MagicMock(return_value = 2)
        mock2 = mock.MagicMock()
        self.assertEqual(3, opcodes.o_output(mock2, program, 1, mock1))
        mock1.assert_called_once_with(program, 7)
        mock2.assert_called_once_with(2)

    def test_o_jumpIfTrue_true(self):
        program = [0, 2, 1, 7, 2]
        mock1 = mock.MagicMock(return_value = 1)
        mock2 = mock.MagicMock(return_value = 2)
        self.assertEqual(2, opcodes.o_jumpIfTrue(program, 2, mock1, mock2, None))
        mock1.assert_called_once_with(program, 7)
        mock2.assert_called_once_with(program, 2)

    def test_o_jumpIfTrue_false(self):
        program = [0, 2, 1, 7, 2]
        mock1 = mock.MagicMock(return_value = 0)
        mock2 = mock.MagicMock(return_value = 2)
        self.assertEqual(5, opcodes.o_jumpIfTrue(program, 2, mock1, mock2, None))
        mock1.assert_called_once_with(program, 7)
        mock2.assert_not_called()

    def test_o_jumpIfFalse_false(self):
        program = [0, 2, 1, 7, 2]
        mock1 = mock.MagicMock(return_value = 0)
        mock2 = mock.MagicMock(return_value = 2)
        self.assertEqual(2, opcodes.o_jumpIfFalse(program, 2, mock1, mock2, None))
        mock1.assert_called_once_with(program, 7)
        mock2.assert_called_once_with(program, 2)

    def test_o_jumpIfFalse_true(self):
        program = [0, 2, 1, 7, 2]
        mock1 = mock.MagicMock(return_value = 1)
        mock2 = mock.MagicMock(return_value = 2)
        self.assertEqual(5, opcodes.o_jumpIfFalse(program, 2, mock1, mock2, None))
        mock1.assert_called_once_with(program, 7)
        mock2.assert_not_called()

