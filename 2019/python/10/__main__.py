import sys
from aoc2019_10 import case01, case02, utils

with open(sys.argv[1], 'r') as f:
    lines = f.readlines()

asteroids = utils.parse(lines)
#print (asteroids)

result = case01.find_optimal(asteroids)

print (result)

result2 = list(case02.sweep(asteroids, result[0]))

print(f'{result2[199][0]*100+result2[199][1]}')