import math
from functools import partial
from aoc2019.utilities import parser

def find_intersection(current_distance, dictionary, key, range_lower, range_upper):
    result = math.inf
    for i in range(range_lower, range_upper, 1 if range_upper > range_lower else -1):
        if i in dictionary:
            for line in dictionary[i]:
                if key > min(line[:2]) and key < max(line[:2]):
                    distance = line[2] + math.fabs(line[0] - key) + math.fabs(range_lower - i) + current_distance
                    print("Intersection ", key, " between ", line[0], " and ", line[1], ", distance ", line[2], " computed ", distance)
                    if distance != 0 and distance < result:
                        result = distance

    return (result, current_distance + math.fabs(range_lower - range_upper))

def append_to_list(dictionary, distance, a, b0, b1):
    dictionary.setdefault(a, []).append((b0, b1, distance))
    return distance + math.fabs(b0 - b1)

def main(first, second):
    result = math.inf
    horizontal = {}
    vertical = {}
    current_distance = 0
    for line in parser.parse(first):
        current_distance = parser.apply(line,
            partial(append_to_list, horizontal, current_distance),
            partial(append_to_list, vertical, current_distance))
    
    print(horizontal)
    print(vertical)
    print()

    #done parsing #1
    current_distance = 0
    for line in parser.parse(second):
        (distance, current_distance) = parser.apply(line,
            partial(find_intersection, current_distance, vertical),
            partial(find_intersection, current_distance, horizontal))

        result = min(result, distance)

    return result
