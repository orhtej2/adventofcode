from sys import argv
from aoc2019 import case01

# execute only if run as a script
with open(argv[1], 'r') as f:
    first = f.readline()
    second = f.readline()

result = case01.main(first, second)

print(result)