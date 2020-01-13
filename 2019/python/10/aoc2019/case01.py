from . import utils

def count_visible(asteroids, coordinates):
    result = set()

    for a in asteroids:
        if a == coordinates:
            continue
        
        line = utils.compute_line(a, coordinates)
        # print(f'{a}: {la}, {lb}')
        result.add((line, a > coordinates))

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
    return max(((asteroid, count_visible(asteroids, asteroid)) for asteroid in asteroids), key=lambda x : x[1])