use bufio;
use encoding::utf8;
use endian;
use fmt;
use hash;
use hash::fnv;
use io;
use math;
use os;
use strconv;
use strings;

type point = struct {
    x: u32,
    y: u32,
};

type direction = enum { DOWN, UP, LEFT, RIGHT };

type invalid = !void;

fn get_direction(r: rune) (direction | invalid) = {
    switch(r) {
        case '<' => return direction::LEFT;
        case '>' => return direction::RIGHT;
        case '^' => return direction::UP;
        case 'v' => return direction::DOWN;
        case => return invalid;
    };
};

@test fn get_direction() void = {
    assert(get_direction('d') is invalid);

    assert(get_direction('<')! == direction::LEFT);
};

fn next_point(p: point, d: direction) point = {
    switch (d) {
        case direction::LEFT => return point { x = p.x - 1, y = p.y };
        case direction::RIGHT => return point { x = p.x + 1, y = p.y };
        case direction::UP => return point { x = p.x, y = p.y - 1 };
        case direction::DOWN => return point { x = p.x, y = p.y + 1 };
    };
};

type set = struct {
    entries: [64][]point,
    all: []point,
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
    append(set.all, val);
    return true;
};

fn set_remove(set: *set, val: point)bool  = {
    const hash = point_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    let found = false;
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i].x == val.x && bucket[i].y == val.y) {
            found = true;
            delete(bucket[i]);
            break;
        };
    };

    if (found) {
        for (let i = 0z; i < len(set.all); i += 1) {
            if (set.all[i].x == val.x && set.all[i].y == val.y) {
                delete(set.all[i]);
                return true;
            };
        };
    };

    return found;
};

fn free_set(set: *set)void = {
    free(set.all);
    for (let i = 0z; i < len(set.entries); i += 1) {
        free(set.entries[i]);
    };
};

fn move(walls: const *set, crates: *set, new_loc: point, d: direction) bool = {
    if (contains(walls, new_loc)) {
        return false;
    };

    if (contains(crates, new_loc)) {
        const n = next_point(new_loc, d);
        if (move(walls, crates, n, d)) {
            set_remove(crates, new_loc);
            set_append(crates, n);
            return true;
        } else {
            return false;
        };
    };

    return true;
};

fn print(walls: const * set, crates: const * set, pos: point, x: u32, y: u32) void = {
    for (let i: u32 = 0; i < y; i += 1) {
        for (let j: u32 = 0; j < x; j += 1) {
            if (contains(walls, point { x = j, y = i})) {
                fmt::print("#")!;
            } else if (contains(crates, point { x = j, y = i})) {
                fmt::print("O")!;
            } else if (i == pos.y && j == pos.x) {
                fmt::print("@")!;
            } else {
                fmt::print(".")!;
            };
        };
        fmt::println()!;
    };
    fmt::println()!;
};

export fn main() void = {
    let walls = set { ... };
    defer free_set(&walls);
    let crates = set { ... };
    defer free_set(&crates);
    let pos = point { x = 0, y = 0 };

    let x : u32 = 0;
    let y : u32 = 0;

    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::torunes(strings::fromutf8(line)!);
            case io::EOF => break;
        };
        defer free(line);
        
        if (len(line) == 0) {
            break;
        };
        
        for (let x : u32 = 0; x < len(line); x += 1) {
            if (line[x] == '#') {
                set_append(&walls, point { x = x, y = y});
            } else if (line[x] == 'O') {
                set_append(&crates, point { x = x, y = y});
            } else if (line[x] == '@') {
                pos.x = x;
                pos.y = y;
            };
        };
        y += 1;
        x = (len(line) : u32);
    };

    print(&walls, &crates, pos, x, y);

    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::torunes(strings::fromutf8(line)!);
            case io::EOF => break;
        };
        defer free(line);

        for (const r .. line) {
            const d = get_direction(r)!;
            const n = next_point(pos, d);
            if (move(&walls, &crates, n, d)) {
                pos = n;
            };

            // fmt::println("Going ", r)!;
        };
    };

    print(&walls, &crates, pos, x, y);

    let score : u64 = 0;

    for (const c .. crates.all) {
        score += c.x + 100 * c.y;
    };

    fmt::println("Score is ", score)!;
};