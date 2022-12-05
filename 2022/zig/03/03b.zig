const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

fn computePriority(item: u8) !u8 {
    return switch (item)
    {
        'a'...'z' => item - 'a' + 1,
        'A'...'Z' => item - 'A' + 27,
        else => return error.InvalidCharacter,
    };
}

test "a-z" {
    try std.testing.expect((try computePriority('a')) == 1);
    try std.testing.expect((try computePriority('c')) == 3);
    try std.testing.expect((try computePriority('z')) == 26);
}

test "A-Z" {
    try std.testing.expect((try computePriority('A')) == 27);
    try std.testing.expect((try computePriority('C')) == 29);
    try std.testing.expect((try computePriority('Z')) == 52);
}

const RucksackError = error {
    NoCommonElement,
};

fn computeCommon(input: [3][] const u8, alloc : std.mem.Allocator) !u8 {
    var hashmap = std.AutoHashMap(u8, u8).init(alloc);
    defer hashmap.deinit();

    for (input) |line|
    {
        var internal = std.AutoHashMap(u8, void).init(alloc);
        defer internal.deinit();
        print("{s}\n", .{line});
        for (line) |item| {
            //print("{c}", .{item});
            try internal.put(item, {});
        }
        var iterator = internal.keyIterator();
        while (iterator.next()) |item| {
            //print("{c}", .{item});
            var v = try hashmap.getOrPut(item.*);
            if (!v.found_existing) {
                // We inserted an entry, specify the new value
                // This is a conditional in case creating the new value is expensive
                v.value_ptr.* = 1;
            }
            else
            {
                v.value_ptr.* += 1;
            }
        }
    }
    
    var iter = hashmap.iterator();

    while (iter.next()) |value| {
        print("{c} {d}\n", .{value.key_ptr.*, value.value_ptr.*});
        if (value.value_ptr.* == 3)
            return value.key_ptr.*;
    }

    return RucksackError.NoCommonElement;
}

test "common" {
    try std.testing.expect((try computeCommon([_][] const u8{"abaa", "acaa", "adaa"}, std.testing.allocator)) == 'a');
    try std.testing.expect((try computeCommon([_][] const u8{"vJrwpWtwJgWrhcsFMMfFFhFp", "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL", "PmmdzqPrVvPwwTWBwg"}, std.testing.allocator)) == 'r');
    try std.testing.expect((try computeCommon([_][] const u8{"wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn", "ttgJtRGJQctTZtZT", "CrZsJsPPZsGzwwsLwLmpwMDw"}, std.testing.allocator)) == 'Z');
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
    var result : u32 = 0;
    var idx : u8 = 0;

    var input: [3][] u8 =  undefined;
    
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];
        
        input[idx] = try allocator.alloc(u8, ln.len);
        std.mem.copy(u8, input[idx][0..ln.len], ln[0..ln.len]);
        //input[idx][ln.len] = 0;
        idx += 1;
        if (idx == 3)
        {
            idx = 0;
            result += try computePriority(try computeCommon(input, allocator));
        }
    }

    print("{d}", .{result});
}
