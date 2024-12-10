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

type file = struct {
    n: u8,
    b: u8
};

fn defrag(f: []u8) u64 = {
    let files: []file = [];
    defer free(files);
    for (const n .. f) {
        append(files, file { n = n, b = 0 });
    };
    let disk : []u64 = [];
    defer free(disk);

    for (let i = 0z; i < len(files); i += 1) {
        const id : u64 = switch(i %2 ) {
            case 0 => yield id(i);
            case => yield 0u;
        };
        for (let j = 0u; j < files[i].n; j += 1) {
            append(disk, id);
        };
    };

    for (const n .. disk) {
        fmt::print(n)!;
    };
    fmt::println()!;

    fmt::println("here")!;
    let rpos = len(disk) - 1;
    let end = len(files) - 1;
    let fid = id(end);
    for (end > 0) {
        if (files[end].n > 0) {
            let lpos = 0z;
            for (let start = 0z; start < end; start += 1) {
                if ((start & 1u) == 1u) {
                    if (files[start].n >= files[end].n) {
                        fmt::printfln("[{}] e {} s{} l {} f {} lp {} rp {}", fid, end, start, len(disk), files[end].n, lpos, rpos)!;
                        for (let j = 0u; j < files[end].n; j += 1) {
                            disk[lpos + files[start].b + j] = fid;
                            disk[rpos - j] = 0u;
                        };

                        files[start].n -= files[end].n;
                        files[start].b += files[end].n;
                        // insert(files[start], file{n = files[end].n, b = 0});
                        // insert(files[start], file{n = 0, b = 0});
                        rpos -= files[end].n;
                        files[end].n = 0;
                        // end += 2;
                        break;
                    };
                };
                lpos += files[start].n + files[start].b;
            };
        };
        rpos -= files[end].n + files[end - 1].n + files[end - 1].b;
        end -= 2;
        fid -= 1;
    };

    for (const n .. disk) {
        fmt::print(n)!;
    };
    fmt::println()!;
    let result : u64 = 0u;
    for (let i = 0z; i < len(disk); i += 1) {
        result += disk[i] * (i : u64);
    };
    fmt::printfln("R is {}", result)!;
    return result;
};

@test fn defrag() void = {
    assert(defrag([1]) == 0);
    assert(defrag([1, 1, 1]) == 1);
    assert(defrag([2, 3, 3, 3, 1, 3, 3, 1, 2, 1, 4, 1, 4, 1, 3, 1, 4, 0, 2]) == 2858);
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