use bufio;
use fmt;
use io;
use os;
use strconv;
use strings;

fn digits(number: u64) u8 = {
    let d :u8 = (1u : u8);
    for (number / 10u > 0) {
        number /= 10u;
        d += 1;
    };

    return d;
};

@test fn digits() void = {
    assert(digits(0u) == 1u);
    assert(digits(1u) == 1u);
    assert(digits(10u) == 2u);
    assert(digits(11u) == 2u);
    assert(digits(333u) == 3u);
};

fn arreq(l: [2]u64, r: [2]u64) bool = {
    return l[0] == r[0] && l[1] == r[1];
};

@test fn arreq() void = {
    assert(arreq([1u, 2u], [1u, 2u]));
    assert(!arreq([5u, 2u], [1u, 2u]));
    assert(!arreq([5u, 2u], [5u, 88u]));
};

fn split(number: u64) [2]u64 = {
    static let buf: [2]u64 = [0, 0];
    const d = digits(number) / 2;
    let n : u64 = 1u;
    for (let i = 0u; i < d; i += 1) {
        n *= 10u;
    };
    buf[0] = number / n;
    buf[1] = number % n;
    // fmt::printfln("For {} - {} and {}", number, buf[0], buf[1])!;
    return buf;
};

@test fn split() void = {
    assert(arreq(split(10u), [1u, 0u]));
    assert(arreq(split(98u), [9u, 8u]));
    assert(arreq(split(1000u), [10u, 0u]));
    assert(arreq(split(1928u), [19u, 28u]));
};

fn step(stones: []u64) []u64 = {
    let result: []u64 = [];
    for (const s .. stones) {
        if (s == 0) {
            append(result, 1u);
        } else if (digits(s) % 2 == 0) {
            const sp = split(s);
            append(result, sp[0]);
            append(result, sp[1]);
            // fmt::printfln("{} becomes {} and {}", s, sp[0], sp[1])!;
        } else {
            append(result, s * (2024u : u32));
            // fmt::printfln("{} becomes {}", s, s * (2024u : u32))!;
        };
    };
    return result;
};

export fn main() void = {
    let line = match(bufio::read_line(os::stdin)!) {
        case let line: []u8 => yield strings::fromutf8(line)!;
        case io::EOF => return;
    };
    defer free(line);
    const numbers = strings::split(line, " ");
    defer free(numbers);
    let stones: []u64 = alloc([], 0);
    for (const n .. numbers) {
        append(stones, strconv::stou64(n)!);
    };

    // for (const s .. stones) {
    //     fmt::printf("{} ", s)!;
    // };
    // fmt::println()!;
    // fmt::println()!;

    for (let i = 0; i < 25; i += 1) {
        const n = step(stones);
        free(stones);
        stones = n;

        // for (const s .. stones) {
        //     fmt::printf("{} ", s)!;
        // };
        // fmt::println()!;
        // fmt::println()!;
    };
    
    // for (const s .. stones) {
    //     fmt::printf("{} ", s)!;
    // };
    // fmt::println()!;

    fmt::printfln("Result is {}", len(stones))!;
};