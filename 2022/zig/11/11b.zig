const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;
const BufferedReaderReadonlyFile = std.io.BufferedReader;

const Op = enum {
    add,
    mul
};

const NumericType = u64;

const Operation = struct {
    op : Op,
    self : bool,
    value : u32
};

const OperationError = error {
    NoSuchOperation
};

fn parseOp(line : [] const u8) !Operation {
    const op = switch (line[23]) {
        '+' => Op.add,
        '*' => Op.mul,
        else => return OperationError.NoSuchOperation
    };
    const self = line[25] == 'o';
    var value : u32 = 0;
    if (!self) {
        value = try std.fmt.parseInt(u32, line[25..], 0);
    }

    return Operation {
        .op = op,
        .self = self,
        .value = value
    };
}

test "parseOp" {
    const res1 = try parseOp("  Operation: new = old + 3");
    try std.testing.expectEqual(Op.add, res1.op);
    try std.testing.expect(!res1.self);
    try std.testing.expect(res1.value == 3);

    const res2 = try parseOp("  Operation: new = old * old");
    try std.testing.expectEqual(Op.mul, res2.op);
    try std.testing.expect(res2.self);
}

const Monkey = struct {
    items : std.ArrayList(NumericType),
    operation : Operation,
    testDenominator : u32,
    trueTarget : usize,
    falseTarget : usize,
};

fn readLine(reader : anytype, allocator : std.mem.Allocator) !?[]u8 {
    if (try reader.readUntilDelimiterOrEofAlloc(allocator, '\n', 1000)) |line|
    {
        var ln : [] u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            return null;
        
        return ln;
    }

    return null;
}

fn readItems(line : [] const u8, allocator : std.mem.Allocator) !std.ArrayList(NumericType) {
    const numbers = line[18..];
    var list = std.ArrayList(NumericType).init(allocator);
    var iterator = std.mem.split(u8, numbers, ", ");
    while (iterator.next()) |num|
    {
        try list.append(try std.fmt.parseInt(NumericType, num,0));
    }

    return list;
}

test "readItems" {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    try std.testing.expectEqualSlices(
        NumericType, 
        &[_] NumericType{96, 74, 68, 96, 56, 71, 75, 53},
        (try readItems("  Starting items: 96, 74, 68, 96, 56, 71, 75, 53", allocator)).items
    );
    
    try std.testing.expectEqualSlices(
        NumericType,
        &[_] NumericType{1},
        (try readItems("  Starting items: 1", allocator)).items
    );
}

fn readAtOffset(line : [] const u8, offset : usize) !u32 {
    return try std.fmt.parseInt(u32, line[offset..], 0);
}

fn readTest(line : [] const u8) !u32 {
    return readAtOffset(line, 21);
}

test "readTest" {
    try std.testing.expect(2 == try readTest("  Test: divisible by 2"));
    try std.testing.expect(15 == try readTest("  Test: divisible by 15"));
}

fn readMonkeyTrue(line : [] const u8) !u32 {
    return readAtOffset(line, 29);
}

fn readMonkeyFalse(line : [] const u8) !u32 {
    return readAtOffset(line, 30);
}

test "indices" {
    try std.testing.expect(4 == try readMonkeyTrue("    If true: throw to monkey 4"));
    try std.testing.expect(1 == try readMonkeyFalse("    If false: throw to monkey 1"));
}

fn readMonkey(reader : anytype, allocator : std.mem.Allocator) !?Monkey {
    var buf: [10000]u8 = undefined;
    if (try reader.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        // discard 'Monkey x' line
        _ = line;
    }
    else
    {
        return null;
    }

    var list : std.ArrayList(NumericType) = undefined;
    if (try readLine(reader, allocator)) |line|
    {
        list = try readItems(line, allocator);
    }
    else
    {
        return null;
    }

    var operation : Operation = undefined;
    if (try readLine(reader, allocator)) |line|
    {
        operation = try parseOp(line);
    }
    else
    {
        return null;
    }

    var testDenominator : u32 = undefined;
    if (try readLine(reader, allocator)) |line|
    {
        testDenominator = try readTest(line);
    }
    else
    {
        return null;
    }

    var trueIdx : u32 = undefined;
    if (try readLine(reader, allocator)) |line|
    {
        trueIdx = try readMonkeyTrue(line);
    }
    else
    {
        return null;
    }
    
    var falseIdx : u32 = undefined;
    if (try readLine(reader, allocator)) |line|
    {
        falseIdx = try readMonkeyFalse(line);
    }
    else
    {
        return null;
    }

    // discard empty line
    _ = reader.readUntilDelimiterOrEof(&buf, '\n') catch "";

    return Monkey {
        .items = list,
        .operation = operation,
        .testDenominator = testDenominator,
        .trueTarget = trueIdx,
        .falseTarget = falseIdx,
    };
}

pub fn shitMod(a : NumericType, b : u32) bool {
    var n : NumericType = a;
    while (n > b) { n -= b; }
    return n == 0;
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var monkeys = std.ArrayList(Monkey).init(allocator);

    while (try readMonkey(in_stream, allocator)) |monkey|
    {
        try monkeys.append(monkey);
    }

    var counter : u32 = 0;
    var activity : [] usize = try allocator.alloc(usize, monkeys.items.len);
    std.mem.set(usize, activity, 0);
    
    var modulus : u32 = 1;
    for (monkeys.items) |monkey| { modulus *= monkey.testDenominator; }

    while (counter < 10000)
    {
        for (monkeys.items) |monkey, idx|
        {
            for (monkey.items.items) |old|
            {
                const other : NumericType = if (monkey.operation.self) old else monkey.operation.value;
                const new : NumericType = @mod(switch (monkey.operation.op) {
                    .add => old + other,
                    .mul => old * other
                }, modulus);

                
                if (@mod(new, monkey.testDenominator) == 0)
                {
                    try monkeys.items[monkey.trueTarget].items.append(new);
                }
                else
                {
                    try monkeys.items[monkey.falseTarget].items.append(new);
                }
            }
            activity[idx] += monkey.items.items.len;
            monkeys.items[idx].items.clearRetainingCapacity();
        }
        // print ("\nIteration {d}\n", .{counter});
        // for (monkeys.items) |monkey, idx| {
        //     print("[{d}]:{any}\n", .{idx, monkey.items.items});
        // }

        counter += 1;
    }

    std.sort.sort(usize, activity, {}, std.sort.desc(usize));

    print("\n{any}\n{d}", .{activity, activity[0] * activity[1]});

     //while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line| {}
    // {
    //     var ln : []const u8 = line;
    //     if (line.len != 0 and line[line.len - 1] == 13)
    //         ln = line[0..line.len-1];

    //     if (ln.len == 0)
    //         break;

       
    // }
}
