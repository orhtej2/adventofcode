import sys
from aoccpu import runner

class Hull:
    def __init__(self):
        self.painted = {(0,0):1}
        self.count_painted = 0
    
    def count(self):
        return len(self.painted)
    
    def left(self):
        return min(self.painted, key=lambda k : k[0])

    def right(self):
        return max(self.painted, key=lambda k : k[0])

    def top(self):
        return min(self.painted, key=lambda k : k[1])

    def bottom(self):
        return max(self.painted, key=lambda k : k[1])
    
    def paint(self, coords, color):
        self.painted[coords] = color
        self.count_painted += 1

    def sample(self, coords):
        return self.painted[coords] if coords in self.painted else 0

class Robot:
    def __init__(self, hull):
        self.hull = hull
        self.x = 0
        self.y = 0
        self.color = True
        self.direction = 0

    def get(self):
        coords = (self.x, self.y)
        color = self.hull.sample(coords)
        #print (f'Got {color} at {coords}')
        return color

    def set(self, value):
        if self.color:
            coords = (self.x, self.y)
            #print (f'Paint {value} at {coords}')
            self.hull.paint(coords, value)
        else:
            d = self.direction
            self.direction += value * 2 - 1
            self.direction += 4
            self.direction %= 4
            if self.direction == 0:
                self.y += 1
            elif self.direction == 1:
                self.x += 1
            elif self.direction == 2:
                self.y -= 1
            else:
                self.x -= 1
           # print(f'I{d},o{value},r{self.direction},p({self.x},{self.y})')
            
        
        self.color = not self.color

class _Input:
    _is_first = True
    def __init__(self, first, next):
        self._first = first
        self.next = next

    def __call__(self):
        value = self._first if self._is_first else self.next()
        self._is_first = False

        return value


with open(sys.argv[1], 'r') as f:
    line = f.readline()

_program = list(map(int, line.split(',')))
program = { x : _program[x] for x in range(len(_program))  }

hull = Hull()
robot = Robot(hull)

r = runner.Runner(program)
r.run(source=robot.get, sink=robot.set)

count = hull.count()
l = hull.left()[0]
r = hull.right()[0]
t = hull.top()[1]
b = hull.bottom()[1]

print(f'Count: {count}')
print(f'({l},{t}) to ({r},{b})')
for y in range(t, b+1):
    line = ""
    for x in range(l, r+1):
        line += " " if hull.sample((x, y)) == 0 else "#"
    print(line)
            