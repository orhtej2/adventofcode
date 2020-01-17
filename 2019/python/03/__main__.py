from sys import argv
from aoc2019_03 import case01, case02

# execute only if run as a script
with open(argv[1], 'r') as f:
    first = f.readline()
    second = f.readline()

print(case01.main(first, second))
print(case02.main(first, second))
