from aoc2019 import number_utilities

def isValid(input):
#    print(f"Input {input}")
    hadDouble = False
    isCandidate = False
    prev = -1
    for i in range(len(input) - 1):
        if input[i+1] < input[i]:
            #print(f"a{input[i+1]}{input[i]}{prev}")
            return False
        if not hadDouble:
            if input[i+1] == input[i]:
                if isCandidate:
                    if input[i] == prev:
                        isCandidate = False
                else:
                    #print(f"Candidate {input[i+1]}{input[i]}{prev}")
                    isCandidate = input[i] != prev
            else:
                if isCandidate:
                    hadDouble = True
        prev = input[i]
    return hadDouble or isCandidate
