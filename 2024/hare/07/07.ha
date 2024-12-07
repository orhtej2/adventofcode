use bufio;
use fmt;
use io;
use os;
use strconv;
use strings;

export fn main() void = {
    let result : u64 = 0u;
    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };

        fmt::println(line)!;
        const s1 = strings::split(line, ":");
        defer free(s1);
        const sum = strconv::stou64(s1[0])!;
        const ing = strings::split(strings::ltrim(s1[1], ' '), " ");
        // fmt::println(len(ing))!;
        defer free(ing);
        let numbers: []u64 = [];
        defer free(numbers);
        for (const s .. ing) {
            append(numbers, strconv::stou64(s)!);
        };

        // fmt::println(len(numbers))!;
        let mask : int = ((1 << len(numbers) - 1) : int);
        mask -= 1;
        for (mask >= 0) {
            let r = numbers[0];
            fmt::print(r)!;
            for (let i = 0z; i < len(numbers) - 1; i += 1) {
                if ((mask & ((1 << i) : int)) > 0) {
                    fmt::printf("*{}", numbers[i+1])!;
                    r *= numbers[i+1];
                } else {
                    fmt::printf("+{}", numbers[i+1])!;
                    r += numbers[i+1];
                };
            };
            fmt::println()!;
            if (r == sum) {
                result += sum;
                break;
            };
            mask -= 1;
        };
     };


    fmt::printfln("Result is {}", result)!;
};