import sys
from aoccpu import runner

with open(sys.argv[1], 'r') as f:
    line = f.readline()

_program = list(map(int, line.split(',')))
program = { x : _program[x] for x in range(len(_program))  }

#print(program)

runner.Runner(dict(program)).run(source=lambda:1, sink=lambda x: print(f'Output {{{x}}}'))
runner.Runner(program).run(source=lambda:2, sink=lambda x: print(f'Output {{{x}}}'))