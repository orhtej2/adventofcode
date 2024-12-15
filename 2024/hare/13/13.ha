use bufio;
use fmt;
use io;
use math;
use os;
use regex;
use strconv;
use strings;

type button = struct {
    x: u32,
    y: u32,
    cost: u8
};

type prize = struct {
    x: u32,
    y: u32
};

type invalid = !void;

fn parse_button(line: str) (button | invalid) = {
    const b = regex::compile(`Button (A|B): X\+([0-9]+), Y\+([0-9]+)`)!;
    defer regex::finish(&b);
    const result = regex::find(&b, line);
    defer regex::result_free(result);

    if (len(result) < 4) {
        // fmt::println("Failed!")!;
        // for (const r .. result) {
        //     fmt::printfln(r.content)!;
        // };
        return invalid;
    };

    // fmt::printfln("x' {} y' {} c' {}", result[1].content, result[2].content, result[0].content)!;

    const x = match(strconv::stou32(result[2].content)) {
        case let x: u32 => yield x;
        case => return invalid;
    }, y = match(strconv::stou32(result[3].content)) {
        case let y: u32 => yield y;
        case => return invalid;
    };

    let cost: u8 = 1;
    if (result[1].content == "A") {
        cost = 3;
    };

    // fmt::printfln("x{} y{} c{}", x, y, cost)!;

    return button { x = x, y = y, cost = cost};
};

@test fn parse_button() void = {
    assert(parse_button("") is invalid);
    assert(parse_button("sadfsagassadg") is invalid);

    const b = parse_button("Button A: X+26, Y+66");
    assert (b is button);
    const b = (b : button);
    assert(b.x == 26);
    assert(b.y == 66);
    assert(b.cost == 3);

    const b = parse_button("Button B: X+21, Y+16");
    assert (b is button);
    const b = (b : button);
    assert(b.x == 21);
    assert(b.y == 16);
    assert(b.cost == 1);
};

fn parse_prize(line: str) (prize | invalid) = {
    const p = regex::compile(`Prize: X=([0-9]+), Y=([0-9]+)`)!;
    defer regex::finish(&p);

    const result = regex::find(&p, line);
    defer regex::result_free(result);

    if (len(result) < 3) {
        // fmt::println("Failed!")!;
        // for (const r .. result) {
        //     fmt::printfln(r.content)!;
        // };
        return invalid;
    };

    const x = match(strconv::stou32(result[1].content)) {
        case let x: u32 => yield x;
        case => return invalid;
    }, y = match(strconv::stou32(result[2].content)) {
        case let y: u32 => yield y;
        case => return invalid;
    };

    return prize { x = x, y = y };
};

@test fn parse_prize() void = {
    assert(parse_prize("") is invalid);
    assert(parse_prize("sadfsagassadg") is invalid);

    const b = parse_prize("Prize: X=7870, Y=6450");
    assert (b is prize);
    const b = (b : prize);
    assert(b.x == 7870);
    assert(b.y == 6450);
};

fn game_cost(a: button, b: button, p: prize) (u32 | invalid) = {
    const pushes_a = ((b.x : f64) * (p.y : f64) - (b.y : f64) * (p.x : f64)) / ((a.y : f64) * (b.x : f64) - (a.x : f64) * (b.y : f64));
    const pushes_b = ((a.y : f64) * (p.x : f64) - (a.x : f64) * (p.y : f64)) / ((a.y : f64) * (b.x : f64) - (a.x : f64) * (b.y : f64));

    if (pushes_a > (100 : f64) || pushes_b > (100 : f64) || !math::isclosef64(pushes_a, math::floorf64(pushes_a))|| !math::isclosef64(pushes_b, math::floorf64(pushes_b))) {
        return invalid;
    };

    return (pushes_a : u32) * a.cost + (pushes_b : u32) * b.cost;
};

@test fn game_cost() void = {
    // Button A: X+94, Y+34
    // Button B: X+22, Y+67
    // Prize: X=8400, Y=5400
    const r = game_cost(button { x = 94, y = 34, cost = 3}, button { x = 22, y = 67, cost = 1}, prize { x = 8400, y = 5400});
    assert( r is u32 );
    const r = (r : u32);
    assert(r == 280);

    // Button A: X+26, Y+66
    // Button B: X+67, Y+21
    // Prize: X=12748, Y=12176
    const r = game_cost(button { x = 26, y = 66, cost = 3}, button { x = 67, y = 21, cost = 1}, prize { x = 12748, y = 12176});
    assert( r is invalid );
    
};

export fn main() void = {
    let cost = 0u;
    let prizes = 0u;
    for (true) {
        let linea = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };
        // fmt::printfln(linea)!;
        defer free(linea);

        let a = parse_button(linea)!;
        
        let lineb = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };
        // fmt::printfln(lineb)!;
        defer free(lineb);

        let b = parse_button(lineb)!;

        let linep = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };
        // fmt::printfln(linep)!;
        defer free(linep);

        let p = parse_prize(linep)!;

        let ignore = bufio::read_line(os::stdin)!;
        if (ignore is []u8) {
            free(ignore : []u8);
        };

        cost += match(game_cost(a, b, p)) {
            case let c: u32 => yield c;
            case invalid => continue;
        };
        prizes += 1;
    };
    
    fmt::printfln("Total prizes is {}, cost {}", prizes, cost)!;
};