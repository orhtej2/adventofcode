class BreakoutException(Exception):
    pass
    
class FunctionThrownException(Exception):
    def __init__(self, outer, step):
        self.outer = outer
        self.step = step

def o_add(input_list, position, param1, param2, param3):
    param3(input_list, input_list[position+3], True, param1(input_list, input_list[position+1]) + param2(input_list, input_list[position+2]))
    return position + 4

def o_multiply(input_list, position, param1, param2, param3):
    param3(input_list, input_list[position+3], True, param1(input_list, input_list[position+1]) * param2(input_list, input_list[position+2]))
    return position + 4

def o_input(source, input_list, position, param1, *_):
    param1(input_list, input_list[position+1], True, source())
    return position + 2

def o_output(sink, input_list, position, param1, *_):
    value = param1(input_list, input_list[position+1])
    try:
        sink(value)
        return position + 2
    except Exception as e:
        raise FunctionThrownException(e, position + 2)

def o_jumpIfTrue(input_list, position, param1, param2, _):
    operand = param1(input_list, input_list[position+1])
    if operand != 0:
        address = param2(input_list, input_list[position+2])
        #print(f'(t{position})Jumping to {address} because of {operand}')
        return address
    #print(f'(t{position})Not jumping to because of {operand}')
    return position + 3

def o_jumpIfFalse(input_list, position, param1, param2, _):
    operand = param1(input_list, input_list[position+1])
    if operand == 0:
        address = param2(input_list, input_list[position+2])
        #print(f'(f{position})Jumping to {address} because of {operand}')
        return address
    #print(f'(f{position})Not jumping to because of {operand}')
    return position + 3

def o_lessThan(input_list, position, param1, param2, param3):
    x = param1(input_list, input_list[position+1])
    y = param2(input_list, input_list[position+2])
    param3(input_list, input_list[position+3], True, 1 if x < y else 0)
    return position + 4

def o_equal(input_list, position, param1, param2, param3):
    x = param1(input_list, input_list[position+1])
    y = param2(input_list, input_list[position+2])
    param3(input_list, input_list[position+3], True, 1 if x == y else 0)
    return position + 4

def o_done(input_list, position, *_):
    raise BreakoutException
