from functools import partial
from . import opcodes as ops
from . import decoder
from . import parameters as param

def run(program, source = None):
    position = 0

    opcodes = {
        1: ops.o_add,
        2: ops.o_multiply,
        3: partial(ops.o_input, source),
        4: ops.o_output,
        99: ops.o_done
    }

    parameters = {
        0: param.memoryParameter,
        1: param.valueParameter
    }

    try:
        while True:
            (opcode, mode1, mode2, mode3) = decoder.decode(program[position])
            advance = opcodes.get(opcode, 'Invalid opcode')(program, position, parameters.get(mode1), parameters.get(mode2), parameters.get(mode3))
            position += advance
    except ops.BreakoutException:
        print('Reached 99 at position ', position)
        pass