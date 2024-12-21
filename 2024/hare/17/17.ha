use bufio;
use encoding::utf8;
use fmt;
use io;
use os;
use strconv;
use strings;

type operand = fn(registers: const *[3]u64) u64;

fn op0(registers: const *[3] u64) u64 ={ return 0; };
@test fn op0() void = {
    assert(op0(&[0 : u64,0,0]) == 0);
};

fn op1(registers: const *[3] u64) u64 ={ return 1; };
@test fn op1() void = {
    assert(op1(&[0 : u64,0,0]) == 1);
};
fn op2(registers: const *[3] u64) u64 ={ return 2; };
@test fn op2() void = {
    assert(op2(&[0 : u64,0,0]) == 2);
};
fn op3(registers: const *[3] u64) u64 ={ return 3; };
@test fn op3() void = {
    assert(op3(&[0 : u64,0,0]) == 3);
};
fn op4(registers: const *[3] u64) u64 ={ return registers[0]; };
@test fn op4() void = {
    assert(op4(&[10 : u64,0,0]) == 10);
    assert(op5(&[0 : u64,0,0]) == 0);
};

fn op5(registers: const *[3] u64) u64 ={ return registers[1]; };
@test fn op5() void = {
    assert(op5(&[10 : u64,11,0]) == 11);
    assert(op5(&[0 : u64,0,0]) == 0);
};
fn op6(registers: const *[3] u64) u64 ={ return registers[2]; };
@test fn op6() void = {
    assert(op6(&[10 : u64,0,12]) == 12);
    assert(op6(&[0 : u64,0,0]) == 0);
};
fn op7(registers: const *[3] u64) u64 ={ assert(false); return 0; };

const operands: [8] *operand = [&op0, &op1, &op2, &op3, &op4, &op5, &op6, &op7];


type op = fn(o: u8, registers: *[3]u64, pointer: u8) u8;
fn o0(o: u8, registers: *[3]u64, pointer: u8) u8 = {
    const d: u64 = 1 << operands[o](registers);
    registers[0] = registers[0] / d;
    return pointer + 2;
};
@test fn o0() void = {
    let registers: [3]u64 = [22, 0, 0];
    assert(o0(0, &registers, 2) == 4);
    assert(registers[0] == 22);
    assert(o0(1, &registers, 2) == 4);
    assert(registers[0] == 11);
};

fn o1(o: u8, registers: *[3]u64, pointer: u8) u8 = {
    registers[1] = registers[1] ^ o;
    return pointer + 2;
};
@test fn o1() void = {
    let registers: [3]u64 = [22, 2, 0];
    assert(o1(1, &registers, 2) == 4);
    assert(registers[1] == 3);
    assert(o1(2, &registers, 2) == 4);
    assert(registers[1] == 1);
};
fn o2(o: u8, registers: *[3]u64, pointer: u8) u8 = {
    registers[1] = operands[o](registers) % 8;
    return pointer + 2;
};
@test fn o2() void = {
    let registers: [3]u64 = [22, 2, 0];
    assert(o2(2, &registers, 2) == 4);
    assert(registers[1] == 2);
    assert(o2(4, &registers, 2) == 4);
    assert(registers[1] == 6);
};

fn o3(o: u8, registers: *[3]u64, pointer: u8) u8 = {
    if (registers[0] != 0) {
        return o;
    };
    return pointer + 2;
};
@test fn o3() void = {
    let registers: [3]u64 = [0, 2, 0];
    assert(o3(1, &registers, 2) == 4);
    registers[0] = 1;
    assert(o3(1, &registers, 2) == 1);
};

fn o4(o: u8, registers: *[3]u64, pointer: u8) u8 = {
    registers[1] = registers[1] ^ registers[2];
    return pointer + 2;
};
@test fn o4() void = {
    let registers: [3]u64 = [0, 2, 3];
    assert(o4(4, &registers, 2) == 4);
    assert(registers[1] == 1);
    assert(o4(1, &registers, 2) == 4);
    assert(registers[1] == 2);
};

fn o5(o: u8, registers: *[3]u64, pointer: u8) u8 = {
    const d = operands[o](registers);
    fmt::printf("{},", d % 8)!;
    return pointer + 2;
};

fn o6(o: u8, registers: *[3]u64, pointer: u8) u8 = {
    const d: u64 = 1 << operands[o](registers);
    registers[1] = registers[0] / d;
    return pointer + 2;
};
@test fn o6() void = {
    let registers: [3]u64 = [22, 0, 0];
    assert(o6(0, &registers, 2) == 4);
    assert(registers[1] == 22);
    assert(o6(1, &registers, 2) == 4);
    assert(registers[1] == 11);
};

fn o7(o: u8, registers: *[3]u64, pointer: u8) u8 = {
    const d: u64 = 1 << operands[o](registers);
    registers[2] = registers[0] / d;
    return pointer + 2;
};
@test fn o7() void = {
    let registers: [3]u64 = [22, 0, 0];
    assert(o7(0, &registers, 2) == 4);
    assert(registers[2] == 22);
    assert(o7(1, &registers, 2) == 4);
    assert(registers[2] == 11);
};

export fn main() void = {
    const ops: [8] *op = [&o0, &o1, &o2, &o3, &o4, &o5, &o6, &o7];

    // let registers: [3]u64 = [0, 0, 9];
    // const program: [_]u8 = [2,6];
    // let registers: [3]u64 = [10, 0, 0];
    // const program: [_]u8 = [5,0,5,1,5,4];
    // let registers: [3]u64 = [729, 0, 0];
    // const program: [_]u8 = [0,1,5,4,3,0];
    // let registers: [3]u64 = [2024, 0, 0];
    // const program: [_]u8 = [0,1,5,4,3,0];
    // let registers: [3]u64 = [0, 29, 0];
    // const program: [_]u8 = [1,7];

    let registers: [3]u64 = [41644071, 0, 0];
    const program: [_]u8 = [2,4,1,2,7,5,1,7,4,4,0,3,5,5,3,0];

    let pointer: u8 = 0;

    for (pointer < len(program)) {
        // fmt::printfln("[{}] {},{} A:{} B:{} C:{}, op: {}", pointer, program[pointer], program[pointer + 1], registers[0], registers[1], registers[2], operands[program[pointer + 1]](&registers))!;
        pointer = ops[program[pointer]](program[pointer + 1], &registers, pointer);
    };
    fmt::printfln("[{} oob] A:{} B:{} C:{}", pointer, registers[0], registers[1], registers[2])!;

    fmt::println()!;
};