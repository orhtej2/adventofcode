const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

const Type = enum {
    Cmd,
    File,
    Directory
};

const Command = enum {
    LS,
    CD
};

const Entry = struct {
    type : Type,
    size : u32,
    command : Command,
    back : bool,
    name : [] const u8
};

fn parse(line : [] const u8) !Entry {
    var ret : Entry = undefined;
    if (line[0] == '$')
    {
        ret.type = Type.Cmd;
        if (line [2] == 'c')
        {
            ret.command = Command.CD;
            ret.back = line[5] == '.';
            ret.name = line[5..];
        }
        else
        {
            ret.command = Command.LS;
        }
    }
    else if (line[0] - '1' < 10) {
        ret.type = Type.File;
        var space = std.mem.indexOf(u8, line, " ").?;
        ret.size = try std.fmt.parseInt(u32, line[0..space], 0);
        ret.name = line[space+1..];
    }
    else
    {
        ret.type = Type.Directory;
        ret.name = line[4..];
    }

    return ret;
}

test "directory" {
    const result = try parse("dir dr");
    try std.testing.expect(result.type == Type.Directory);
    try std.testing.expect(std.mem.eql(u8, result.name,"dr"));
}

test "file" {
    const result = try parse("123 ff");
    try std.testing.expect(result.type == Type.File);
    try std.testing.expect(result.size == 123);
    try std.testing.expect(std.mem.eql(u8, result.name,"ff"));
}

test "cd" {
    const resulta = try parse("$ cd a");
    try std.testing.expect(resulta.type == Type.Cmd);
    try std.testing.expect(resulta.command == Command.CD);
    try std.testing.expect(!resulta.back);
    try std.testing.expect(std.mem.eql(u8, resulta.name,"a"));

    const result_back = try parse("$ cd ..");
    try std.testing.expect(result_back.type == Type.Cmd);
    try std.testing.expect(result_back.command == Command.CD);
    try std.testing.expect(result_back.back);
}

test "ls" {
    const ls = try parse("$ ls");
    try std.testing.expect(ls.type == Type.Cmd);
    try std.testing.expect(ls.command == Command.LS);
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var tree : std.ArrayList(u32) = std.ArrayList(u32).init(allocator);
    defer tree.deinit();

    var path : std.ArrayList([]const u8) = std.ArrayList([]const u8).init(allocator);
    defer path.deinit();

    var directories = std.StringHashMap(u32).init(allocator);
    defer directories.deinit();

    var level : u32 = 0;
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1000)) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            break;

        const parsed = try parse(ln);
        switch (parsed.type)
        {
            .File => level += parsed.size,
            .Cmd => {
                switch (parsed.command) {
                    .CD => {
                        if (parsed.back)
                        {
                            const back = level;
                            const p = path.pop();
                            try directories.put(p, back);
                            
                            level = tree.pop() + back;
                        }
                        else
                        {
                            try tree.append(level);
                            try path.append(parsed.name);
                            level = 0;
                        }
                    },
                    .LS => {}
                }
            },
            .Directory => {}
        }
    }

    while(path.items.len != 0) {
        try directories.put(path.pop(), level);
        level += tree.pop();
    }

    const required : u32 = 30000000 - (70000000 - directories.get("/").?);
    var iterator = directories.valueIterator();

    var size : u32 = 100000000;

    while (iterator.next()) |element| {
        const value : u32 = element.*;
        if (value > required and value < size)
            size = value;
        //print("{s} {d}\n", .{element.*, element.value_ptr.*});
    }

    print ("{d}\n", .{size});
}
