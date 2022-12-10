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
    var result = Point { .x = head.x, .y = head.y };
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

const TailError = error {
    NotMoved,
    InvalidMove
};

const Diff = struct {
    dx : i32,
    dy : i32
};

fn moveTail(tail: Point, head : Point) !Point {
    const diff : Diff = Diff { .dx = head.x - tail.x, .dy = head.y - tail.y };

    var result = Point { .x = tail.x, .y = tail.y };

    //print("{}\n", .{diff});

    if(diff.dx == 0 and diff.dy == 1
    or diff.dx == 0 and diff.dy == 0
    or diff.dx == 0 and diff.dy == -1
    or diff.dx == 1 and diff.dy == 1
    or diff.dx == 1 and diff.dy == 0
    or diff.dx == 1 and diff.dy == -1
    or diff.dx == -1 and diff.dy == 1
    or diff.dx == -1 and diff.dy == 0
    or diff.dx == -1 and diff.dy == -1
    ) { return TailError.NotMoved; }

    else if (diff.dx == 2 and diff.dy == 2) { result.x +=1; result.y += 1; }
    else if (diff.dx == 2 and diff.dy == 1) { result.x +=1; result.y += 1; }
    else if (diff.dx == 2 and diff.dy == 0) { result.x += 1; }
    else if (diff.dx == 2 and diff.dy == -1) { result.x +=1; result.y -= 1; }
    else if (diff.dx == 2 and diff.dy == -2) { result.x +=1; result.y -= 1; }

    else if (diff.dx == 1 and diff.dy == 2) { result.x +=1; result.y += 1; }
    else if (diff.dx == 1 and diff.dy == -2) { result.x +=1; result.y -= 1; }

    else if (diff.dx == 0 and diff.dy == 2) { result.y += 1; }
    else if (diff.dx == 0 and diff.dy == -2) { result.y -= 1; }

    else if (diff.dx == -1 and diff.dy == 2) { result.x -=1; result.y += 1; }
    else if (diff.dx == -1 and diff.dy == -2) { result.x -=1; result.y -= 1; }

    else if (diff.dx == -2 and diff.dy == 0) { result.x -= 1; }
    else if (diff.dx == -2 and diff.dy == -1) { result.x -=1; result.y -= 1; }
    else if (diff.dx == -2 and diff.dy == -2) { result.x -=1; result.y -= 1; }
    else if (diff.dx == -2 and diff.dy == 1) { result.x -=1; result.y += 1; }
    else if (diff.dx == -2 and diff.dy == 2) { result.x -=1; result.y += 1; }

    else { return TailError.InvalidMove; }

    return result;
}

test "dontMoveTail" {
    try std.testing.expectError(TailError.NotMoved, moveTail(Point{.x=0,.y=0}, Point{.x=0,.y=0}));
    try std.testing.expectError(TailError.NotMoved, moveTail(Point{.x=0,.y=0}, Point{.x=0,.y=1}));
    try std.testing.expectError(TailError.NotMoved, moveTail(Point{.x=0,.y=0}, Point{.x=1,.y=1}));
    try std.testing.expectError(TailError.NotMoved, moveTail(Point{.x=0,.y=0}, Point{.x=1,.y=-1}));
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
    try std.testing.expectEqual(Point{.x=-1,.y=1}, try moveTail(Point{.x=0,.y=0}, Point{.x=-1,.y=2}));

    try std.testing.expectEqual(Point{.x=-1,.y=-1}, try moveTail(Point{.x=0,.y=0}, Point{.x=-1,.y=-2}));
    try std.testing.expectEqual(Point{.x=-1,.y=-1}, try moveTail(Point{.x=0,.y=0}, Point{.x=-2,.y=-1}));

    try std.testing.expectEqual(Point{.x=1,.y=-1}, try moveTail(Point{.x=0,.y=0}, Point{.x=2,.y=-1}));
    try std.testing.expectEqual(Point{.x=1,.y=-1}, try moveTail(Point{.x=0,.y=0}, Point{.x=1,.y=-2}));

    try std.testing.expectEqual(Point{.x=3,.y=3}, try moveTail(Point{.x=2,.y=2}, Point{.x=4,.y=3}));
    try std.testing.expectEqual(Point{.x=3,.y=2}, try moveTail(Point{.x=2,.y=1}, Point{.x=4,.y=2}));
    try std.testing.expectEqual(Point{.x=2,.y=2}, try moveTail(Point{.x=1,.y=1}, Point{.x=3,.y=2}));

    try std.testing.expectEqual(Point{.x=1,.y=1}, try moveTail(Point{.x=0,.y=0}, Point{.x=2,.y=2}));
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
    defer known.deinit();
    
    var buf: [10000]u8 = undefined;

    const count = 10;

    var rope : [count]Point = [_]Point{ Point{ .x = 0, .y = 0}, } ** count;
    // , Point{ .x = 0, .y = 0}, Point{ .x = 0, .y = 0},
    //     Point{ .x = 0, .y = 0}, Point{ .x = 0, .y = 0}, Point{ .x = 0, .y = 0}, Point{ .x = 0, .y = 0}, Point{ .x = 0, .y = 0}, Point{ .x = 0, .y = 0} };

    try known.put(rope[rope.len - 1], {});

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
            rope[0] = moveHead(rope[0], direction);
            var idx : u32 = 1;
            while (idx < rope.len)
            {
                if (moveTail(rope[idx], rope[idx - 1])) |moved| {
                    rope[idx] = moved;
                }
                else |err| {
                    std.debug.assert(err == TailError.NotMoved);
                    break;
                }
                idx += 1;
            }
            try known.put(rope[rope.len - 1], {});
        }
        print("{any}\n\n", .{rope});
    }

    //print ("{any}\n", .{known.keys()});
    print ("{d}\n", .{known.count()});
}
