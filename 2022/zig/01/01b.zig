const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

const size : usize = 3;

fn push(arr: [size]u32, val: u32) [size]u32 {
    print("{d}\n", .{arr});
    var ret : [size]u32 = arr;

    var idx : usize = 0;

    while (idx < arr.len)
    {
        if (val > arr[idx])
            break;
        idx = idx + 1;
    }

    print("idx: {d}\n", .{idx});

    if (idx != arr.len)
    {
        var idx2 = arr.len - 2;

        while (idx2 >= idx)
        {
            print("swapping {}@{} and {}@{}\n", .{ret[idx2+1], idx2+1, ret[idx2], idx2});
            ret[idx2+1] = ret[idx2];
            if (idx2 == 0)
                break;
            idx2 = idx2 - 1;
        }

        ret[idx] = val;
    }

    print("{d}\n", .{ret});
    return ret;
}

test "Check push" {
    try std.testing.expectEqual([_]u32{3, 2, 1}, push([_]u32{2, 1, 0}, 3));
    try std.testing.expectEqual([_]u32{3, 2, 1}, push([_]u32{3, 1, 0}, 2));
    try std.testing.expectEqual([_]u32{3, 2, 1}, push([_]u32{3, 2, 0}, 1));
    try std.testing.expectEqual([_]u32{7, 3, 2}, push([_]u32{7, 3, 2}, 1));
}

pub fn main() !void {

    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [1024]u8 = undefined;
    var result : [size]u32 = [_]u32{ 0 } ** size;
    var current : u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];
        if (ln.len == 0)
        {
            //print("{d}\n", .{current});
            result = push(result, current);
            current = 0;
        }
        else
        {
            print("{d}\n", .{ln});
            current += try std.fmt.parseInt(u32, ln, 0);
        }
    }

    print("{d}\n", .{current});

    result = push(result, current);

    print("{s}", .{"\n"});

    var number : u32 = 0;
    for (result) |elf| number = number + elf;

    print("{d}\n{d}", .{result,number});
}