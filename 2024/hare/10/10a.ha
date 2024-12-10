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

type outofbounds = !void;

fn point_from_coords(x: int, y: int, bounds: point) (point | outofbounds) = {
    if (x < 0 || y < 0 || (x : u32) >= bounds.x || (y : u32) >= bounds.y) {
        return outofbounds;
    };

    return point { x = (x : u32), y = (y : u32)};
};

@test fn point_from_coords() void = {
    const a = point_from_coords(1, 4, point { x = 10, y = 10})!;
    assert(a.x == 1);
    assert(a.y == 4);
};

export fn main() void = {
    let bounds = point { x = 0u, y = 0u };
    let map: [][]i8 = [];
    defer free(map);

    let queue: []point = [];

    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::torunes(strings::fromutf8(line)!);
            case io::EOF => break;
        };
        bounds.x = (len(line) : u32);
        bounds.y += 1;

        let l : []i8 = [];

        for(let i = 0z; i < len(line); i += 1) {
            const r = line[i];
            const n = (((r : u32) - 48) : i8);
            fmt::print(n)!;
            append(l, n);

            if (n == 0) {
                append(queue, point { x = (i: u32), y = bounds.y - 1});
            };
        };
        append(map, l);
        fmt::println()!;
    };

    let result = 0;
    for(const p .. queue) {
        let partial = 0;
        let q2: []point = [];
        append(q2, p);
        for (len(q2) > 0) {
            let n: []point  = [];
            for (const p2 .. q2) {
                if (map[p2.y][p2.x] == 9) {
                    partial += 1;
                } else {
                    for (let d .. [[-1, 0], [1, 0], [0, -1], [0, 1]]) {
                        const next = match(point_from_coords((p2.x : int) + d[0], (p2.y : int) + d[1], bounds)) {
                            case let next: point => yield next;
                            case outofbounds => continue;
                        };
                        if (map[next.y][next.x] == map[p2.y][p2.x] + 1) {
                            append(n, next);
                        };
                    };
                };
            };
            delete(q2[0..]);
            q2 = n[0..];
        };
        result += partial;
        fmt::printfln("For p[x:{}, y:{}] score is {}", p.x, p.y, partial)!;
    };

    fmt::printfln("Result is {}", result)!;
};