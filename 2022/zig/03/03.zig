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

fn computeCommon(input: [] const u8, alloc : std.mem.Allocator) !u8 {
    var hashmap = std.AutoHashMap(u8, u8).init(alloc);
    defer hashmap.deinit();


    for (input[0..input.len/2]) |item| {
        //print("{c}", .{item});
        try hashmap.put(item, 0);
    }
    
    //print("\n{s}->\n", .{input});
    for (input[input.len/2..input.len]) |item| {
      //print("{c}", .{item});
      var value = hashmap.get(item);
        if (value) |_| {
      //      print ("->{c}\n",.{item});
            return item;
        }
    }

    return RucksackError.NoCommonElement;
}

test "common" {
    try std.testing.expect((try computeCommon("aa", std.testing.allocator)) == 'a');
    try std.testing.expect((try computeCommon("abaa", std.testing.allocator)) == 'a');
    try std.testing.expect((try computeCommon("baaa", std.testing.allocator)) == 'a');
    try std.testing.expect((try computeCommon("bbab", std.testing.allocator)) == 'b');
    try std.testing.expect((try computeCommon("Bbab", std.testing.allocator)) == 'b');
    try std.testing.expect((try computeCommon("BbaB", std.testing.allocator)) == 'B');
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

    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        result += try computePriority(try computeCommon(ln, allocator));
    }

    print("{d}", .{result});
}
