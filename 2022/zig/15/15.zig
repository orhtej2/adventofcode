const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

const Beacon = struct {
    x : i32,
    y: i32
};

const Sensor = struct {
    x : i32,
    y : i32,
    closestBeacon : Beacon,
    fn distance(self : *const Sensor) !i32 {
        return try std.math.absInt(self.x - self.closestBeacon.x) + try std.math.absInt(self.y - self.closestBeacon.y);
    }

    fn yDistance(self : *const Sensor, y : i32) !?i32 {
        const dst = try std.math.absInt(self.y - y);
        if (dst > try self.distance())
            return null;
        
        return dst;
    }
};

test "yDistance" {
    try std.testing.expect(2 == try ((Sensor{.x = 1, .y = 1, .closestBeacon = Beacon{.x = 2, .y = -3}}).yDistance(3)));
    try std.testing.expect(null == try ((Sensor{.x = 1, .y = 1, .closestBeacon = Beacon{.x = 2, .y = -3}}).yDistance(10)));
}

test "distance" {
    try std.testing.expect(5 == try ((Sensor{.x = 1, .y = 1, .closestBeacon = Beacon{.x = 2, .y = -3}}).distance()));
}

test "excluded" {
    var s : Sensor = .{
        .x = 8,
        .y = 7,
        .closestBeacon = .{
            .x = 2,
            .y = 10
        }
    };

    const s1 = try s.yDistance(6);
    try std.testing.expect(s1 != null);

    const area = try s.distance() - s1.?;
    print("{d} {d}\n", .{area, s1.?});

    print("{d} {d}\n", .{s.x - area, s.x + area});

    try std.testing.expect(0 == s.x + area);
    try std.testing.expect(16 == s.x + area);
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();
    var max : i32 = 4000000 + 1;

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var buf: [10000]u8 = undefined;

    var sensors : std.ArrayList(Sensor) = std.ArrayList(Sensor).init(allocator);
    
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            break;

        try sensors.append(try parse(ln));
    }

    // for (sensors.items) |s| {
    //     print("{}\n", .{s});
    // }

    var known : [] bool = try allocator.alloc(bool, @intCast(usize, max));

    var search : i32 = 0;
    var found : bool = false;
    while (search < max and !found)
    {
        std.mem.set(bool, known, false);
        for (sensors.items) |s| {
            if (try s.yDistance(search)) |dst|
            {
                const area = try s.distance() - dst;
                var x : usize = @intCast(usize, @max(0, s.x - area));
                const limit : usize = @intCast(usize, @min(max, s.x + area));
                while (x < limit)
                {
                    known[x] = true;
                    x += 1;
                }
            }
        }

        for (known)|k|
        {
            if (!k)
            {
                found = true;
                break;
            }
        }
        search += 1;

        if (@mod(search, 100) == 0)
        {
            print("{d}\n", .{search});
        }
    }
    
    var x : usize = 0;
    while (x <= max)
    {
        if (!known[x])
        {
            print("{d} {d} {d}\n", .{x, search, x * 4000000 + @intCast(usize, search)});
        }
        x += 1;
    }
}

fn parse(line : [] const u8) !Sensor {
    const p1 = std.mem.indexOfScalar(u8, line, '=').?;
    const p2 = std.mem.indexOfScalarPos(u8, line, p1, ',').?;
    const p3 = std.mem.indexOfScalarPos(u8, line, p2, '=').?;
    const p4 = std.mem.indexOfScalarPos(u8, line, p3, ':').?;
    const p5 = std.mem.indexOfScalarPos(u8, line, p4, '=').?;
    const p6 = std.mem.indexOfScalarPos(u8, line, p5, ',').?;
    const p7 = std.mem.indexOfScalarPos(u8, line, p6, '=').?;

    return Sensor {
        .x = try std.fmt.parseInt(i32, line[p1+1..p2], 10),
        .y = try std.fmt.parseInt(i32, line[p3+1..p4], 10),
        .closestBeacon = Beacon {
            .x = try std.fmt.parseInt(i32, line[p5+1..p6], 10),
            .y = try std.fmt.parseInt(i32, line[p7+1..], 10),
        }
    };
}

test "parse" {
    try std.testing.expectEqual(
        Sensor {
            .x = 2,
            .y = 18,
            .closestBeacon = Beacon {
                .x = -2,
                .y = 15,
            }
        },
        try parse("Sensor at x=2, y=18: closest beacon is at x=-2, y=15")
    );
}
