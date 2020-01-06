from functools import partial, partialmethod
from aoccpu import runner

class Amplifier:
    def __init__(self, program, input):
        self.program = program
        self.input = input

    value = 0
    def _set_value(self, value):
        self.value = value

    def __call__(self):
        runner.run(self.program, self.input, self._set_value)
        return self.value

class Input:
    which = True
    def __init__(self, first, second):
        print(f'{first} {second}')
        self.first = first
        self.second = second
    
    def __call__(self):
        val = self.first if self.which else self.second
        self.which = not self.which
        print(f'returning {val}')
        return val


class Chain:
    stage = 0

    def __init__(self, program, configuration):
        self.program = program
        self.configuration = configuration

    def __call__(self):
        result = 0
        for stage in range(0, 5):
            amp = Amplifier(self.program[:], Input(self.configuration[stage], result))
            result = amp()

        return result