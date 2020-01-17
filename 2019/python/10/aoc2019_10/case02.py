import math
from . import utils

def sweep(asteroids, center, count=-1):
    lines = {}

    for asteroid in asteroids:
        if asteroid == center:
            continue

        angle = (360 + math.atan2( asteroid[0]- center[0], center[1] - asteroid[1]) *180 / math.pi) % 360
        #print(angle)
        lines.setdefault(angle, []).append(asteroid)
    
    for line in lines:
        lines[line].sort(key=lambda a : abs(a[0] - center[0]) + abs(a[1] - center[1]))
    #print(lines)
    
    keys = list(lines)
    keys.sort()
    # print(keys)
    result = []
    hit = True
    while hit and (count == -1 or len(result) < count):
        hit = False
        for key in keys:
            if len(lines[key]) > 0:
                result.append(lines[key][0])
                del lines[key][:1]
                hit = True
    return result
