class BreakoutException(Exception):
    pass

def o_add(input_list, position):
    #print('Adding ', input_list[position+1], ' and ({position+2})', input_list[position+2])
    input_list[input_list[position+3]] = input_list[input_list[position+1]] + input_list[input_list[position+2]]

def o_multiply(input_list, position):
    #print('Multiplying ', input_list[position+1], ' and ({position+2})', input_list[position+2])
    input_list[input_list[position+3]] = input_list[input_list[position+1]] * input_list[input_list[position+2]]

def o_done(input_list, position):
    raise BreakoutException

def run(program):
    position = 0

    opcodes = {
        1: o_add,
        2: o_multiply,
        99: o_done
    }

    try:
        while True:
            opcodes.get(program[position], 'Invalid opcode')(program, position)
            position += 4
    except BreakoutException:
        #print('Reached 99 at position ', position)
        pass

    return program[0]


with open('input2.txt', 'r') as f:
    line = f.readline()

program = list(map(int, line.split(',')))
print(program)

for noun in range(0, 99):
    for verb in range(0, 99):
        input = program[:]
        input[1] = noun
        input[2] = verb
        result = run(input)
        if result == 19690720:
            break
    if result == 19690720:
        break

print (100 * noun + verb)

