import sys
from aoc2019 import case01, case02

with open(sys.argv[1], 'r') as f:
    lines = f.readlines()

input = [x.strip().split(')') for x in lines]

#print(input)


#print(grouped)

print(case01.count(input))
print(case02.count(input))
#print(list(map(lambda key: (key, grouped[key]), filter(lambda y : len(grouped[y]) > 1, grouped))))