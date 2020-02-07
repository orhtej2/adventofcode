class Planet:
    def __init__(self, x=0, y=0, z=0, vx=0, vy=0, vz=0, line=None):
        if line != None:
            res = [int(field) for field in line.replace("<x=", "").replace(", y=", " ").replace(", z=", " ").replace(">","").split()]
            # print(res)
            self.x, self.y, self.z = res
        else:
            self.x, self.y, self.z = x,y,z
        self.vx = vx
        self.vy = vy
        self.vz = vz

    def __repr__(self):
        return '[Point({self.x}, {self.y}, {self.z}), Vel({self.vx}, {self.vy}, {self.vz})]'.format(self=self)

    def assign(self, other):
        self.x, self.y, self.z = other.x, other.y, other.z
        self.vx = other.vx
        self.vy = other.vy
        self.vz = other.vz

    def copy(self):
        newcopy = Planet()
        newcopy.x, newcopy.y, newcopy.z = self.x, self.y, self.z
        newcopy.vx, newcopy.vy, newcopy.vz = self.vx, self.vy, self.vz
        return newcopy

    __copy__ = copy

    def __eq__(self, other):
        return (self.x == other.x and self.y == other.y and self.z == other.z and
               self.vx == other.vx and self.vy == other.vy and self.vz == other.vz)