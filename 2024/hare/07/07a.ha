use bufio;
use fmt;
use io;
use os;
use strconv;
use strings;

fn validate(sum: u64, input: []u64, target: u64) bool = {
    // fmt::printfln("{} {} {}", sum, len(input), target)!;
    const sum1 = sum + input[0];
    if (len(input) == 1) {
        if (sum1 == target) {
            return true;
        };
    } else {
        if (validate(sum1, input[1..], target)) {
            return true;
        };
    };

    const sum1 = sum * input[0];
    if (len(input) == 1) {
        if (sum1 == target) {
            return true;
        };
    } else {
        if (validate(sum1, input[1..], target)) {
            return true;
        };
    };

    const n1 = strings::dup(strconv::u64tos(sum));
    defer free(n1);
    // fmt::println(input[0])!;
    const n2 = strings::dup(strconv::u64tos(input[0]));
    defer free(n2);
    const s = strings::concat(n1, n2);
    defer free(s);
    const sum1 = strconv::stou64(s)!;    
    if (len(input) == 1) {
        if (sum1 == target) {
            return true;
        };
    } else {
        if (validate(sum1, input[1..], target)) {
            return true;
        };
    };

    return false;
};

export fn main() void = {
    let result : u64 = 0u;
    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };

        // fmt::println(line)!;
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

        
        if (validate(numbers[0], numbers[1..], sum)) {
            result += sum;
        };
     };


    fmt::printfln("Result is {}", result)!;
};