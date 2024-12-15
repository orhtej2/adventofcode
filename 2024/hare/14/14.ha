use bufio;
use fmt;
use io;
use math;
use os;
use regex;
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

fn simulate(r: robot, steps: u32, x: u8, y: u8) point = {
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

type outofbounds = !void;

fn quadrant(p: point, x: u8, y: u8) (size | outofbounds) = {
    const half_x = x / 2;
    const half_y = y / 2;

    if (p.x == half_x || p.y == half_y) {
        return outofbounds;
    };
    let shift_x = 0z;
    if (p.x > half_x) {
        shift_x = 1z;
    };

    let shift_y = 0z;
    if (p.y > half_y) {
        shift_y = 1z;
    };

    return shift_x + 2z * shift_y;
};

@test fn quadrant() void = {
    assert(quadrant(point{ x = 1, y = 2}, 3, 3) is outofbounds);
    assert(quadrant(point{ x = 2, y = 2}, 3, 5) is outofbounds);

    assert(quadrant(point{ x = 0, y = 1}, 3, 5)! == 0);
    assert(quadrant(point{ x = 2, y = 1}, 3, 5)! == 1);
    assert(quadrant(point{ x = 0, y = 4}, 3, 5)! == 2);
    assert(quadrant(point{ x = 2, y = 4}, 3, 5)! == 3);
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

export fn main() void = {
    // const x : u8 = 11;
    // const y : u8 = 7;
    const x : u8 = 101;
    const y : u8 = 103;

    let counts : [4]u32 = [0...];
    for (true) {
        let linea = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };
        defer free(linea);

        let r = parse_robot(linea)!;
        const p = simulate(r, 100, x, y);
        const idx = match(quadrant(p, x, y)) {
            case let idx: size => yield idx;
            case => continue;
        };

        counts[idx] += 1;
    };

    let result : u64 = 1;

    for (let i .. counts) {
        result *= i;
    };

    fmt::println("Score is ", result)!;
};