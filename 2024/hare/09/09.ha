use bufio;
use fmt;
use io;
use os;
use strconv;
use strings;

fn id(l: size) u64 = {
    return ((l / 2u) : u64);
};

@test fn id() void = {
    assert(id(8) == 4u);
};

fn checksum(o: u64, l: u8, id: u64) u64 = {
    const partial = o * l * 2u + l * l - l;
    const partial = partial / 2u;
    const result = partial * id;
    fmt::printfln("p {} l {} id {} cccs {}", o, l, id, result)!;
    return result;
};

@test fn checksum() void = {
    assert(checksum(2, 2, 9) == 45);
    assert(checksum(2, 0, 9) == 0);
};

fn min(l: u8, r: u8) u8 = {
    if (l < r) {
        return l;
    };

    return r;
};

fn defrag(disk: []u8) u64 = {
    let start = 0z, end = len(disk) - 1;
    let pos: u64 = 0u;
    // fmt::printfln("{}, {}", start, end)!;
    let result : u64 = 0u;
    for (start <= end) {
        if (start % 2 == 0) {
            // fmt::printfln("Checking {} val {} ", start, disk[start])!;
            // for (let i=0u; i < disk[start]; i+=1) {
            //     fmt::print(id(start))!;
            // };
            result += checksum(pos, disk[start], id(start));
            pos += disk[start];
            start += 1;
        } else {
            const n = min(disk[start], disk[end]);
            // for (let i=0u; i < n; i+=1) {
            //     fmt::print(id(end))!;
            // };
            result += checksum(pos, n, id(end));
            // fmt::printfln("d[{}] {} d[{}] {} n {}", start, disk[start], end, disk[end], n)!;
            disk[start] -= n;
            disk[end] -= n;
            // fmt::printfln("d[{}] {} d[{}] {} n {}", start, disk[start], end, disk[end], n)!;
            pos += n;
            if (disk[start] == 0) {
                start += 1;
            };
            if (disk[end] == 0) {
                end -= 2;
            };
        };
    };

    fmt::println()!;
    fmt::printfln("R is {}", result)!;
    return result;
};

@test fn defrag() void = {
    assert(defrag([1]) == 0);
    assert(defrag([1, 1, 1]) == 1);
    assert(defrag([2, 3, 3, 3, 1, 3, 3, 1, 2, 1, 4, 1, 4, 1, 3, 1, 4, 0, 2]) == 1928);
};

export fn main() void = {
    let line = match(bufio::read_line(os::stdin)!) {
        case let line: []u8 => yield strings::fromutf8(line)!;
        case io::EOF => return;
    };
    defer free(line);
    let disk: []u8 = [];
    defer free(disk);

    let iter = strings::iter(line);
    for (true) {
        let r = match(strings::next(&iter)) {
            case let r: rune => yield r;
            case done => break;
        };

        const n = (((r : u32) - 48) : u8);
        append(disk, n);
        fmt::println(n)!;
    };

    const result = defrag(disk);

    fmt::printfln("Result is {}", result)!;
};