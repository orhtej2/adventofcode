import math

result = 0
with open('input2.txt', 'r') as f:
    for line in f:
        print('\n\na',line)
        print(int(line)/3)
        print(math.floor(int(line)/3))
        added = math.floor(int(line)/3)-2
        print (added)
        result = result + added

print(result)

