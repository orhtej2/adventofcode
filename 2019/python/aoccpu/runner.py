from functools import partial
from . import opcodes as ops
from . import decoder
from . import parameters as param

def run(program, source = None, sink = None):
    position = 0

    opcodes = {
        1: ops.o_add,
        2: ops.o_multiply,
        3: partial(ops.o_input, source),
        4: partial(ops.o_output, sink),
        5: ops.o_jumpIfTrue,
        6: ops.o_jumpIfFalse,
        7: ops.o_lessThan,
        8: ops.o_equal,
        99: ops.o_done
    }

    parameters = {
        0: param.memoryParameter,
        1: param.valueParameter
    }

    try:
        while True:
            (opcode, mode1, mode2, mode3) = decoder.decode(program[position])
            #print(opcode)
            operation = opcodes.get(opcode, f'Invalid opcode {opcode}')
            if isinstance(operation, str):
                print(f"{position}:{program[position]}")
            position = operation(program, position, parameters.get(mode1), parameters.get(mode2), parameters.get(mode3))
    except ops.BreakoutException:
        print('Reached 99 at position ', position)
        pass