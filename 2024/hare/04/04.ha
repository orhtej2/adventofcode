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

    const search = ['X','M','A','S'];
    const l = len(search);
    let result = 0;

    const y = len(input);
    for (let i = 0z; i < y; i += 1) {
        const x = len(input[i]);
        for (let j = 0z; j < x; j += 1) {
            if (j <= x - l) {
                // right
                let m = true;
                for (let z = 0z; z < l; z += 1) {
                    if (input[i][j + z] != search[z]) {
                        m = false;
                        break;
                    };
                };
                if (m) {
                    result += 1;
                };

                //right-down
                if (i <= y -l) {
                    let m = true;
                    for (let z = 0z; z < l; z += 1) {
                        if (input[i + z][j + z] != search[z]) {
                            m = false;
                            break;
                        };
                    };
                    if (m) {
                        result += 1;
                    };
                };

                //right-up
                if (i >= l - 1) {
                    let m = true;
                    for (let z = 0z; z < l; z += 1) {
                        if (input[i - z][j + z] != search[z]) {
                            m = false;
                            break;
                        };
                    };
                    if (m) {
                        result += 1;
                    };
                };
            };

            if (j >= l - 1) {
                // left
                let m = true;
                for (let z = 0z; z < l; z += 1) {
                    if (input[i][j - z] != search[z]) {
                        m = false;
                        break;
                    };
                };
                if (m) {
                    result += 1;
                };

                //left-down
                if (i <= y -l) {
                    let m = true;
                    for (let z = 0z; z < l; z += 1) {
                        if (input[i + z][j - z] != search[z]) {
                            m = false;
                            break;
                        };
                    };
                    if (m) {
                        result += 1;
                    };
                };

                //left-up
                if (i >= l - 1) {
                    let m = true;
                    for (let z = 0z; z < l; z += 1) {
                        if (input[i - z][j - z] != search[z]) {
                            m = false;
                            break;
                        };
                    };
                    if (m) {
                        result += 1;
                    };
                };
            };

            //down
            if (i <= y - l) {
                let m = true;
                for (let z = 0z; z < l; z += 1) {
                    if (input[i + z][j] != search[z]) {
                        m = false;
                        break;
                    };
                };
                if (m) {
                    result += 1;
                };
            };

            //up
            if (i >= l - 1) {
                let m = true;
                for (let z = 0z; z < l; z += 1) {
                    if (input[i - z][j] != search[z]) {
                        m = false;
                        break;
                    };
                };
                if (m) {
                    result += 1;
                };
            };
        };
    };

    fmt::printfln("Found {} matches", result)!;
};