use bufio;
use fmt;
use io;
use os;
use strings;

export fn main() void = {
    let input: [][]rune = [];
    defer free(input);
    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::torunes(strings::fromutf8(line)!);
            case io::EOF => break;
        };
        if (len(line) > 0) {
            append(input, line);
        };
    };

    let result = 0;

    const y = len(input);
    const x = len(input[0]);
    for (let i = 1z; i < y - 1; i += 1) {
        for (let j = 1z; j < x - 1; j += 1) {
            if (input[i][j] == 'A') {
                if ((input[i - 1][j - 1] == 'M' && input[i + 1][j + 1] == 'S') || (input[i - 1][j - 1] == 'S' && input[i + 1][j + 1] == 'M')) {
                    if ((input[i + 1][j - 1] == 'M' && input[i - 1][j + 1] == 'S') || (input[i + 1][j - 1] == 'S' && input[i - 1][j + 1] == 'M')) {
                        result += 1;
                    };
                };
            };
        };
    };

    fmt::printfln("Found {} matches", result)!;
};