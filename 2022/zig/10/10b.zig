const std = @import("std");
const fs = std.fs;
const print = @import("std").debug.print;

const Registers = struct {
    X : i32 = 1
};

test "Registers" {
    const r : Registers = .{};
    try std.testing.expect(r.X == 1);
}

const OPCode = enum {
    noop,
    addx
};

const ParseError = error {
    NoSuchOpCode
};

const OP = struct {
    opcode : OPCode,
    operand : i32
};

fn parse(line : [] const u8) !OP {
    if (line[0] == 'a') {
        return OP {
            .opcode = OPCode.addx,
            .operand = try std.fmt.parseInt(i32, line[5..], 0)
        };
    }
    else if (line[0] == 'n')
    {
        return OP {
            .opcode = OPCode.noop,
            .operand = 0
        };
    }

    return ParseError.NoSuchOpCode;
}

test "Parsing" {
    const op1 = try parse("addx 1");
    try std.testing.expect(op1.opcode == OPCode.addx);
    try std.testing.expect(op1.operand == 1);

    const op2 = try parse("addx -81");
    try std.testing.expect(op2.opcode == OPCode.addx);
    try std.testing.expect(op2.operand == -81);

    const op3 = try parse("noop");
    try std.testing.expect(op3.opcode == OPCode.noop);
}

const CPU = struct {
    registers : Registers = .{},
    clock : u32 = 0,
    fn noop(self : *CPU) void {
        self.clock += 1;
    }

    fn addx(self : *CPU, value : i32) void {
        self.registers.X += value;
        self.clock += 2;
    }

    pub fn exec(self : *CPU, line : [] const u8) !Registers {
        const op = try parse(line);

        var ret = self.registers;

        switch (op.opcode) {
            .addx => {
                    addx(self, op.operand);
                },
            .noop => noop(self),
        }
        return ret;
    }
};

test "str" {
    var reg : Registers = .{};
    reg.X = 10;
    var reg2 : Registers = reg;
    try std.testing.expect(reg.X == 10);
    try std.testing.expect(reg2.X == 10);

    reg.X = 20;
    reg2.X = 30;
    try std.testing.expect(reg.X == 20);
    try std.testing.expect(reg2.X == 30);
}

test "CPU" {
    var c1 : CPU = .{};
    try std.testing.expect(c1.registers.X == 1);
    try std.testing.expect(c1.clock == 0);

    c1.noop();
    try std.testing.expect(c1.registers.X == 1);
    try std.testing.expect(c1.clock == 1);

    c1.addx(2);
    try std.testing.expect(c1.registers.X == 3);
    try std.testing.expect(c1.clock == 3);
}

test "Programs" {
    var c1 : CPU = .{};
    _ = try c1.exec("noop");
    _ = try c1.exec("addx 3");
    const result = try c1.exec("addx -5");

    try std.testing.expect(result.X == 4);
    try std.testing.expect(c1.registers.X == -1);
    try std.testing.expect(c1.clock == 5);
}

test "20" {
    var cpu : CPU = CPU { .clock = 19 };
    const ret = try cpu.exec("addx 5");
    try std.testing.expect(ret.X == 1);

    var cpu2 : CPU = CPU { .clock = 18 };
    const ret2 = try cpu2.exec("addx 5");
    try std.testing.expect(ret2.X == 1);
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();

    var buf: [10000]u8 = undefined;

    var result : i32 = 0;
    var next : i32 = 0;

    var cpu : CPU = .{};

    var pos : u32 = 0;
    while (try in_stream.readUntilDelimiterOrEof(&buf, '\n')) |line|
    {
        var ln : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln = line[0..line.len-1];

        if (ln.len == 0)
            break;

        const r = try cpu.exec(ln);
        while (next < cpu.clock) {
            const c : u8 = if (r.X == pos or r.X - 1 == pos or r.X + 1 == pos) '#' else '.';
            print ("{c}", .{c});
            pos += 1;
            if (@mod(pos, 40) == 0) {
                pos = 0;
                print("{c}", .{'\n'});
            }
            next += 1;
        }
    }

    print ("{d}\n", .{result});
}
