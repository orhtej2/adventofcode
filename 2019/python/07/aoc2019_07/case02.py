from functools import partial, partialmethod
from . import amplifier

class _ReachedOutput(Exception):
    def __init__(self, value):
        self.value = value

def _func(value):
    raise _ReachedOutput(value)

class Chain:
    def __init__(self, program, configuration):
        self.program = program
        self.configuration = configuration

    def __call__(self):
        amps = [amplifier.Amplifier(dict(self.program), self.configuration[i]) for i in range(5)]
        for i in range(5):
            amps[i].output = _func

        stage = 0
        result = 0
        while True:
            try:
                #print(f'Running stage {stage} with input {result}')
                amps[stage](result)
                return result
            except _ReachedOutput as e:
                #print(f'Got out, {e.value}')
                result = e.value
                stage += 1
                stage %= 5

        return result