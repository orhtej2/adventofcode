from math import copysign

def _adjust(left, right, target):
    if left.x != right.x:
        target.vx += copysign(1, left.x - right.x)
    if left.y != right.y:
        target.vy += copysign(1, left.y - right.y)
    if left.z != right.z:
        target.vz += copysign(1, left.z - right.z)

def step(planets, copied=None, count=0):
    copied = [planet.copy() for planet in planets] if copied == None else copied
    count = len(planets) if count == 0 else count
    for i in range(count):
        for j in range(count):
            if i == j:
                continue
            _adjust(copied[i], copied[j], planets[j])

    for i in range(count):
        planets[i].x += planets[i].vx
        planets[i].y += planets[i].vy
        planets[i].z += planets[i].vz
        copied[i].assign(planets[i])
