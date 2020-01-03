import math

def getParameterMode(opcode, position):
    return math.floor((opcode / math.pow(10, position + 1)) % 10) 

def decode(opcode):
    return (opcode % 100, getParameterMode(opcode, 1), getParameterMode(opcode, 2), getParameterMode(opcode, 3))