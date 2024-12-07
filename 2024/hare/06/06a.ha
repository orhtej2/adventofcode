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
    return true;
};

fn set_clone(s: *set) set = {
    let retval = set {
        ...
    };

    for (let i = 0z; i < len(s.entries); i += 1) {
        for (let j = 0z; j < len(s.entries[i]); j += 1) {
            append(retval.entries[i], s.entries[i][j]);
        };
    };

    return retval;
};

export fn main() void = {
    let obstacles = set {
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

    let result = 0;

    let add = set {
        ...
    };

    for (let x : u32 = 1u; x <= maxx; x += 1) {
        for (let y : u32 = 1u; y <= maxy; y += 1) {
            if (contains(&obstacles, point { x = x, y = y})) {
                continue;
            };
            let o2 = set_clone(&obstacles);
            set_append(&o2, point { x = x, y = y});
            let direction = direction::UP;
            let turns = set {
                ...
            };
            let s2 = point { x = start.x, y = start.y};
            let prev = s2;

            let loop = false;

            for(true) {
                const n = next(s2, direction);
                if (n.x == 0 || n.y == 0 || n.x > maxx || n.y > maxy) {
                    break;
                };

                if (contains(&o2, n)) {
        //            fmt::printfln("Prev {},{}, target {},{}, current {},{}", prev.x, prev.y, n.x, n.y, s2.x, s2.y)!;
                    if ((s2.x != prev.x || s2.y != prev.y) && contains(&turns, s2)) {
                        loop = true;
                        break;
                    };
                    set_append(&turns, s2);
                    direction = turn(direction);
                    prev = s2;
                } else {
                    prev = s2;
                    s2 = n;
                };
            };

            if (loop) {
                set_append(&add, point { x = x, y = y});
                result += 1;
            };
        };
    };

    for (let y : u32 = 1u; y <= maxy; y += 1) {
        for (let x : u32 = 1u; x <= maxx; x += 1) {
            const p = point { x = x, y = y};
            if (contains(&obstacles, p)) {
                fmt::printf("#")!;
            } else if (contains(&add, p)) {
                fmt::printf("O")!;
            } else if (start.x == x && start.y == y) {
                fmt::printf("^")!;
            } else {
                fmt::printf(".")!;
            };
        };
        fmt::println()!;
    };

    fmt::printfln("Possible {} cells", result)!;
};