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

    var buf: [10000]u8 = undefined;
    //var result : u32 = 0;

    var input : std.ArrayList(std.ArrayList(u8)) = std.ArrayList(std.ArrayList(u8)).init(allocator);

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            break;
        
        var idx : usize = 0;
        while (idx < ln.len)
        {
            if (input.items.len < (idx / 4) + 1)
                try input.append(std.ArrayList(u8).init(allocator));
            if (ln[idx] == '[')
            {
                try input.items[idx/4].append(ln[idx+1]);
            }

            idx += 4;
        }
    }

    for (input.items) |line| {
        print("{s}\n", .{line.items});
    }

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        const idx1 = std.mem.indexOf(u8, ln, " from").?;
        const idx2 = std.mem.indexOf(u8, ln, " to").?;

        const count = try std.fmt.parseInt(u32, ln[5..idx1], 0);
        const source = try std.fmt.parseInt(u32, ln[idx1+6..idx2], 0);
        const destination  = try std.fmt.parseInt(u32, ln[idx2+4..], 0);

        print("{d} {d} {d}\n", .{count, source, destination});

        for (input.items[source-1].items[0..count]) |item|
        {
            try input.items[destination - 1].insert(0, item);
        }
        
        try input.items[source - 1].replaceRange(0, count, "");
        for (input.items) |f| {
            print("{s}\n", .{f.items});
        }
    }

    for(input.items) |line|
    {
        print("{c}", .{line.items[0]});
    }

    print("{c}", .{'\n'});

}
