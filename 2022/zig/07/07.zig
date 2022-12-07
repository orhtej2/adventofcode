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
    back : bool
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
        }
        else
        {
            ret.command = Command.LS;
        }
    }
    else if (line[0] - '1' < 10) {
        ret.type = Type.File;
        ret.size = try std.fmt.parseInt(u32, line[0..std.mem.indexOf(u8, line, " ").?], 0);
    }
    else
    {
        ret.type = Type.Directory;
    }

    return ret;
}

test "directory" {
    try std.testing.expect((try parse("dir a")).type == Type.Directory);
}

test "file" {
    const result = try parse("123 a");
    try std.testing.expect(result.type == Type.File);
    try std.testing.expect(result.size == 123);
}

test "cd" {
    const resulta = try parse("$ cd a");
    try std.testing.expect(resulta.type == Type.Cmd);
    try std.testing.expect(resulta.command == Command.CD);
    try std.testing.expect(!resulta.back);

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

    var buf: [10000]u8 = undefined;

    var tree : std.ArrayList(u32) = std.ArrayList(u32).init(allocator);
    defer tree.deinit();

    var result : u32 = 0;
    var level : u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
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
                            if (back <= 100000)
                                result += back;
                            level = tree.pop() + back;
                        }
                        else
                        {
                            try tree.append(level);
                            level = 0;
                        }
                    },
                    .LS => {}
                }
            },
            .Directory => {}
        }
    }

    print("{d}\n", .{result});
}
