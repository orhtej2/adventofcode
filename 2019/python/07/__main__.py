import sys
from itertools import permutations
from aoc2019_07 import case01, case02


with open(sys.argv[1], 'r') as f:
    line = f.readline()

_program = list(map(int, line.split(',')))
program = (x : _program[x] for x in range(len(_program)) ) 

input = [0,1,2,3,4]

result = 0
winning_perm = []

for perm in permutations(input):
    r = case01.Chain(program, perm)()
    if r > result:
        result = r
        winning_perm = perm

print (f'And the winner for case 1 is {winning_perm} with score of {result}')

input = [5,6,7,8,9]
for perm in permutations(input):
    r = case02.Chain(program, perm)()
    if r > result:
        result = r
        winning_perm = perm

print (f'And the winner for case 2 is {winning_perm} with score of {result}')
