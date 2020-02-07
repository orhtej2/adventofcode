from . import runner

def run(planets, steps):
    for _ in range(steps):
        runner.step(planets)

def energy(planets):
    result = 0
    for planet in planets:
        result += (abs(planet.x) + abs(planet.y) + abs(planet.z)) * (abs(planet.vx) + abs(planet.vy) + abs(planet.vz))
    return result
