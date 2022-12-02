const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

fn computeWinner(enemy: u32, my: u32) u32 {
    print("enemy: {}, my: {} ", .{enemy, my});
    if (enemy == my)
    {
        print("draw{s}", .{"\n"});
        return 3;
    } 
    else if ((enemy > my or (enemy == 0 and my == 2)) and !(enemy == 2 and my == 0))
    {
        print("loss{s}", .{"\n"});
        return 0;
    }
    
    print("win{s}", .{"\n"});
    return 6;
}

test "wins" {
    try std.testing.expect(6 == computeWinner(0, 1));
    try std.testing.expect(6 == computeWinner(1, 2));
    try std.testing.expect(6 == computeWinner(2, 0));
}
test "draws" {
    try std.testing.expect(3 == computeWinner(0, 0));
    try std.testing.expect(3 == computeWinner(1, 1));
    try std.testing.expect(3 == computeWinner(2, 2));
}
test "losses" {
    try std.testing.expect(0 == computeWinner(1, 0));
    try std.testing.expect(0 == computeWinner(2, 1));
    try std.testing.expect(0 == computeWinner(0, 2));
}

fn computeScore(enemy: u8, my: u8) u32 {
    const e = enemy - 'A';
    const m = my - 'X';

    return computeWinner(e, m) + m + 1;
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [10]u8 = undefined;
    var result : u32 = 0;
    
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];
        result += computeScore(ln[0], ln[2]);
    }

    print("{d}", .{result});
}
