from aoccpu import runner as run

class _Input:
    _is_first = True
    def __init__(self, first, next):
        self._first = first
        self.next = next

    def __call__(self):
        value = self._first if self._is_first else self.next
        self._is_first = False

        return value

class Amplifier:
    def __init__(self, program, mode):
        self.runner = run.Runner(program)
        self.mode = mode
    
    value = -1
    output = None
    _is_first = True

    def _set_value(self, value):
        self.value = value
        if self.output != None:
             self.output(value)
        

    def __call__(self, input):
        self.value = -1
        inputf = _Input(self.mode, input) if self._is_first else lambda : input
        self._is_first = False
        self.runner.run(inputf, self._set_value)
        return self.value