const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

const Coords = struct {
    x : usize,
    y : usize
};

const What = enum {
    Stone,
    Sand
};

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var buf: [10000]u8 = undefined;

    var known : std.AutoHashMap(Coords, What) = std.AutoHashMap(Coords, What).init(allocator);
    
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            break;

        try drawLines(&known, ln);
    }
    const depth = computeDepth(&known) + 2;
    try addHorizontalSegment(&known, 300, 720, depth);
    // draw(&known, depth);
    var result : u32 = 0;
    while(try dropSand(&known, Coords {.x = 500, .y = 0}, depth)) {
        // draw(&known, depth);
        result += 1;
    }
    draw(&known, depth);
    print("\n{d}\n", .{result});
}

fn dropSand(known : *std.AutoHashMap(Coords, What), start : Coords, depth : usize) !bool {
    if (known.contains(start))
    {
        print("{s}\n", .{"A"});
        return false;
    }
    
    var current = start;
    while (current.y <= depth) {
        var attempt = Coords { .x = current.x, .y = current.y + 1 };
        if (known.contains(attempt)) {
            attempt.x -= 1;
            if (known.contains(attempt)) {
                attempt.x += 2;
                if (known.contains(attempt))
                {
                    try known.put(current, What.Sand);
                    return true;
                }
            }
        }
        current = attempt;
    }

    // print("{d}, {}\n", .{depth, current});
    return false;
}

fn computeDepth(known : *std.AutoHashMap(Coords, What)) usize {
    var iter = known.keyIterator();
    const k1 = iter.next();
    var bottom : usize = k1.?.y;
    while (iter.next()) |k| {
        if (k.y > bottom)
        {
            bottom = k.y;
        }
    }

    return bottom;
}

fn draw(known : *std.AutoHashMap(Coords, What), bottom : usize) void {
    var iter = known.keyIterator();
    const k1 = iter.next();
    var left : usize = k1.?.x;
    var right : usize = k1.?.x;
    while (iter.next()) |k| {
        if (k.x < left)
        {
            left = k.x;
        }
        else if (k.x > right) {
            right = k.x;
        }
    }

    var y : usize = 0;
    while (y <= bottom)
    {
        var x : usize = left;
        while (x <= right)
        {
            if (known.get(Coords{.x = x, .y = y}))|w|
            {
                var c : u8 = switch (w) {
                    .Stone => '#',
                    .Sand => 'o'
                };
                print("{c}", .{c});
            }
            else
            {
                print("{c}", .{'.'});
            }
            x += 1;
        }
        y += 1;
        print("{c}", .{'\n'});
    }
    print("{c}", .{'\n'});
}

fn parse(input : [] const u8) !Coords {
    // print("{s}\n", .{input});
    const pos = std.mem.indexOfScalar(u8, input, ',').?;
    return Coords {
        .x = try std.fmt.parseInt(usize, input[0..pos],0),
        .y = try std.fmt.parseInt(usize, input[pos+1..],0)
    };
}

test "parse" {
    try std.testing.expectEqual(Coords{.x = 1, .y = 2}, try parse("1,2"));
    try std.testing.expectEqual(Coords{.x = 12, .y = 500}, try parse("12,500"));
}

fn drawLines(known : *std.AutoHashMap(Coords, What), input : [] const u8) !void {
    // print("{s}\n", .{input});
    var pos = std.mem.indexOfScalar(u8, input, ' ').?;
    var start = try parse(input[0..pos]);
    var line = input[pos+4..];
    // print("{}\n", .{start});
    while (std.mem.indexOfScalar(u8, line, ' ')) |i|
    {
        var end = try parse(line[0..i]);
        try addSegment(known, start, end);
        start = end;
        line = line[i+4..];
    }
    var end = try parse(line);
    try addSegment(known, start, end);
}

fn addSegment(known : *std.AutoHashMap(Coords, What), start : Coords, end : Coords) !void {
    if (start.x == end.x) {
        try addVerticalSegment(known, start.y, end.y, start.x);
    }
    else
    {
        try addHorizontalSegment(known, start.x, end.x, start.y);
    }
}

fn addHorizontalSegment(known : *std.AutoHashMap(Coords, What), left : usize, right : usize, y : usize) !void {
    var start = if (left < right) left else right;
    const end = if (left > right) left else right;
    while (start <= end) {
        try known.put(Coords {.x = start, .y = y}, What.Stone);
        start += 1;
    }
}

fn addVerticalSegment(known : *std.AutoHashMap(Coords, What), top : usize, bottom : usize, x : usize) !void {
    var start = if (top < bottom) top else bottom;
    const end = if (top > bottom) top else bottom;
    while (start <= end) {
        try known.put(Coords {.x = x, .y = start}, What.Stone);
        start += 1;
    }
}