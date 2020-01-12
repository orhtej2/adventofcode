def parse(lines):
    asteroids = []

    for y in range(len(lines)):
        for x in range(len(lines[y])):
            if lines[y][x] =='#':
                asteroids.append((x,y))

    return asteroids