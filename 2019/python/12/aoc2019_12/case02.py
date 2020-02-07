from . import runner

def different(left, right, count):
    #print(f'{left} {right}')
    for i in range(count):
        if left[i] != right[i]:
            return True
    
    return False

def loop(planets):
    count = len(planets)
    initial = [planet.copy() for planet in planets]
    copied = [planet.copy() for planet in planets]
    steps = 1
    runner.step(planets, copied, count)
    while different(initial, planets, count):
        steps += 1
        runner.step(planets, copied, count)

    return steps