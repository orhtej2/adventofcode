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

    for (input.items) |line| {
        print("a {s} b\n", .{line.items});
    }

    var result : u32 = @intCast(u32, input.items.len * 2 + input.items[0].items.len * 2 - 4);

    var x : usize = 1;

    while (x < input.items.len - 1) {
        var y : usize = 1;
        while (y < input.items[0].items.len - 1) {
            var visible : bool = true;
            var xInner : usize = 0;
            while (visible and xInner < x) {
                // print("[{d},{d}]{d},{d}\n", .{x, y, xInner, y});
                if (input.items[xInner].items[y] >= input.items[x].items[y])
                    visible = false;
                xInner += 1;
            }

            if (!visible)
            {
                visible = true;
                xInner = x + 1;
                while (visible and xInner < input.items.len) {
                    // print("[{d},{d}]{d},{d}\n", .{x, y, xInner, y});
                    if (input.items[xInner].items[y] >= input.items[x].items[y])
                        visible = false;
                    xInner += 1;
                }
            }

            if (!visible)
            {
                visible = true;
                var yInner : usize = y + 1;
                while (visible and yInner < input.items[0].items.len) {
                    // print("[{d},{d}]{d},{d}\n", .{x, y, x, yInner});
                    if (input.items[x].items[yInner] >= input.items[x].items[y])
                        visible = false;
                    yInner += 1;
                }
            }

            if (!visible)
            {
                visible = true;
                var yInner : usize = 0;
                while (visible and yInner < y) {
                    // print("[{d},{d}]{d},{d}\n", .{x, y, x, yInner});
                    if (input.items[x].items[yInner] >= input.items[x].items[y])
                        visible = false;
                    yInner += 1;
                }
            }
            
            if (visible)
                result += 1;

            y += 1;
        }

        x += 1;
    }

    print("{d}", .{result});
}
