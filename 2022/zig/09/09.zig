const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;
const AutoHashMap = std.AutoArrayHashMap;

const Point = struct {
    x : i32,
    y : i32
};

const DirectionError = error {
    NoSuchDirection
};

const Direction = enum {
    up,
    down,
    left,
    right
};

fn toDirection(direction : u8) !Direction {
    return switch (direction) {
        'U' => Direction.up,
        'D' => Direction.down,
        'L' => Direction.left,
        'R' => Direction.right,
        else => DirectionError.NoSuchDirection
    };
}

test "toDirection" {
    try std.testing.expect(Direction.up == try toDirection('U'));
    try std.testing.expect(Direction.down == try toDirection('D'));
    try std.testing.expect(Direction.left == try toDirection('L'));
    try std.testing.expect(Direction.right == try toDirection('R'));
}

fn moveHead(head : Point, direction : Direction) Point {
    var result = head;
    switch(direction) {
        Direction.up => result.y += 1,
        Direction.down => result.y -= 1,
        Direction.left => result.x -= 1,
        Direction.right => result.x += 1,
    }

    return result;
}

test "moveHead" {
    try std.testing.expectEqual(Point { .x = 0, .y = 1 }, moveHead(Point{ .x = 0, .y = 0 }, Direction.up));
    try std.testing.expectEqual(Point { .x = 0, .y = -1 }, moveHead(Point{ .x = 0, .y = 0 }, Direction.down));
    try std.testing.expectEqual(Point { .x = 1, .y = 0 }, moveHead(Point{ .x = 0, .y = 0 }, Direction.right));
    try std.testing.expectEqual(Point { .x = -1, .y = 0 }, moveHead(Point{ .x = 0, .y = 0 }, Direction.left));
}

fn moveTail(tail: Point, head : Point) !Point {
    const diff_x : i32 = head.x - tail.x;
    const diff_y : i32 = head.y - tail.y;

    var result = tail;
    if ((try std.math.absInt(diff_x)) > 1)
    {
        //print ("{d}:{d} -> {d}:{d}, {d} {d}\n", .{head.x, head.y, tail.x, tail.y, diff_x, diff_y});
        result.x += diff_x - @divExact(diff_x,  try std.math.absInt(diff_x));
        result.y += diff_y;
    }
    
    if((try std.math.absInt(diff_y)) > 1)
    {
        //print ("{d}:{d} -> {d}:{d}, {d} {d}\n", .{head.x, head.y, tail.x, tail.y, diff_x, diff_y});
        result.x += diff_x;
        result.y += diff_y - @divExact(diff_y,  try std.math.absInt(diff_y));
    }

    return result;
}

test "dontMoveTail" {
    try std.testing.expectEqual(Point{.x=0,.y=0}, try moveTail(Point{.x=0,.y=0}, Point{.x=0,.y=0}));
    try std.testing.expectEqual(Point{.x=0,.y=0}, try moveTail(Point{.x=0,.y=0}, Point{.x=0,.y=1}));
    try std.testing.expectEqual(Point{.x=0,.y=0}, try moveTail(Point{.x=0,.y=0}, Point{.x=1,.y=1}));
    try std.testing.expectEqual(Point{.x=0,.y=0}, try moveTail(Point{.x=0,.y=0}, Point{.x=1,.y=-1}));
}

test "straightMoveTail" {
    try std.testing.expectEqual(Point{.x=1,.y=0}, try moveTail(Point{.x=0,.y=0}, Point{.x=2,.y=0}));
    try std.testing.expectEqual(Point{.x=-1,.y=0}, try moveTail(Point{.x=0,.y=0}, Point{.x=-2,.y=0}));

    try std.testing.expectEqual(Point{.x=0,.y=1}, try moveTail(Point{.x=0,.y=0}, Point{.x=0,.y=2}));
    try std.testing.expectEqual(Point{.x=0,.y=-1}, try moveTail(Point{.x=0,.y=0}, Point{.x=0,.y=-2}));
}

test "moveDiagonal" {
    try std.testing.expectEqual(Point{.x=1,.y=1}, try moveTail(Point{.x=0,.y=0}, Point{.x=2,.y=1}));
    try std.testing.expectEqual(Point{.x=1,.y=1}, try moveTail(Point{.x=0,.y=0}, Point{.x=1,.y=2}));
    try std.testing.expectEqual(Point{.x=-1,.y=1}, try moveTail(Point{.x=0,.y=0}, Point{.x=-2,.y=1}));
    try std.testing.expectEqual(Point{.x=-1,.y=-1}, try moveTail(Point{.x=0,.y=0}, Point{.x=-1,.y=-2}));
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var known : AutoHashMap(Point, void) = AutoHashMap(Point, void).init(allocator);
    
    var buf: [10000]u8 = undefined;

    var head : Point = Point{ .x = 0, .y = 0};
    var tail : Point = Point{ .x = 0, .y = 0};

    try known.put(tail, {});

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            break;

        const direction = try toDirection(ln[0]);
        const times = try std.fmt.parseInt(u32, ln[2..], 0);
        var counter : u32 = 0;
        while (counter < times) {
            counter += 1;
            head = moveHead(head, direction);
            tail = try moveTail(tail, head);
            try known.put(tail, {});
        }
    }

    print ("{d}", .{known.count()});
}
