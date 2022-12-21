const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

const Room = struct {
    name : [] u8,
    valveFlowRate : u32,
    passages : std.ArrayList([] u8),
    allocator : std.mem.Allocator,
    distances : std.StringHashMap(u32),

    pub fn init(input : [] const u8, allocator : std.mem.Allocator) !Room {
        const p1 = std.mem.indexOfScalar(u8, input, '=').?;
        const p2 = std.mem.indexOfScalar(u8, input, ';').?;
        const flowRate : u32 = try std.fmt.parseUnsigned(u32, input[p1+1..p2], 10);
        const name : [] u8 = try allocator.alloc(u8, 2);
        std.mem.copy(u8, name, input[6..8]);
        var passages : std.ArrayList([] u8) = std.ArrayList([] u8).init(allocator);
        if (std.mem.indexOf(u8, input, "valve ")) |single| {
            try passages.append(try allocator.alloc(u8, input.len - single - 6));
            std.mem.copy(u8, passages.items[0], input[single+6..]);
        }
        else {
            const start = std.mem.indexOf(u8, input, "valves ").? + 7;
            var iterator = std.mem.split(u8, input[start..], ", ");
            while (iterator.next()) |n|
            {
                try passages.append(try allocator.alloc(u8, n.len));
                std.mem.copy(u8, passages.items[passages.items.len - 1], n);
            }
        }

        var distances = std.StringHashMap(u32).init(allocator);
        try distances.put(name, 0);
        
        return .{
            .name = name,
            .valveFlowRate = flowRate,
            .passages = passages,
            .allocator = allocator,
            .distances = distances
        };
    }

    pub fn deinit(self : *Room) void {
        self.allocator.free(self.name);
        self.distances.deinit();
        for (self.passages.items) |p| {
            self.allocator.free(p);
        }
        self.passages.deinit();
    }
};

test "Room.init" {
    const a = std.testing.allocator;

    {
        var r = try Room.init("Valve HH has flow rate=22; tunnel leads to valve GG", a);
        defer r.deinit();

        try std.testing.expectEqualSlices(u8, "HH", r.name);
        try std.testing.expectEqual(r.valveFlowRate, 22);
        try std.testing.expectEqual(r.passages.items.len, 1);
        try std.testing.expectEqualSlices(u8, "GG", r.passages.items[0]);
    }

    {
        var r = try Room.init("Valve PO has flow rate=4; tunnels lead to valves GZ, TN, SA, XT, BM", a);
        defer r.deinit();

        try std.testing.expectEqualSlices(u8, "PO", r.name);
        try std.testing.expectEqual(r.valveFlowRate, 4);
        try std.testing.expectEqual(r.passages.items.len, 5);
        try std.testing.expectEqualSlices(u8, "GZ", r.passages.items[0]);
        try std.testing.expectEqualSlices(u8, "TN", r.passages.items[1]);
        try std.testing.expectEqualSlices(u8, "SA", r.passages.items[2]);
        try std.testing.expectEqualSlices(u8, "XT", r.passages.items[3]);
        try std.testing.expectEqualSlices(u8, "BM", r.passages.items[4]);
    }
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var map : std.StringHashMap(Room) = std.StringHashMap(Room).init(allocator);
    defer map.deinit();

    var destinations : std.ArrayList([] const u8) = std.ArrayList([] const u8).init(allocator);
    defer destinations.deinit();

    var buf: [10000]u8 = undefined;

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            break;

        const room = try Room.init(ln, allocator);
        try map.put(room.name, room);
        if (room.valveFlowRate != 0) {
            try destinations.append(room.name);
        }
    }

    // dump(map);

    try computeDistances(map);

    // dumpDistances(map, "AA");

    //print("{d}\n", .{computeScore(map, &[_][] const u8 {"DD", "BB", "JJ", "HH", "EE", "CC"})});
    
    std.sort.sort([] const u8, destinations.items, {}, compare);
    // dumpOrder(destinations.items);

    const max : u32 = findMax(map, destinations.items, allocator);

    print("{d}", .{max});
}

fn findMax(map : std.StringHashMap(Room), order : [][]const u8, allocator : std.mem.Allocator) u32 {
    var max : u32 = 0;
    var cp = std.ArrayList([] const u8).init(allocator);
    defer cp.deinit();
    while (next_permutation(order)) {
        //dumpOrder(destinations.items);
        const score_a = computeScore(&map, order);
            
        var limit = computeTimeLimit(map, order);
        //cp.clearRetainingCapacity();
        cp.resize(order.len - limit - 1) catch unreachable;
        // print("{d} {d} {d}", .{order.len, limit, order.len - limit});
        std.mem.copy([] const u8, cp.items, order[limit+1..]);
        std.sort.sort([] const u8, cp.items, {}, compare);
        const score_b = findMaxNoRecursion(map, cp.items);
        if (score_a + score_b > max)
            max = score_a + score_b;
        if (limit < order.len) {
            std.sort.sort([] const u8, order[limit + 1..], {}, compareDesc);
        }
        
        // print("{d} ", .{score});
    }

    return max;
}

fn findMaxNoRecursion(map : std.StringHashMap(Room), order : [][]const u8) u32 {
    var max : u32 = 0;
    while (next_permutation(order)) {
        //dumpOrder(destinations.items);
        const score = computeScore(&map, order);
            
        var limit = computeTimeLimit(map, order);
        if (score > max)
            max = score;
        if (limit < order.len) {
            std.sort.sort([] const u8, order[limit + 1..], {}, compareDesc);
        }
        
        // print("{d} ", .{score});
    }

    return max;
}

fn computeTimeLimit(map : std.StringHashMap(Room), order : [][]const u8) usize {
    var timeLeft : u32 = 26;

    var current : []const u8 = "AA";

    for (order) |next, idx| {
        // print("{s}", .{current});
        var distance = map.get(current).?.distances.get(next).? + 1;
        if (distance >= timeLeft)
        {
            // print("\n", .{});
            return idx;
        }
        // print("[{d}] ", .{distance});
        timeLeft -= distance;
        current = next;
    }

    // print("\n", .{});

    return order.len;
}

fn dumpOrder(order : [][] const u8) void {
    var first : bool = true;
    for (order) |e| {
        if (!first) {
            print(", ", .{});
        } else {
            first = false;  
        }
        print("{s}", .{e});
    }

    print("\n", .{});
}

fn compareDesc(ctx : void, lhs : [] const u8, rhs : [] const u8) bool {
    _ = ctx;
    for (lhs) |c, idx| {
        if (c != rhs[idx])
            return c > rhs[idx];
    }

    return false;
}

fn compare(ctx : void, lhs : [] const u8, rhs : [] const u8) bool {
    _ = ctx;
    for (lhs) |c, idx| {
        if (c != rhs[idx])
            return c < rhs[idx];
    }

    return false;
}

fn dump(map : std.StringHashMap(Room)) void {
    var iter = map.valueIterator();

    while (iter.next()) |r|
    {
        print("{s}: [{d}] -> {s}", .{r.name, r.valveFlowRate, r.passages.items[0]});
        var idx : usize = 1;
        while (idx < r.passages.items.len)
        {
            print(", {s}", .{r.passages.items[idx]});
            idx += 1;
        }

        print("{c}", .{'\n'});
    }
}

fn dumpDistances(map : std.StringHashMap(Room), start : [] const u8) void {
    const room = map.get(start).?;
    print("{s}\n", .{start});
    var kvIterator = room.distances.iterator();
    while(kvIterator.next()) |kv| {
        print("-> {s} [{d}]\n", .{kv.key_ptr.*, kv.value_ptr.*});
    }
}

fn computeDistances(map : std.StringHashMap(Room)) !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var all = std.ArrayList([] const u8).init(allocator);
    var keyIterator = map.keyIterator();
    while (keyIterator.next()) |k| {
        try all.append(k.*);
    }

    // print("{any}\n", .{all});

    var changed : bool = true;
    while (changed) {
        changed = false;
        var kvIterator = map.iterator();
        while (kvIterator.next()) |entry| {
            for (all.items) |d| {
                if (!entry.value_ptr.distances.contains(d)) {
                    var candidate : ?u32 = null;
                    for (entry.value_ptr.passages.items) |p| {
                        const neighbour = map.get(p).?;
                        if (neighbour.distances.get(d)) |distance| {
                            if (candidate == null or candidate.? > distance) {
                                // print ("Looking in {s}, found {s} [{d}]\n", .{entry.value_ptr.name, neighbour.name, distance});
                                candidate = distance;
                            }
                        }
                    }
                    if (candidate) |c| {
                        try entry.value_ptr.distances.put(d, c + 1);
                        changed = true;
                    }
                }
            }
        }
    }
}

fn computeScore(map : * const std.StringHashMap(Room), order : [] const [] const u8) u32 {
    var result : u32 = 0;
    
    var currentFlow : u32 = 0;
    var timeLeft : u32 = 26;

    var current : []const u8 = "AA";

    for (order) |next| {
        const distance : u32 = map.get(current).?.distances.get(next).? + 1;
        if (distance > timeLeft) {
            break;
        }
        result += distance * currentFlow;
        currentFlow += map.get(next).?.valveFlowRate;
        timeLeft -= distance;
        current = next;
    }

    result += timeLeft * currentFlow;

    return result;
}

fn next_permutation(order: [][] const u8) bool {
    // Find non-increasing suffix
    if (order.len < 2) return false;

    var i: usize = order.len - 1;
    while (i > 0 and  compare({}, order[i], order[i - 1])) {
        i -= 1;
    }

    if (i == 0)
        return false;

    // Find successor to pivot
    var j: usize = order.len - 1;
    
    while (compare({}, order[j], order[i - 1])) {
        j -= 1;
    }

    std.mem.swap([]const u8, &order[j], &order[i - 1]);
    std.mem.reverse([] const u8, order[i..]);
    return true;
}

test "next_permutation" {
    var order = [_][] const u8 { "AA", "AB" };
    try std.testing.expect(next_permutation(&order));
    try std.testing.expectEqualSlices(u8, "AB", order[0]);
    try std.testing.expectEqualSlices(u8, "AA", order[1]);

    try std.testing.expect(!next_permutation(&order));
}