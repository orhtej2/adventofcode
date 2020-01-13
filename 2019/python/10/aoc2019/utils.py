from math import copysign, gcd

def parse(lines):
    asteroids = []

    for y in range(len(lines)):
        for x in range(len(lines[y])):
            if lines[y][x] =='#':
                asteroids.append((x,y))

    return asteroids

def _gcd(a, b):
    while True:
        g = gcd(a, b)
        #print(f'{a} {b} {g}')
        if g == 1:
            return (a, b)
        a //= g
        b //= g

def compute_line(a1, a2):
    dy = a1[1] - a2[1]
    dx = a1[0] - a2[0]
    sign = dx*dy
    d = _gcd(abs(dx), abs(dy))
    la = (copysign(d[0], sign), d[1])
    lb = a2[1] - (dy/dx)*a2[0] if dx != 0 else a2[1]

    return (la, lb)