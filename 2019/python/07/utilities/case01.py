from functools import partial, partialmethod
from . import amplifier

class Chain:
    stage = 0

    def __init__(self, program, configuration):
        self.program = program
        self.configuration = configuration

    def __call__(self):
        result = 0
        for stage in range(0, 5):
            amp = amplifier.Amplifier(self.program[:], self.configuration[stage])
            result = amp(result)

        return result