import sys

def split(array, pixels):
    return (array[x*pixels:(x+1)*pixels] for x in range(len(array)//pixels))

with open(sys.argv[1], 'r') as f:
    line = f.readline()

size = 6*25

#line ="111222"

input = list(map(int, line.strip()))

#print(input)
input_splitted = list(split(input, size))
#print(len(input)/size)
#print(input_splitted[-1])
#print(input_splitted)

aggregated = (list((x.count(0), x.count(1), x.count(2))) for x in input_splitted)
max_0 = min(aggregated, key=lambda x: x[0])
print(f'{max_0}, {max_0[1] * max_0[2]}')