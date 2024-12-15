use bufio;
use fmt;
use io;
use os;
use regex;
use sort;
use strconv;
use strings;


type point = struct {
    x: u8,
    y: u8
};

type robot = struct {
    start: point,
    v_x: i8,
    v_y: i8,
};

type invalid = !void;

fn parse_robot(line: str) (robot | invalid) = {
    const b = regex::compile(`p=([0-9]+),([0-9]+) v=(-?[0-9]+),(-?[0-9]+)`)!;
    defer regex::finish(&b);
    const result = regex::find(&b, line);
    defer regex::result_free(result);

    if (len(result) < 5) {
        // fmt::println("Failed!")!;
        // for (const r .. result) {
        //     fmt::printfln(r.content)!;
        // };
        return invalid;
    };

    // fmt::printfln("x' {} y' {} c' {}", result[1].content, result[2].content, result[0].content)!;

    const x = match(strconv::stou8(result[1].content)) {
        case let x: u8 => yield x;
        case => return invalid;
    }, y = match(strconv::stou8(result[2].content)) {
        case let y: u8 => yield y;
        case => return invalid;
    }, vx = match(strconv::stoi8(result[3].content)) {
        case let x: i8 => yield x;
        case => return invalid;
    }, vy = match(strconv::stoi8(result[4].content)) {
        case let y: i8 => yield y;
        case => return invalid;
    };

    return robot { start = point { x = x, y = y }, v_x = vx, v_y = vy };
};

@test fn parse_robot() void = {
    assert(parse_robot("") is invalid);
    assert(parse_robot("sadfsagassadg") is invalid);

    const b = parse_robot("p=1,4 v=3,-3");
    assert (b is robot);
    const b = (b : robot);
    assert(b.start.x == 1);
    assert(b.start.y == 4);
    assert(b.v_x == 3);
    assert(b.v_y == -3);
};

fn simulate(r: robot, steps: u64, x: u8, y: u8) point = {
    let px : i64 = ((r.v_x : i64) * (steps : i64) + (r.start.x : i64)) % (x : i64);
    let py : i64 = ((r.v_y : i64) * (steps : i64) + (r.start.y : i64)) % (y : i64);

    // fmt::printfln("at {} - {} / {}", steps, px, py)!;

    if (px < 0) {
        px += (x : i64);
    };
    if (py < 0) {
        py += (y : i64);
    };

    const ret = point { x = (px : u8), y = (py : u8) };

    // fmt::printfln("{} / {}", ret.x, ret.y)!;

    return ret;
};

@test fn simulate() void = {
    const x : u8 = 11;
    const y : u8 = 7;

    const r = robot { start = point { x = 2, y = 4 }, v_x = 2, v_y = -3};
    
    const p = simulate(r, 0, x, y);
    assert(p.x == 2);
    assert(p.y == 4);

    const p = simulate(r, 1, x, y);
    assert(p.x == 4);
    assert(p.y == 1);

    const p = simulate(r, 2, x, y);
    assert(p.x == 6);
    assert(p.y == 5);

    const p = simulate(r, 3, x, y);
    assert(p.x == 8);
    assert(p.y == 2);

    const p = simulate(r, 4, x, y);
    assert(p.x == 10);
    assert(p.y == 6);

    const p = simulate(r, 5, x, y);
    assert(p.x == 1);
    assert(p.y == 3);
};

fn right(a: const *opaque, b: const *opaque) int = {
    const a = *(a: const *point), b = *(b: const *point);
    if (a.y < b.y) {
        return -1;
    } else if (a.y > b.y) {
        return 1;
    } else if (a.x < b.x) {
        return -1;
    } else if (a.x > b.x) {
        return 1;
    };
    return 0;
};

export fn main() void = {
    // const x : u8 = 11;
    // const y : u8 = 7;
    const x : u8 = 101;
    const y : u8 = 103;

    const mid_x = x/2;
    const mid_y = y/2;

    let robots : []robot = [];
    defer free(robots);
    for (true) {
        let linea = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };
        defer free(linea);

        append(robots, parse_robot(linea)!);
    };

    let result : u64 = 0;
    // fmt::printfln("Len is {} robots {}", len(rbq), len(robots))!;
    for (true) {
        let rbq : []point = alloc([point {x = 0, y = 0}...], len(robots));
        defer free(rbq);
        for (let i = 0z; i < len(robots); i += 1) {
            const p = simulate(robots[i], result, x, y);
            rbq[i] = p;
        };

        sort::sort(rbq, size(point), &right);
        let i = 0z;
        for (true) {
            // fmt::println(i)!;
            if (rbq[i].x == rbq[i+1].x && rbq[i].y == rbq[i+1].y) {
                delete(rbq[i]);
            } else {
                i += 1;
            };

            if (i == len(rbq) - 2) {
                break;
            };
        };

        let line = false;
        let i = 0z;
        for (true) {
            const p = rbq[i];
            let l2 = true;
            for (let j : u8 = 0; j < 9; j += 1 ) {
                if (rbq[j+i].y != p.y || rbq[j+i].x != p.x + j) {
                    l2 = false;
                    break;
                };
            };

            if (l2) {
                line = true;
                break;
            } else {
                i += 1;
            };

            if (i == len(rbq) - 10) {
                break;
            };
        };

        if (line) {
            let idxl = 0z;

            for (let i : u8 = 0; i < y; i += 1) {
                for (let j : u8 = 0; j < x; j += 1) {
                    if (idxl < len(rbq) && rbq[idxl].x == j && rbq[idxl].y == i) {
                        fmt::print("#")!;
                        idxl += 1;
                    } else {
                        fmt::print(".")!;
                    };
                };
                fmt::println()!;
            };

            fmt::println()!;
            fmt::printfln("Score is {}", result)!;
            break;
        };
        result += 1;
        if (result % 10000 == 0) {
            fmt::printfln("Done iteration {}", result)!;
        };
    };  
};