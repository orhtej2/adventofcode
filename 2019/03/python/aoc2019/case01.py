import math
from functools import partial
from aoc2019.utilities import parser

def find_intersection(dictionary, key, range_lower, range_upper):
    result = math.inf
    for i in range(range_lower, range_upper):
        if i in dictionary:
            for line in dictionary[i]:
                if key > line[0] and key < line[1]:
                    distance = math.fabs(i) + math.fabs(key)
                    if distance != 0 and distance < result:
                        result = distance

    return result

def main(first, second):
    result = math.inf
    horizontal = {}
    vertical = {}

    for line in parser.parse(first):
        parser.apply(line,
                     lambda y, x0, x1 : horizontal.setdefault(y, []).append((x0, x1)),
                     lambda x, y0, y1 : vertical.setdefault(x, []).append((y0, y1)))

    #done parsing #1
    for line in parser.parse(second):
        distance = parser.apply(line,
            partial(find_intersection, vertical),
            partial(find_intersection, horizontal))

        result = min(result, distance)

    print(vertical)
    print(horizontal)
    return result
