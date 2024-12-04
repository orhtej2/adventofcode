use bufio;
use fmt;
use io;
use os;
use regex;
use strconv;
use strings;

export fn main() void = {
    const re = regex::compile(`(do\(\)|don't\(\)|mul\([0-9]+,[0-9]+\))`)!;
    defer regex::finish(&re);
    const re2 = regex::compile(`([0-9]+),([0-9]+)`)!;
    defer regex::finish(&re2);

    let result = 0, resultp2 = 0;
    let enabled = true;
    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };
        const results = regex::findall(&re, line);
        defer regex::result_freeall(results);
        for (const r .. results) {
            const statement = r[0];
            if (statement.content == "do()") {
                fmt::println("do")!;
                enabled = true;
            } else if (statement.content == "don't()") {
                fmt::println("dont")!;
                enabled = false;
            } else {
                const r2 = regex::find(&re2, statement.content);
                defer regex::result_free(r2);
                const a = strconv::stoi(r2[1].content)!, b = strconv::stoi(r2[2].content)!;
                fmt::printfln("mul {} x {}", a, b)!;

                result = result + a * b;
                if (enabled) {
                    resultp2  = resultp2 + a * b;
                };
            };
        };
    };

    fmt::printfln("Result is p1: {} p2: {}", result, resultp2)!;
};