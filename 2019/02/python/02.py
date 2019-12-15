class BreakoutException(Exception):
    pass

def o_add(input_list, position):
    print('Adding ', input_list[position+1], ' and ({position+2})', input_list[position+2])
    input_list[input_list[position+3]] = input_list[input_list[position+1]] + input_list[input_list[position+2]]

def o_multiply(input_list, position):
    print('Multiplying ', input_list[position+1], ' and ({position+2})', input_list[position+2])
    input_list[input_list[position+3]] = input_list[input_list[position+1]] * input_list[input_list[position+2]]

def o_done(input_list, position):
    raise BreakoutException

with open('input2.txt', 'r') as f:
    line = f.readline()

program = list(map(int, line.split(',')))

program[1] = 12
program[2] = 2
print(program)

position = 0

opcodes = {
    1: o_add,
    2: o_multiply,
    99: o_done
}

try:
    while True:
        opcodes.get(program[position], 'Invalid opcode')(program, position)
        print('Position ', position, ': ', program)
        position += 4
except BreakoutException:
    print('Reached 99 at position ', position)
    pass

print(program)
