use fmt;
use fs;
use io;
use os;
use sort;
use sort::cmp;
use strconv;
use strings;

export fn main() void = {
    if (len(os::args) != 2) {
        fmt::fatalf("Usage: {} <input>", os::args[0]);
    };

    const path = os::args[1];
    const file = match (os::open(path)) {
    case let file: io::file =>
        yield file;
    case let err: fs::error =>
        fmt::fatalf("Error opening {}: {}",
            path, fs::strerror(err));
    };
    defer io::close(file)!;
    
    const input = io::drain(file)!;
    const input = strings::fromutf8(input)!;
    const input = strings::split(input, "\n");
    defer free(input);

    const length = len(input);
    let left: []int = [], right: []int = [];
    defer free(left);
    defer free(right);

    for (let i = 0z; i < length; i += 1) {
        const split = strings::split(input[i], " ");
        defer free(split);
        append(left, strconv::stoi(split[0]) as int);
        append(right, strconv::stoi(split[len(split)-1]) as int);
    };

    sort::sort(left, size(int), &sort::cmp::ints);
    sort::sort(right, size(int), &sort::cmp::ints);

    let result = 0;
    for (let i = 0z; i < length; i += 1) {
        const intermediate = left[i] - right[i];
        if (intermediate < 0) {
            result = result - intermediate;
        } else {
            result = result + intermediate;
        };
    };

    fmt::printfln("Result is {}", result)!;
};