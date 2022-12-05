const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

const Range = struct {
    start: u32,
    end: u32,
};

const Pair = struct {
    a: Range,
    b: Range,
};

const FindError = error {
    NotFound
};

fn find(input: []const u8, what: u8) FindError!usize {
    for (input) |element,index| {
        if (element == what)
            return index;
    }
    
    return FindError.NotFound;
}

fn toRange(input: []const u8) !Range {
    const index = try find(input, '-');
    const left = input[0..index];
    const right = input[index+1..input.len];

    //print("r{s}: {s}-{s}\n", .{input, left, right});
    return Range {
        .start = try std.fmt.parseInt(u32, left, 0),
        .end = try std.fmt.parseInt(u32, right, 0)
    };
}

test "toRange" {
    try std.testing.expect(std.meta.eql(try toRange("1-2"), Range{.start = 1, .end = 2}));
    try std.testing.expect(std.meta.eql(try toRange("122-2111"), Range{.start = 122, .end = 2111}));
}


fn toPair(input: []const u8) !Pair {
    const index = try find(input, ',');
    const left = input[0..index];
    const right = input[index+1..input.len];

    //print("p{s}: {s} {s}\n", .{input, left, right});
    return Pair {
        .a = try toRange(left),
        .b = try toRange(right)
    };
}

test "toPair" {
    try std.testing.expect(std.meta.eql(try toPair("1-2,3-4"), Pair{.a = Range{.start = 1, .end = 2}, .b = Range {.start = 3, .end = 4}}));
}

fn contains(pair : Pair) bool {
    const result = (pair.a.start <= pair.b.start and pair.a.end >= pair.b.end) or (pair.b.start <= pair.a.start and pair.b.end >= pair.a.end);

    //print("{s}\n{}\n\n", .{if (result) "constains" else "not contains", pair});

    return result;
}

test "contains" {
    try std.testing.expect(contains(Pair{.a = Range{.start = 1, .end = 3}, .b = Range {.start = 2, .end = 2}}));
    try std.testing.expect(contains(Pair{.a = Range{.start = 1, .end = 3}, .b = Range {.start = 1, .end = 2}}));
    try std.testing.expect(contains(Pair{.a = Range{.start = 1, .end = 3}, .b = Range {.start = 2, .end = 3}}));
    try std.testing.expect(contains(Pair{.a = Range{.start = 1, .end = 3}, .b = Range {.start = 0, .end = 4}}));
}

test "not contains" {
    try std.testing.expect(!contains(Pair{.a = Range{.start = 1, .end = 3}, .b = Range {.start = 4, .end = 5}}));
    try std.testing.expect(!contains(Pair{.a = Range{.start = 2, .end = 3}, .b = Range {.start = 0, .end = 1}}));
    try std.testing.expect(!contains(Pair{.a = Range{.start = 1, .end = 3}, .b = Range {.start = 2, .end = 4}}));
    try std.testing.expect(!contains(Pair{.a = Range{.start = 1, .end = 3}, .b = Range {.start = 0, .end = 2}}));
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    
    var buf: [10000]u8 = undefined;
    var result : u32 = 0;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (contains(try toPair(ln)))
        {
            //print("{s}\n\n", .{ln});
            result += 1;
        }
    }

    print("{d}", .{result});
}
