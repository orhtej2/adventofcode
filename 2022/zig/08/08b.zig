const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var input : std.ArrayList(std.ArrayList(u8)) = std.ArrayList(std.ArrayList(u8)).init(allocator);
    
    var buf: [10000]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            break;

        var array = try std.ArrayList(u8).initCapacity(allocator, ln.len);
        try array.appendSlice(ln);
        try input.append(array);
    }

    // for (input.items) |line| {
    //     print("a {s} b\n", .{line.items});
    // }

    var result : usize = 0;

    var x : usize = 1;

    while (x < input.items.len - 1) {
        var y : usize = 1;
        while (y < input.items[0].items.len - 1) {
            var left : usize = 0;
            var xInner : usize = x - 1;
            while (xInner >= 0) {
                // print("[{d},{d}]{d},{d}\n", .{x, y, xInner, y});
                left += 1;
                if (input.items[xInner].items[y] >= input.items[x].items[y])
                    break;
                if (xInner == 0)
                    break;
                xInner -= 1;
            }

            var right : usize = 0;
            xInner = x + 1;
            while (xInner < input.items.len) {
                // print("[{d},{d}]{d},{d}\n", .{x, y, xInner, y});
                right += 1;
                if (input.items[xInner].items[y] >= input.items[x].items[y])
                    break;
                xInner += 1;
            }

            var top : usize = 0;
            var yInner : usize = y + 1;
            while (yInner < input.items[0].items.len) {
                // print("[{d},{d}]{d},{d}\n", .{x, y, x, yInner});
                top += 1;
                if (input.items[x].items[yInner] >= input.items[x].items[y])
                    break;
                yInner += 1;
            }

            var bottom : usize = 0;
            yInner = y - 1;
            while (yInner >= 0) {
                // print("[{d},{d}]{d},{d}\n", .{x, y, x, yInner});
                bottom += 1;
                if (input.items[x].items[yInner] >= input.items[x].items[y])
                    break;
                if (yInner == 0)
                    break;
                yInner -= 1;
            }

            const score = left * right * top * bottom;
            if (score > result)
                result = score;

            y += 1;
        }

        x += 1;
    }

    print("{d}", .{result});
}
