from math import copysign, gcd

def _different(left, right, i):
    #print(f'{left} {right}')
    return (left[0][2*i] != right[0][2*i] or left[0][2*i+1] != right[0][2*i+1] or
            left[1][2*i] != right[1][2*i] or left[1][2*i+1] != right[1][2*i+1] or
            left[2][2*i] != right[2][2*i] or left[2][2*i+1] != right[2][2*i+1] or
            left[3][2*i] != right[3][2*i] or left[3][2*i+1] != right[3][2*i+1])

def _adjust(left, right, target, i):
    if left[i*2] != right[i*2]:
        target[i*2+1] += copysign(1, left[i*2] - right[i*2])

def _step(planets, copied, dimension):
    _adjust(copied[0], copied[1], planets[1], dimension)
    _adjust(copied[0], copied[2], planets[2], dimension)
    _adjust(copied[0], copied[3], planets[3], dimension)
    _adjust(copied[1], copied[0], planets[0], dimension)
    _adjust(copied[1], copied[2], planets[2], dimension)
    _adjust(copied[1], copied[3], planets[3], dimension)
    _adjust(copied[2], copied[1], planets[1], dimension)
    _adjust(copied[2], copied[0], planets[0], dimension)
    _adjust(copied[2], copied[3], planets[3], dimension)
    _adjust(copied[3], copied[1], planets[1], dimension)
    _adjust(copied[3], copied[2], planets[2], dimension)
    _adjust(copied[3], copied[0], planets[0], dimension)

    planets[0][dimension*2] += planets[0][dimension*2 + 1]
    planets[1][dimension*2] += planets[1][dimension*2 + 1]
    planets[2][dimension*2] += planets[2][dimension*2 + 1]
    planets[3][dimension*2] += planets[3][dimension*2 + 1]

    copied[0][dimension*2] = planets[0][dimension*2]
    copied[0][dimension*2+1] = planets[0][dimension*2+1]
    copied[1][dimension*2] = planets[1][dimension*2]
    copied[1][dimension*2+1] = planets[1][dimension*2+1]
    copied[2][dimension*2] = planets[2][dimension*2]
    copied[2][dimension*2+1] = planets[2][dimension*2+1]
    copied[3][dimension*2] = planets[3][dimension*2]
    copied[3][dimension*2+1] = planets[3][dimension*2+1]

def _loop(initial, dimension):
    steps = 1
    planets = [t[:] for t in initial]
    copied = [t[:] for t in initial]
    #print(planets)
    _step(planets, copied, dimension)
    #print(planets)
    while(_different(initial, planets, dimension)):
        steps += 1
        _step(planets, copied, dimension)

    return steps


def loop(planets):
    assert(len(planets) == 4)
    steps = [1,1,1]
    for x in range(3):
        initial = [[p.x, 0, p.y, 0, p.z, 0] for p in planets]
        steps[x] = _loop(initial, x)
    
    print(steps)

    result = steps[0] * steps[1] // gcd(steps[0], steps[1])
    result = steps[2] * result // gcd(steps[2], result)

    return result