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

type crate = struct {
    l: point,
    r: point,
};

type set_entry = struct {
    p: point,
    c: crate,
};

type crate_set = struct {
    entries: [64][]set_entry,
    all: []crate,
};

fn crate_contains(set: const *crate_set, val: point) (crate | bool) = {
    const hash = point_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i].p.x == val.x && bucket[i].p.y == val.y) {
            return bucket[i].c;
        };
    };

    return false;
};

fn crate_set_append(set: *crate_set, val: crate)bool  = {
    const hash = point_hash(val.l);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if ((bucket[i].p.x == val.l.x && bucket[i].p.y == val.l.y)) {
            return false;
        };
    };

    const hash2 = point_hash(val.r);
    let bucket2 = &set.entries[hash2 % len(set.entries)];
    for (let i = 0z; i < len(bucket2); i += 1) {
        if ((bucket2[i].p.x == val.r.x && bucket2[i].p.y == val.r.y)) {
            return false;
        };
    };

    append(bucket, set_entry { p = val.l, c = val });
    append(bucket2, set_entry { p = val.r, c = val });
    append(set.all, val);
    return true;
};

fn crate_set_remove(set: *crate_set, val: point)bool  = {
    for (let i = 0z; i < len(set.all); i += 1) {
        if ((set.all[i].l.x == val.x && set.all[i].l.y == val.y) || (set.all[i].r.x == val.x && set.all[i].r.y == val.y)) {
            const hash = point_hash(set.all[i].l);
            let bucket = &set.entries[hash % len(set.entries)];
            let found = false;
            for (let j = 0z; j < len(bucket); j += 1) {
                if (bucket[j].p.x == set.all[i].l.x && bucket[j].p.y == set.all[i].l.y) {
                    fmt::printfln("Deleting {}/{}", bucket[j].p.x, bucket[j].p.y)!;
                    delete(bucket[j]);
                    found = true;
                    break;
                };
            };
            assert(found);
            const hash = point_hash(set.all[i].r);
            let bucket = &set.entries[hash % len(set.entries)];
            let found = false;
            for (let j = 0z; j < len(bucket); j += 1) {
                if (bucket[j].p.x == set.all[i].r.x && bucket[j].p.y == set.all[i].r.y) {
                    fmt::printfln("Deleting {}/{}", bucket[j].p.x, bucket[j].p.y)!;
                    delete(bucket[j]);
                    found = true;
                    break;
                };
            };
            assert(found);
            delete(set.all[i]);

            return true;
        };
    };

    return false;
};

fn free_crate_set(set: *crate_set)void = {
    free(set.all);
    for (let i = 0z; i < len(set.entries); i += 1) {
        free(set.entries[i]);
    };
};

fn can_move(walls: const *set, crates: *crate_set, new_loc: point, d: direction) bool = {
    if (contains(walls, new_loc)) {
        return false;
    };

    const c = crate_contains(crates, new_loc);
    if (c is crate) {
        const c = (c : crate);
        const nl = next_point(c.l, d);
        const nr = next_point(c.r, d);
        if (d == direction::UP || d == direction::DOWN) {
            return can_move(walls, crates, nr, d) && can_move(walls, crates, nl, d);
        } else if (d == direction::LEFT) {
            return can_move(walls, crates, nl, d);
        } else {
            return can_move(walls, crates, nr, d);
        };
    };

    return true;
};

fn move(walls: const *set, crates: *crate_set, new_loc: point, d: direction) bool = {
    if (contains(walls, new_loc)) {
        return false;
    };

    const c = crate_contains(crates, new_loc);
    if (c is crate) {
        const c = (c : crate);
        fmt::printfln("Found crate {}/{}, {}/{}", c.l.x, c.l.y, c.r.x, c.r.y)!;
        const nl = next_point(c.l, d);
        const nr = next_point(c.r, d);
        if (can_move(walls, crates, nl, d) && can_move(walls, crates, nr, d)) {
            if (d == direction::UP || d == direction::DOWN) {
                fmt::printfln("moving {}/{} and {}/{}", nl.x, nl.y, nr.x, nr.y)!;
                move(walls, crates, nr, d);
                move(walls, crates, nl, d);
            } else if (d == direction::LEFT) {
                fmt::printfln("moving l {}/{}", nl.x, nl.y)!;
                move(walls, crates, nl, d);
            } else {
                fmt::printfln("moving r {}/{}", nr.x, nr.y)!;
                move(walls, crates, nr, d);
            };
            crate_set_remove(crates, new_loc);
            // fmt::printfln("Appending {}/{} {}/{}", nl.)
            crate_set_append(crates, crate { l = nl, r = nr});
            return true;
        } else {
            return false;
        };
    };

    return true;
};

fn print(walls: const * set, crates: const * crate_set, pos: point, x: u32, y: u32) void = {
    for (let i: u32 = 0; i < y; i += 1) {
        for (let j: u32 = 0; j < x; j += 1) {
            if (contains(walls, point { x = j, y = i})) {
                fmt::print("#")!;
            } else if (i == pos.y && j == pos.x) {
                fmt::print("@")!;
            } else {
                const c = crate_contains(crates, point { x = j, y = i});
                if (c is crate) {
                    const c = (c : crate);
                    if (c.l.x == j && c.l.y == i) {
                        fmt::print("[")!;
                    } else if (c.r.x == j && c.r.y == i) {
                        fmt::print("]")!;
                    };
                } else {
                    fmt::print(".")!;
                };
            };
        };
        fmt::println()!;
    };
    fmt::println()!;
};

export fn main() void = {
    let walls = set { ... };
    defer free_set(&walls);
    let crates = crate_set { ... };
    defer free_crate_set(&crates);
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
                set_append(&walls, point { x = 2*x, y = y});
                set_append(&walls, point { x = 2*x+1, y = y});
            } else if (line[x] == 'O') {
                crate_set_append(&crates, crate { l = point { x = 2*x, y = y}, r = point { x = 2*x + 1, y = y}});
            } else if (line[x] == '@') {
                pos.x = 2*x;
                pos.y = y;
            };
        };
        y += 1;
        x = (len(line) : u32) * 2;
    };

    // for (const c .. crates.all) {
    //     fmt::printfln("l {}/{} r {}/{}", c.l.x, c.l.y, c.r.x, c.r.y)!;
    // };

    print(&walls, &crates, pos, x, y);

    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::torunes(strings::fromutf8(line)!);
            case io::EOF => break;
        };
        defer free(line);

        // let i = 0;

        for (const r .. line) {
            const d = get_direction(r)!;
            const n = next_point(pos, d);
            if (move(&walls, &crates, n, d)) {
                pos = n;
            };

            fmt::println("Going ", r)!;
            // print(&walls, &crates, pos, x, y);
            // i += 1;
            // fmt::println(i)!;

            // if (i > 5) {
            //     return;
            // };
        };
    };

    print(&walls, &crates, pos, x, y);
    let score : u64 = 0;

    for (const c .. crates.all) {
        score += c.l.x + 100 * c.l.y;
    };

    fmt::println("Score is ", score)!;
};