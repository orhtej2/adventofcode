from . import number_utilities

def isValid(input):
    hadDouble = False
    for i in range(len(input) - 1):
        if input[i+1] < input[i]:
            return False
        if not hadDouble and input[i+1] == input[i]:
            hadDouble = True
    return hadDouble
