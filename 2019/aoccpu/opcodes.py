class BreakoutException(Exception):
    pass

def o_add(input_list, position, param1, param2, param3):
    param3(input_list, input_list[position+3], True, param1(input_list, input_list[position+1]) + param2(input_list, input_list[position+2]))
    return 4

def o_multiply(input_list, position, param1, param2, param3):
    param3(input_list, input_list[position+3], True, param1(input_list, input_list[position+1]) * param2(input_list, input_list[position+2]))
    return 4

def o_input(source, input_list, position, param1, param2, param3):
    param1(input_list, input_list[position+1], True, source())
    return 2

def o_output(input_list, position, param1, param2, param3):
    print(f'Output = {{ {param1(input_list, input_list[position+1])} }}')
    return 2

def o_done(input_list, position, *_):
    raise BreakoutException
