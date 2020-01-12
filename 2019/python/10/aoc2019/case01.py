from math import gcd, copysign

def _gcd(a, b):
    while True:
        g = gcd(a, b)
        #print(f'{a} {b} {g}')
        if g == 1:
            return (a, b)
        a //= g
        b //= g

def count_visible(asteroids, coordinates):
    result = set()

    for a in asteroids:
        if a == coordinates:
            continue
        dy = coordinates[1] - a[1]
        dx = coordinates[0] - a[0]
        sign = dx*dy
        d = _gcd(abs(dx), abs(dy))
        la = (copysign(d[0], sign), d[1], a > coordinates)
        lb = coordinates[1] - (dy/dx)*coordinates[0] if dx != 0 else coordinates[1]

        # print(f'{a}: {la}, {lb}')
        result.add((la, lb))

        # print (f'{a}:y = {la}x + {lb}')
        # c = True
        # for x in range(min(coordinates[0], a[0]) + 1, max(coordinates[0], a[0])):
        #     if (x, la*x + lb) in asteroids:
        #         c = False
        #         print((x, la*x + lb))
        #         break
        # if c:
        #     result.add(a)

    # f = list((result))
    # f.sort()
    # print(f)
    return len(result)

def find_optimal(asteroids):
    return max(count_visible(asteroids, asteroid) for asteroid in asteroids)