def parse(line):
    posx = 0
    posy = 0
    for token in line.split(','):
        value = int(token[1:])
        if token[0] == 'U':
            yield ((posx, posy), (posx, posy + value))
            posy += value
        if token[0] == 'D':
            yield ((posx, posy), (posx, posy - value))
            posy -= value
        if token[0] == 'R':
            yield ((posx, posy), (posx + value, posy))
            posx += value
        if token[0] == 'L':
            yield ((posx, posy), (posx - value, posy))
            posx -= value

def apply(case, horizontal_runnable, vertical_runnable):
    if case[0][0] == case[1][0]: #vertical
        return vertical_runnable(case[0][0], case[0][1], case[1][1])
    else: #horizontal
        return horizontal_runnable(case[0][1], case[0][0], case[1][0])

