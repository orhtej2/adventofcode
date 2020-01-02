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
