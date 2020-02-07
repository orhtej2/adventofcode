import sys
from aoc2019_12 import planet, case01, case02
with open(sys.argv[1]) as f:
    lines = f.readlines()

planets = list(planet.Planet(line=line) for line in lines) 

case01.run(planets, 1000)
print(case01.energy(planets))

planets2 = list(planet.Planet(line=line) for line in lines) 
print(case02.loop(planets2))