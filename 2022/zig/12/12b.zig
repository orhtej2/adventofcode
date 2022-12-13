const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

const Coords = struct {
    x : usize,
    y : usize
};

const Result = struct {
    coords : Coords,
    found : bool
};

fn check(map: * const std.ArrayList(std.ArrayList(u8)), path : [][]u32, coord : Coords, next : u32, dx : i32, dy : i32) ?Result {
    const x : usize = @intCast(usize, @intCast(i32, coord.x + 1) + dx);
    const y : usize = @intCast(usize, @intCast(i32, coord.y + 1) + dy);
    if (path[y][x] > next
        and map.items[y - 1].items[x - 1] + 1 >= map.items[coord.y].items[coord.x]) {
        path[y][x] = next;
        return .{ .found = map.items[y - 1].items[x - 1] == 0, .coords = .{.x = x - 1, .y = y - 1 } };
    }
    return null;
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var buf: [10000]u8 = undefined;

    var map : std.ArrayList(std.ArrayList(u8)) = std.ArrayList(std.ArrayList(u8)).init(allocator);
    var queue : std.ArrayList(Coords) = std.ArrayList(Coords).init(allocator);
    var target : Coords = .{ .x = 10000000, .y = 10000000 };
    var y : usize = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            break;

        var lnArr : std.ArrayList(u8) = try std.ArrayList(u8).initCapacity(allocator, ln.len);
        for (ln) |ch, idx| {
            switch (ch)
            {
                'S' => {
                    //try queue.append(.{.x = idx, .y = y});
                    try lnArr.append(0);
                },
                'E' => {
                    try queue.append(.{.x = idx, .y = y});
                    target = .{.x = idx, .y = y};
                    try lnArr.append('z' - 'a');
                },
                else => try lnArr.append(ch - 'a')
            }
        }

        try map.append(lnArr);

        y += 1;
    }

    var path : [][] u32 = try allocator.alloc([]u32, map.items.len + 2);
    y = 0;
    while (y < path.len) {
        var x : usize = 0;
        path[y] = try allocator.alloc(u32, map.items[0].items.len + 2);
        while (x < path[y].len) {
            if (y == 0 or y == path.len - 1 or x == 0 or x == path[y].len - 1)
            {
                path[y][x] = 0;
            }
            else
            {
                path[y][x] = 9999;
            }
            x += 1;
        }
        y += 1;
    }

    const start = queue.items[0];
    path[start.y + 1][start.x + 1] = 0;

    // for (map.items) |row, idx|
    // {
    //     print("[{d}] : {any}\n", .{idx, row.items});
    // }

    print("{}\n{}\n\n\n\n", .{queue, target});

    while (queue.items.len > 0)
    {
        const coord = queue.orderedRemove(0);
        const next = path[coord.y + 1][coord.x + 1] + 1;
        
        if (check(&map, path, coord, next, -1, 0)) |new| // left
        {
            if (new.found) {
                print("{d}\n", .{path[new.coords.y + 1][new.coords.x + 1]});
                return;
            }
                
            try queue.append(new.coords); 
        } 
        if (check(&map, path, coord, next, 1, 0)) |new| { // right
            if (new.found) {
                print("{d}\n", .{path[new.coords.y + 1][new.coords.x + 1]});
                return;
            }
                
            try queue.append(new.coords); 
        }
        if (check(&map, path, coord, next, 0, -1)) |new| { // up
            if (new.found) {
                print("{d}\n", .{path[new.coords.y + 1][new.coords.x + 1]});
                return;
            }
                
            try queue.append(new.coords); 
        }
        if (check(&map, path, coord, next, 0, 1)) |new| { // down
            if (new.found) {
                print("{d}\n", .{path[new.coords.y + 1][new.coords.x + 1]});
                return;
            }
                
            try queue.append(new.coords); 
        }
    }

    unreachable;
}
