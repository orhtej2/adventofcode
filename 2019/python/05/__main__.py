import sys
from aoccpu import runner
def showOutput(value):
    print(f'Output = {{ {value} }}')

with open(sys.argv[1], 'r') as f:
    line = f.readline()

program = list(map(int, line.split(',')))

#print(program)

runner.Runner(program[:]).run(lambda : 1, showOutput)
runner.Runner(program).run(lambda : 5, showOutput)
