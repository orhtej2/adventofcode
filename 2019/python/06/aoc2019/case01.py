def count_suborbits(orbits, key, distance):
    x = distance
    if key in orbits:
        for suborbit in orbits[key]:
            #print(f'recursing {suborbit}')
            x += count_suborbits(orbits, suborbit, distance + 1)
    #print(f'returning {x} for {key}')
    return x

def count(input):
    orbits = {}

    for x in input:
        orbits.setdefault(x[0], []).append(x[1])
    return count_suborbits(orbits, 'COM', 0)