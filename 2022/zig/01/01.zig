const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var result : u32 = 0;
    var current : u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];
        if (ln.len == 0)
        {
            print("{d}\n", .{current});
            if (current > result)
                result = current;
            current = 0;
        }
        else
        {
            print("{d}\n", .{ln});
            current += try std.fmt.parseInt(u32, ln, 0);
        }
    }

    print("{d}\n", .{current});
            if (current > result)
                result = current;

    print("{s}", .{"\n"});

    print("{d}", .{result});
}
}