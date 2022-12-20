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

const Range  = struct {
    start : i32,
    end : i32,
    pub fn rangeUnion(self : *const Range, other : Range) ?Range {
        if (self.intersects(other)) {
            return make(std.math.min(self.start, other.start), std.math.max(self.end, other.end));
        }

        return null;
    }
    pub fn intersects(self : *const Range, other : Range) bool {
        return self.start <= other.end and other.start <= self.end;
    }
    pub fn make(a : i32, b : i32) Range {
        return Range { .start = std.math.min(a, b), .end = std.math.max(a,b ) };
    }
    pub fn lower(self : *const Range, other : Range) bool {
        return self.end < other.start;
    }
};

test "range.intersects" {
    try std.testing.expect(Range.make(10, 20).intersects(Range.make(10,11)));
    try std.testing.expect(Range.make(0, 20).intersects(Range.make(10,11)));
    try std.testing.expect(Range.make(10, 20).intersects(Range.make(20,21)));
    try std.testing.expect(Range.make(10, 20).intersects(Range.make(9,11)));

    try std.testing.expect(!Range.make(10, 20).intersects(Range.make(8,9)));
    try std.testing.expect(!Range.make(10, 20).intersects(Range.make(80,90)));
}

test "range.lower" {
    try std.testing.expect(Range.make(10, 20).lower(Range.make(21,22)));
    try std.testing.expect(!Range.make(10, 20).lower(Range.make(19,21)));
}

test "range.union" {
    try std.testing.expectEqual(Range.make(10, 20), Range.make(10, 20).rangeUnion(Range.make(15,17)).?);
    try std.testing.expectEqual(Range.make(10, 20), Range.make(10, 15).rangeUnion(Range.make(14,20)).?);
}

const RangeSet = struct {
    allocator : std.mem.Allocator,
    ranges : std.ArrayList(Range),
    const Self = @This();
    pub fn init(allocator : std.mem.Allocator) Self {
        return .{
            .allocator = allocator,
            .ranges = std.ArrayList(Range).init(allocator)
        };
    }

    pub fn append(self : *RangeSet, range : Range) !void {
        if (self.ranges.items.len == 0)
        {
            try self.ranges.append(range);
            return;
        }
        var idx : usize = 0;
        while (idx < self.ranges.items.len)
        {
            if (range.lower(self.ranges.items[idx])) {
                if (range.end == self.ranges.items[idx].start - 1) {
                    self.ranges.items[idx].start = range.start;
                    try mergeAhead(self, idx);
                }
                else {
                    try self.ranges.insert(idx, range);
                }
                return;
            }
            else if (range.rangeUnion(self.ranges.items[idx])) |r| {
                self.ranges.items[idx] = r;
                try mergeAhead(self, idx);
                return;
            }
            else if (self.ranges.items[idx].end == range.start - 1) {
                self.ranges.items[idx].end = range.end;
                try mergeAhead(self, idx);

                return;
            }

            idx += 1;
        }
        try self.ranges.append(range);
    }

    fn mergeAhead(self : *RangeSet, idx: usize) !void {
        const pos = idx;
        const limit = idx + 1;
        while (limit < self.ranges.items.len) {
            if (self.ranges.items[pos].rangeUnion(self.ranges.items[limit])) |r2| {
                self.ranges.items[pos] = r2;
                _ = self.ranges.orderedRemove(limit);
            }
            else if (self.ranges.items[pos].end == self.ranges.items[limit].start - 1) {
                self.ranges.items[pos].end = self.ranges.items[limit].end;
            }
            else
            {
                break;
            }
        }
    }
};

fn runCase(input : [] const Range, expected : [] const Range) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var set : RangeSet = RangeSet.init(allocator);

    for (input) |r| {
        try set.append(r);
        print("{}\n{any}\n", .{r, set.ranges.items});
    }

    print("\nexpected:{any}\nactual: {any}\n\n", .{expected, set.ranges.items});
    try std.testing.expectEqualSlices(Range, expected, set.ranges.items);
}

test "rangeSet" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    var set : RangeSet = RangeSet.init(allocator);

    try set.append(Range.make(10, 20));

    try std.testing.expectEqualSlices(
        Range, 
        &[_]Range{Range.make(10, 20)}, 
        set.ranges.items
    );

    try set.append(Range.make(12, 15));

    try std.testing.expectEqualSlices(
        Range, 
        &[_]Range{Range.make(10, 20)}, 
        set.ranges.items
    );

    try set.append(Range.make(22, 25));

    try std.testing.expectEqualSlices(
        Range, 
        &[_]Range{Range.make(10, 20), Range.make(22, 25)}, 
        set.ranges.items
    );

    try set.append(Range.make(19, 25));

    try std.testing.expectEqualSlices(
        Range, 
        &[_]Range{Range.make(10, 25)}, 
        set.ranges.items
    );

    try set.append(Range.make(5, 6));

    try std.testing.expectEqualSlices(
        Range, 
        &[_]Range{Range.make(5, 6), Range.make(10, 25)}, 
        set.ranges.items
    );

    try set.append(Range.make(8, 8));

    try std.testing.expectEqualSlices(
        Range, 
        &[_]Range{Range.make(5, 6), Range.make(8, 8), Range.make(10, 25)}, 
        set.ranges.items
    );
}

test "parametrized rangeSet" {
    try runCase(
        &[_]Range{Range.make(1, 1), Range.make(2, 2)},
        &[_]Range{Range.make(1,2)}
    );

    try runCase(
        &[_]Range{Range.make(2, 2), Range.make(1, 1)},
        &[_]Range{Range.make(1,2)}
    );

    try runCase(
        &[_]Range{Range.make(1, 2), Range.make(1, 1)},
        &[_]Range{Range.make(1,2)}
    );

    try runCase(
        &[_]Range{Range.make(1, 2), Range.make(3, 4)},
        &[_]Range{Range.make(1,4)}
    );

    try runCase(
        &[_]Range{Range.make(1, 2), Range.make(4, 5), Range.make(3, 3)},
        &[_]Range{Range.make(1,5)}
    );

    try runCase(
        &[_]Range{Range.make(266462, 312678), Range.make(1555500, 4000001), Range.make(858743, 1172421),
            Range.make(2357608, 2357608), Range.make(0, 266462), Range.make(0, 1642446), Range.make(828792, 2118056), Range.make(2370712, 4000001)},
        &[_]Range{Range.make(0,4000001)}
    );
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

    var known : RangeSet = RangeSet.init(allocator);

    var last : std.ArrayList(Range) = std.ArrayList(Range).init(allocator);
    var search : i32 = 0;
    var found : bool = false;
    while (search < max and !found)
    {
        known.ranges.clearRetainingCapacity();
        last.clearRetainingCapacity();
        for (sensors.items) |s| {
            if (try s.yDistance(search)) |dst|
            {
                const area = try s.distance() - dst;
                const start : i32 = @max(0, s.x - area);
                const end : i32 = @min(max, s.x + area);
                const range = Range.make(start, end);
                try known.append(range);
                try last.append(range);
            }
        }

        if (known.ranges.items.len != 1
            or (known.ranges.items.len == 1 and (known.ranges.items[0].start != 0 or known.ranges.items[0].end != max))) {
            break;
        }
        
        search += 1;

        // if (@mod(search, 100) == 0)
        // {
        //     print("{d}\n", .{search});
        // }
    }
    
    print("{any}\n{any}\n\n{d}\n\n", .{known.ranges.items, last.items, search});

    print("{d}\n", .{10884456000000 + @intCast(i64, search)});
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
