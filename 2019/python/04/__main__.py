from sys import argv, exit
from aoc2019_04 import case01, case02, number_utilities

if len(argv) < 3:
    print(f"Usage {argv[0]} <lower> <upper>")
    exit()

lower = number_utilities.asArray(argv[1])
upper = number_utilities.asArray(argv[2])

print (lower)
print(upper)

def count(operand, lower, upper):
    result = 0
    while number_utilities.isLowerOrEqual(lower, upper):
        if operand(lower):
            result += 1
        number_utilities.increase(lower)
    
    return result

print(count(case01.isValid, lower[:], upper))
print(count(case02.isValid, lower, upper))


