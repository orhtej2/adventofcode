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

type fence = struct {
    x: int,
    y: int,
    d: direction,
};

type outofbounds = !void;

type set = struct {
    entries: [64][]point,
    all: []point,
    count: u32,
};

type fence_set = struct {
    entries: [64][]fence,
    all: [4][]fence,
};

fn fence_hash(f: fence) u32 = {
	let hash = fnv::fnv32a();
    let buf: [4]u8 = [0...];
    endian::leputu32(buf, f.x : u32);
    hash::write(&hash, buf);
    endian::leputu32(buf, f.y : u32);
    hash::write(&hash, buf);
    endian::leputu32(buf, f.d: u32);
    hash::write(&hash, buf);
	return hash::fnv::sum32(&hash);
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
    append(set.all, val);
    return true;
};

fn fence_contains(set: const *fence_set, val: fence) bool = {
    const hash = fence_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i].x == val.x && bucket[i].y == val.y && bucket[i].d == val.d) {
            return true;
        };
    };

    return false;
};

fn fence_set_append(set: *fence_set, val: fence)bool  = {
    const hash = fence_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i].x == val.x && bucket[i].y == val.y && bucket[i].d == val.d) {
            return false;
        };
    };

    append(bucket, val);
    append(set.all[val.d], val);
    return true;
};

fn free_set(set: *set)void = {
    free(set.all);
    for (let i = 0z; i < len(set.entries); i += 1) {
        free(set.entries[i]);
    };

};

fn point_from_coords(x: int, y: int, bounds: point) (point | outofbounds) = {
    if (x < 0 || y < 0 || (x : u32) >= bounds.x || (y : u32) >= bounds.y) {
        return outofbounds;
    };

    return point { x = (x : u32), y = (y : u32)};
};

export fn main() void = {
    let bounds = point { x = 0, y = 0 };

    let map: [][]rune = [];
    defer free(map);

    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::torunes(strings::fromutf8(line)!);
            case io::EOF => break;
        };
        bounds.x = (len(line) : u32);
        bounds.y += 1;

        append(map, line);
    };

    let spots: [][]u32 = alloc([[]...], bounds.y);

    for (let i = 0z; i < bounds.y; i += 1) {
        spots[i] = alloc([0...], bounds.x);
    };

    for (let i = 0z; i < bounds.y; i += 1) {
        for (let j = 0z; j < bounds.x; j += 1) {
            fmt::print(map[i][j])!;
        };
        fmt::println()!;
    };
    fmt::println()!;

    let num: u32 = 0u;
    let result = 0u;
    let resultp2 = 0u;
    for (let y = 0u : u32 ; y < bounds.y; y += 1) {
        for (let x = 0u : u32; x < bounds.y; x += 1) {
            if (map[y][x] != '.') {
                const r = map[y][x];
                let seen = set {...};
                set_append(&seen, point { x = x, y = y});
                defer free_set(&seen);
                let fs = fence_set {...};
                let q2: []point = alloc([point { x = x, y = y}], 1);
                let fc : u32 = 0u;
                for (len(q2) > 0) {
                    let n = set { ... };        
                    defer free_set(&n);
                    for (const p2 .. q2) {
                        spots[p2.y][p2.x] = num;
                        // fmt::printfln("Erasing x{}/y{} with {}", p2.x, p2.y, r)!;
                        //[-1, 0], [1, 0], [0, -1], [0, 1]
                        for (const d .. [fence { x = -1, y = 0, d = direction::LEFT}, fence { x = 1, y = 0, d = direction::RIGHT},
                            fence { x = 0, y = -1, d = direction::UP}, fence { x = 0, y = 1, d = direction::DOWN} ]) {
                            const next = point_from_coords((p2.x : int) + d.x, (p2.y : int) + d.y, bounds);
                            if (next is outofbounds) {
                                // fmt::printfln("oob fence at {}/{} from {}/{}",(p2.x : int) + d[0], (p2.y : int) + d[1], p2.x, p2.y)!;
                                fence_set_append(&fs, fence {x = (p2.x : int) + d.x, y = (p2.y : int) + d.y, d = d.d});
                                fc += 1;
                            } else {
                                const next = (next : point);
                                if (map[next.y][next.x] == r) {
                                    if (set_append(&seen, next)) {
                                        set_append(&n, next);
                                    };
                                } else {
                                    // fmt::printfln("fence at {}/{} from {}/{}",next.x, next.y, p2.x, p2.y)!;
                                    fence_set_append(&fs, fence {x = (next.x : int), y = (next.y : int), d = d.d});
                                    fc += 1;
                                };
                            };
                        };
                    };
                    free(q2);
                    q2 = alloc(n.all[..len(n.all)], len(n.all));
                };
                for (const p .. seen.all) {
                    map[p.y][p.x] = '.';
                };
                num += 1;
                fmt::printfln("For {} count is {} fence is {}", r, seen.count, fc)!;

                fmt::println()!;

                result += (fc : uint * seen.count : uint);
                let side = 0u;
                for (const d..[direction::UP, direction::DOWN]) {
                    // fmt::printf("{} has [", (d : u32))!;
                    // for (const p .. fs.all[d]) { 
                    //     fmt::printf("{}/{} ", p.x, p.y)!;
                    // };
                    //  fmt::println("]")!;
                    for (true) {
                        if (len(fs.all[d]) == 0) {
                            break;
                        };
                        const p = fs.all[d][0];
                        // fmt::printfln("Point is {}/{} d {}", p.x, p.y, (p.d : u32))!;
                        side += 1;
                        delete(fs.all[d][0]);
                        for (let i = p.x + 1; i <= (bounds.x : int); i += 1) {
                            if (fence_contains(&fs, fence {x = i, y = p.y, d = d})) {
                                for (let j = 0z; j < len(fs.all[d]); j += 1) {
                                    if (fs.all[d][j].x == i && fs.all[d][j].y == p.y) {
                                        // fmt::printfln("Deleting {}/{} d {} at pos {}", fs.all[d][j].x, fs.all[d][j].y, (fs.all[d][j].d : u32), j)!;
                                        delete(fs.all[d][j]);
                                        break;
                                    };
                                };
                            } else {
                                break;
                            };
                        };
                        for (let i = p.x - 1; i >= -1; i -= 1) {
                            if (fence_contains(&fs, fence {x = i, y = p.y, d = d})) {
                                for (let j = 0z; j < len(fs.all[d]); j += 1) {
                                    if (fs.all[d][j].x == i && fs.all[d][j].y == p.y) {
                                        // fmt::printfln("Deleting {}/{} d {} at pos {}", fs.all[d][j].x, fs.all[d][j].y, (fs.all[d][j].d : u32), j)!;
                                        delete(fs.all[d][j]);
                                        break;
                                    };
                                };
                            } else {
                                break;
                            };
                        };
                    };
                };
                for (const d..[direction::LEFT, direction::RIGHT]) {
                    // fmt::printf("{} has [", (d : u32))!;
                    // for (const p .. fs.all[d]) { 
                    //     fmt::printf("{}/{} ", p.x, p.y)!;
                    // };
                    //  fmt::println("]")!;
                    for (len(fs.all[d]) > 0) {
                        const p = fs.all[d][0];
                        // fmt::printfln("Point is {}/{} d {}", p.x, p.y, (p.d : u32))!;
                        side += 1;
                        delete(fs.all[d][0]);
                        for (let i = p.y + 1; i <= (bounds.y : int); i += 1) {
                            if (fence_contains(&fs, fence {x = p.x, y = i, d = d})) {
                                for (let j = 0z; j < len(fs.all[d]); j += 1) {
                                    if (fs.all[d][j].x == p.x && fs.all[d][j].y == i) {
                                        // fmt::printfln("Deleting {}/{} d {} at pos {}", fs.all[d][j].x, fs.all[d][j].y, (fs.all[d][j].d : u32), j)!;
                                        delete(fs.all[d][j]);
                                        break;
                                    };
                                };
                            } else {
                                break;
                            };
                        };
                        for (let i = p.y - 1; i >= -1; i -= 1) {
                            if (fence_contains(&fs, fence {x = p.x, y = i, d = d})) {
                                for (let j = 0z; j < len(fs.all[d]); j += 1) {
                                    if (fs.all[d][j].x == p.x && fs.all[d][j].y == i) {
                                        // fmt::printfln("Deleting {}/{} d {} at pos {}", fs.all[d][j].x, fs.all[d][j].y, (fs.all[d][j].d : u32), j)!;
                                        delete(fs.all[d][j]);
                                        break;
                                    };
                                };
                            } else {
                                break;
                            };
                        };
                    };
                };
                fmt::printfln("{} has {} sides with {} count total price {}", r, side, seen.count, (seen.count : uint) * side)!;
                resultp2 += (seen.count : uint) * side;
            };
        };
    };

    for (let i = 0z; i < bounds.y; i += 1) {
        for (let j = 0z; j < bounds.x; j += 1) {
            fmt::print(spots[i][j])!;
        };
        fmt::println()!;
    };

    fmt::printfln("Result is {} p2 {}", result, resultp2)!;
};