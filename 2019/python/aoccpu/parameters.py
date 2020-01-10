class InvalidInteraction(Exception):
    pass

def valueParameter(program, x, set = False, value = 0):
    if set:
        raise InvalidInteraction

    return x

def memoryParameter(program, x, set = False, value = 0):
    if set:
        program[x] = value

    return program[x]

class RelativeParameter:
    offset = 0

    def adjust_offset(self, program, position, param1, *_):
        self.offset += param1(program, program[position + 1])
        return position + 2

    def __call__(self, program, x, set = False, value = 0):
        if set:
            program[self.offset + x] = value
        
        return program[self.offset + x]
