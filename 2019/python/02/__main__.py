import sys
from aoccpu import runner

with open(sys.argv[1], 'r') as f:
    line = f.readline()

program = list(map(int, line.split(',')))

program[1] = 12
program[2] = 2
print(program)

runner.Runner(program).run()

print(program)
