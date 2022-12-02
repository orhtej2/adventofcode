const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

fn computeCounter(enemy: i32, strategy: i32) i32 {
    if (strategy == 0)
    {
        var play : i32 = enemy - 1;
        if (play < 0)
            return 2;
        return play;
    }
    else if (strategy == 2)
    {
        var play : i32 = enemy + 1;
        return @mod(play, 3);
    }

    return enemy;
}

test "wins" {
    try std.testing.expect(1 == computeCounter(0, 2));
    try std.testing.expect(2 == computeCounter(1, 2));
    try std.testing.expect(0 == computeCounter(2, 2));
}
test "draws" {
    try std.testing.expect(0 == computeCounter(0, 1));
    try std.testing.expect(1 == computeCounter(1, 1));
    try std.testing.expect(2 == computeCounter(2, 1));
}
test "losses" {
    try std.testing.expect(2 == computeCounter(0, 0));
    try std.testing.expect(0 == computeCounter(1, 0));
    try std.testing.expect(1 == computeCounter(2, 0));
}

fn computeScore(enemy: u8, my: u8) i32 {
    const e = enemy - 'A';
    const m : i32 = my - 'X';

    const counter : i32 = computeCounter(e, m);

    //print ("{d} {d} {d}\n", .{counter + (m * 3) + 1, e, m});

    return counter + m * 3 + 1;
}

test "score win" {
    try std.testing.expect(8 == computeScore('A', 'Z'));
    try std.testing.expect(9 == computeScore('B', 'Z'));
    try std.testing.expect(7 == computeScore('C', 'Z'));
}
test "score draw" {
    try std.testing.expect(4 == computeScore('A', 'Y'));
    try std.testing.expect(5 == computeScore('B', 'Y'));
    try std.testing.expect(6 == computeScore('C', 'Y'));
}
test "score loss" {
    try std.testing.expect(3 == computeScore('A', 'X'));
    try std.testing.expect(1 == computeScore('B', 'X'));
    try std.testing.expect(2 == computeScore('C', 'X'));
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [10]u8 = undefined;
    var result : i32 = 0;
    
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];
        result += computeScore(ln[0], ln[2]);
    }

    print("{d}", .{result});
}
