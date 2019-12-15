import math

def fuelForModule(mass):
    print(mass)
    print(mass/3)
    print(math.floor(mass/3))
    added = math.floor(mass/3)-2
    print (added)
    return added


result = 0
added = 0
with open('input2.txt', 'r') as f:
    for line in f:
        added = fuelForModule(int(line))
        result = result + added
        while True:
            added = fuelForModule(added)
            print ('adding ', added)
            if added > 0:
                result += added
            else:
                break

print ('adding for fuel', result)

added = result


print(result)

