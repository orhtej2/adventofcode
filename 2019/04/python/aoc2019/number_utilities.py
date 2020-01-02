def asArray(input):
    return list(map(int, list(input)))
    
def isLowerOrEqual(first, second):
    if (len(second) != len(first)):
        return len(second) > len(first)
    
    i = 0
    while i < len(first):
        if (second[i] < first[i]):
            return False
        if (second[i] > first[i]):
            return True
        i+=1
    
    return True

def increase(input):

    def increase(position):
        if input[position] < 9:
            input[position] += 1
            return 0
        
        input[position] = 0
        return 1
    
    carry = 0
    for i in range(len(input), 0, -1):
        carry = increase(i - 1)
        if carry == 0:
            break

    if carry == 1:
        input.insert(0, 1)
    
    return input