use bufio;
use endian;
use fmt;
use hash;
use hash::fnv;
use io;
use os;
use strings;

type point = struct {
    x: u32,
    y: u32,
};

type direction = enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
};

fn turn(direction: direction) direction = {
    if (direction == direction::UP) {
        return direction::RIGHT;
    };
    if (direction == direction::RIGHT) {
        return direction::DOWN;
    };
    if (direction == direction::DOWN) {
        return direction::LEFT;
    };

    return direction::UP;
};

fn next(origin: point, direction: direction) point = {
    if (direction == direction::UP) {
        return point { x = origin.x, y = origin.y - 1};
    };
    if (direction == direction::RIGHT) {
        return point { x = origin.x + 1, y = origin.y };
    };
    if (direction == direction::DOWN) {
        return point { x = origin.x, y = origin.y + 1};
    };

    return point { x = origin.x - 1, y = origin.y };
};

type set = struct {
    entries: [64][]point,
    count: u32,
};

fn point_hash(point: point) u32 = {
	let hash = fnv::fnv32a();
    let buf: [4]u8 = [0...];
    endian::leputu32(buf, point.x);
    hash::write(&hash, buf);
    endian::leputu32(buf, point.y);
    hash::write(&hash, buf);
	return hash::fnv::sum32(&hash);
};

fn contains(set: const *set, val: point) bool = {
    const hash = point_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i].x == val.x && bucket[i].y == val.y) {
            return true;
        };
    };

    return false;
};

fn set_append(set: *set, val: point)bool  = {
    const hash = point_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i].x == val.x && bucket[i].y == val.y) {
            return false;
        };
    };

    append(bucket, val);
    set.count += 1;
    return true;
};

export fn main() void = {
    let obstacles = set {
        count = 0u,
        ...
    };
    let start = point {
        x = 0u,
        y = 0u,
    };
    let maxx: u32 = 0u, maxy : u32 = 0u;

    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::torunes(strings::fromutf8(line)!);
            case io::EOF => break;
        };
        defer free(line);
        maxy += 1;
        maxx = (len(line) : u32);
        for (let i = 0z; i < len(line); i += 1) {
            if (line[i] == '#') {
                set_append(&obstacles, point { x = ((i + 1) : u32), y = maxy});
            } else if (line[i] == '^') {
                start.x = ((i + 1) : u32);
                start.y = maxy;
            };
        };
    };

    let direction = direction::UP;
    let visited = set {
        count = 0u,
        ...
    };
    set_append(&visited, start);
    for(true) {
        const n = next(start, direction);
        if (n.x == 0 || n.y == 0 || n.x > maxx || n.y > maxy) {
            break;
        };

        if (contains(&obstacles, n)) {
            direction = turn(direction);
        } else {
            set_append(&visited, n);
            start = n;
        };
    };

    fmt::printfln("Visited {} cells", visited.count)!;
};