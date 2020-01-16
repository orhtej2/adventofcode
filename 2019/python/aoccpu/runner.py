from functools import partial
from . import opcodes as ops
from . import decoder
from . import parameters as param

class Runner:
    def __init__(self, program):
        self.program = program
        
        self.position = 0
        self.offset = param.RelativeParameter()
        self.opcodes = {
            1: ops.o_add,
            2: ops.o_multiply,
            5: ops.o_jumpIfTrue,
            6: ops.o_jumpIfFalse,
            7: ops.o_lessThan,
            8: ops.o_equal,
            9: self.offset.adjust_offset,
            99: ops.o_done
        }
        
        self.parameters = {
            0: param.memoryParameter,
            1: param.valueParameter,
            2: self.offset
        }

    def run(self, source = None, sink = None):
        self.opcodes[3] = partial(ops.o_input, source)
        self.opcodes[4] = partial(ops.o_output, sink)

        try:
            while True:
                (opcode, mode1, mode2, mode3) = decoder.decode(self.program[self.position])
                #print(f'{opcode} at {self.position}')
                operation = self.opcodes.get(opcode, f'Invalid opcode {opcode}')
                if isinstance(operation, str):
                    print(f"{self.position}:{self.program[self.position]}")
                    break
                try:
                    self.position = operation(self.program, self.position, self.parameters.get(mode1), self.parameters.get(mode2), self.parameters.get(mode3))
                except ops.FunctionThrownException as e:
                    #print(f'Thrown {e}, advancing to {e.step} first')
                    self.position = e.step
                    raise e.outer
        except ops.BreakoutException:
            #print('Reached 99 at position ', self.position)
            pass