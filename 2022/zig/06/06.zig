const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

fn checkUnique(input : []const u8) bool {
    for (input) |c, idx|
    {
        for (input[idx+1..]) |c2|
            if (c == c2)
                return false;
    }

    return true;
}

test "checkUnique - true" {
    try std.testing.expect(checkUnique("abcd"));
}

test "checkUnique - false" {
    try std.testing.expect(!checkUnique("abca"));
    try std.testing.expect(!checkUnique("aacd"));
    try std.testing.expect(!checkUnique("abad"));
    try std.testing.expect(!checkUnique("abcb"));
    try std.testing.expect(!checkUnique("abcc"));
}

const UniqueIndexError = error {
    NotFound
};

fn findUniqueIndex(input : []const u8, length : usize) !usize {
    var idx : usize = length;
    while (idx < input.len)
    {
        if (checkUnique(input[idx-length..idx]))
        {
            return idx;
        }
        idx += 1;
    }

    return UniqueIndexError.NotFound;
}

test "findUniqueIndex" {
    try std.testing.expect(try findUniqueIndex("bvwbjplbgvbhsrlpgdmjqwftvncz", 4) == 5);
    try std.testing.expect(try findUniqueIndex("nppdvjthqldpwncqszvftbrmjlhg", 4) == 6);
    try std.testing.expect(try findUniqueIndex("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 4) == 10);
    try std.testing.expect(try findUniqueIndex("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 4) == 11);

    try std.testing.expect(try findUniqueIndex("mjqjpqmgbljsphdztnvjfqwrcgsmlb", 14) == 19);
    try std.testing.expect(try findUniqueIndex("bvwbjplbgvbhsrlpgdmjqwftvncz", 14) == 23);
    try std.testing.expect(try findUniqueIndex("nppdvjthqldpwncqszvftbrmjlhg", 14) == 23);
    try std.testing.expect(try findUniqueIndex("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg", 14) == 29);
    try std.testing.expect(try findUniqueIndex("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw", 14) == 26);
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [10000]u8 = undefined;
    var line = try in_stream.readUntilDelimiterOrEof(&buf, '\n');
    var ln : []const u8 = line.?;
    if (ln.len != 0 and ln[ln.len - 1] == 13)
        ln = ln[0..ln.len-1];

    print("{d} {d}", .{try findUniqueIndex(ln, 4), try findUniqueIndex(ln, 14)});
}
