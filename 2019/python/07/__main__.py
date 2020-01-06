import sys
from itertools import permutations
from utilities import case01


with open(sys.argv[1], 'r') as f:
    line = f.readline()

program = list(map(int, line.split(',')))

input = [0,1,2,3,4]

result = 0
winning_perm = []
for perm in permutations(input):
    chain = case01.Chain(program, perm)
    r = chain()
    if r > result:
        result = r
        winning_perm = perm

print (f'And the winner is {winning_perm} with score of {result}')