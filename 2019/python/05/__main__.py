import sys
from aoccpu import runner

def return1():
    return 1

def return5():
    return 5

def showOutput(value):
    print(f'Output = {{ {value} }}')

with open(sys.argv[1], 'r') as f:
    line = f.readline()

program = list(map(int, line.split(',')))

#print(program)

runner.run(program[:], return1, showOutput)
runner.run(program, return5, showOutput)
