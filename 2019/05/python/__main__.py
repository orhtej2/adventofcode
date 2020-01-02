import sys
from aoccpu import runner

def return1():
    return 1

with open(sys.argv[1], 'r') as f:
    line = f.readline()

program = list(map(int, line.split(',')))

print(program)

runner.run(program, return1)

print(program)
