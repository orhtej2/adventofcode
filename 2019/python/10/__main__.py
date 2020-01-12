import sys
from aoc2019 import case01, parser

with open(sys.argv[1], 'r') as f:
    lines = f.readlines()

asteroids = parser.parse(lines)
#print (asteroids)

result = case01.find_optimal(asteroids)

print (result)