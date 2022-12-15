const std = @import("std");
const fs = std.fs;
const print = std.debug.print;
const assert = std.debug.assert;

const TokenType = enum {
    ArrayStart,
    ArrayEnd,
    Integer,
    SingleIntegerArray,
    SingleIntegerArrayStart,
    SingleIntegerArrayEnd,
    Comma
};

const State = struct {
    depth : u32 = 1,
    borrowed : u32 = 0,
    position : usize = 1,
    lastValue : i32 = 0,
    lastToken : TokenType = TokenType.ArrayStart,
    input : [] const u8
};

fn parse(state : State) !State {
    var result : State = state;
    if (result.lastToken == TokenType.SingleIntegerArrayStart)
    {
        result.lastToken = TokenType.SingleIntegerArray;
        return result;
    }
    else if (result.lastToken == TokenType.SingleIntegerArray 
        or (result.lastToken == TokenType.SingleIntegerArrayEnd and result.borrowed > 0))
    {
        result.borrowed -= 1;
        result.lastToken = TokenType.SingleIntegerArrayEnd;
        return result;
    }
    switch (state.input[state.position]) {
        '[' => { 
            result.depth += 1;
            result.lastToken = TokenType.ArrayStart;
            result.position += 1;
        },
        ']' => {
            result.depth -= 1;
            result.lastToken = TokenType.ArrayEnd;
            result.position += 1;
        },
        ',' => {
            result.lastToken = TokenType.Comma;
            result.position += 1;
        },
        else => {
            var end = state.input.len;
            if (std.mem.indexOfAnyPos(u8, state.input, state.position, "],")) |pos|
            {
                end = pos;
            }
            result.lastToken = TokenType.Integer;
            //print("{s}\n", .{state.input[result.position..]});
            result.lastValue = try std.fmt.parseInt(i32, state.input[result.position..end], 0);
            result.position = end;
        }
    }

    return result;
}

test "parse" {
    var state = State{ .input = "[2]" };
    state = try parse(state);
    try std.testing.expect(state.lastToken == TokenType.Integer);
    try std.testing.expect(state.position == 2);
    try std.testing.expect(state.lastValue == 2);

    state = State{ .input = "[20,1]"};
    state = try parse(state);
    try std.testing.expect(state.lastToken == TokenType.Integer);
    try std.testing.expect(state.position == 3);
    try std.testing.expect(state.lastValue == 20);

    state = try parse(state);
    try std.testing.expect(state.lastToken == TokenType.Comma);
    try std.testing.expect(state.position == 4);

    state = try parse(state);
    try std.testing.expect(state.lastToken == TokenType.Integer);
    try std.testing.expect(state.position == 5);
    try std.testing.expect(state.lastValue == 1);
}

fn adjust(left : State, right : State) !?State {
    if ((left.lastToken == TokenType.Integer or left.lastToken == TokenType.SingleIntegerArray) and right.lastToken == TokenType.ArrayStart)
    {
        var result = left;
        result.borrowed += 1;
        result.lastToken = TokenType.SingleIntegerArrayStart;

        return result;
    }

    return null;
}

test "adjust" {
    var stateLeft = State{ .input = "[2]" };
    var stateRight = State{ .input = "[[2]]" };

    stateLeft = try parse(stateLeft);
    stateRight = try parse(stateRight);

    try std.testing.expect(stateLeft.lastToken == TokenType.Integer);
    try std.testing.expect(stateLeft.position == 2);
    try std.testing.expect(stateLeft.lastValue == 2);

    try std.testing.expect(stateRight.lastToken == TokenType.ArrayStart);
    try std.testing.expect(stateRight.position == 2);
    
    var adjusted = try adjust(stateLeft, stateRight);
    
    try std.testing.expect(adjusted != null);
    try std.testing.expect(adjusted.?.lastToken == TokenType.SingleIntegerArrayStart);
    try std.testing.expect(adjusted.?.position == 2);

    stateLeft = try parse(adjusted.?);
    stateRight = try parse(stateRight);

    try std.testing.expect(stateLeft.lastToken == TokenType.SingleIntegerArray);
    try std.testing.expect(stateLeft.position == 2);
    try std.testing.expect(stateLeft.lastValue == 2);

    try std.testing.expect(stateRight.lastToken == TokenType.Integer);
    try std.testing.expect(stateRight.position == 3);
    try std.testing.expect(stateRight.lastValue == 2);

    stateLeft = try parse(stateLeft);
    stateRight = try parse(stateRight);

    try std.testing.expect(stateLeft.lastToken == TokenType.SingleIntegerArrayEnd);
    try std.testing.expect(stateLeft.position == 2);

    try std.testing.expect(stateRight.lastToken == TokenType.ArrayEnd);
    try std.testing.expect(stateRight.position == 4);
}

test "adjustDoubleNestedLeft" {
    var stateLeft = State{ .input = "[2]" };
    var stateRight = State{ .input = "[[[2]]]" };

    stateLeft = try parse(stateLeft);
    stateRight = try parse(stateRight);

    try std.testing.expect(stateLeft.lastToken == TokenType.Integer);
    try std.testing.expect(stateLeft.position == 2);
    try std.testing.expect(stateLeft.lastValue == 2);

    try std.testing.expect(stateRight.lastToken == TokenType.ArrayStart);
    try std.testing.expect(stateRight.position == 2);

    var adjusted = try adjust(stateLeft, stateRight);
    
    try std.testing.expect(adjusted != null);
    try std.testing.expect(adjusted.?.lastToken == TokenType.SingleIntegerArrayStart);
    try std.testing.expect(adjusted.?.position == 2);
}

test "adjustDoubleNestedRight" {
    var stateLeft = State{ .input = "[[[2]]]" };
    var stateRight = State{ .input = "[2]" };

    stateLeft = try parse(stateLeft);
    stateRight = try parse(stateRight);

    try std.testing.expect(stateLeft.lastToken == TokenType.ArrayStart);
    try std.testing.expect(stateLeft.position == 2);
    
    try std.testing.expect(stateRight.lastToken == TokenType.Integer);
    try std.testing.expect(stateRight.position == 2);
    try std.testing.expect(stateRight.lastValue == 2);

    var adjusted = try adjust(stateLeft, stateRight);
    try std.testing.expect(adjusted == null);

    adjusted = try adjust(stateRight, stateLeft);    
    try std.testing.expect(adjusted != null);
    try std.testing.expect(adjusted.?.lastToken == TokenType.SingleIntegerArrayStart);
    try std.testing.expect(adjusted.?.position == 2);
    try std.testing.expect(adjusted.?.borrowed == 1);

    print("{}\n{}\n\n", .{stateLeft, adjusted.?});

    stateLeft = try parse(stateLeft);
    stateRight = try parse(adjusted.?);

    print("{}\n{}\n\n", .{stateLeft, stateRight});

    adjusted = try adjust(stateLeft, stateRight);
    try std.testing.expect(adjusted == null);

    adjusted = try adjust(stateRight, stateLeft);    
    print("{}\n{}\n{}\n\n", .{stateLeft, stateRight, adjusted.?});
    try std.testing.expect(adjusted != null);

    try std.testing.expectEqual(TokenType.ArrayStart, stateLeft.lastToken);
    try std.testing.expect(stateLeft.position == 3);
    
    try std.testing.expectEqual(TokenType.SingleIntegerArrayStart, adjusted.?.lastToken);
    try std.testing.expect(adjusted.?.position == 2);

    stateLeft = try parse(stateLeft);
    stateRight = try parse(adjusted.?);

    print("{}\n{}\n\n", .{stateLeft, stateRight});

    adjusted = try adjust(stateLeft, stateRight);
    try std.testing.expect(adjusted == null);

    adjusted = try adjust(stateRight, stateLeft);    
    try std.testing.expect(adjusted == null);

    print("{}\n{}\n\n", .{stateLeft, stateRight});

    try std.testing.expectEqual(TokenType.Integer, stateLeft.lastToken);
    try std.testing.expect(stateLeft.position == 4);
    try std.testing.expect(stateLeft.lastValue == 2);
    
    try std.testing.expectEqual(TokenType.SingleIntegerArray, stateRight.lastToken);
    try std.testing.expect(stateRight.position == 2);
    try std.testing.expect(stateRight.lastValue == 2);
}

fn skipArray(state : State, targetDepth : u32) !State {
    var result : State = state;
    // print("skipping {s}\n", .{state.input});
    while (result.depth + result.borrowed > targetDepth and result.lastToken != TokenType.ArrayEnd and result.lastToken != TokenType.SingleIntegerArrayEnd)
    {
        print("{c}\n", .{state.input[state.position]});
        result = try parse(result);
    }

    return result;
}

fn checkOrder(left : [] const u8, right : [] const u8) !bool {
    // print("{s}\n{s}\n", .{left, right});
    var leftState = State{ .input = left };
    var rightState = State{ .input = right };

    while(true)
    {
        leftState = try parse(leftState);
        rightState = try parse(rightState);
        // print("a\n{}\n{},\n\n", .{leftState, rightState});
        if (try adjust(leftState, rightState)) |new| {
            leftState = new;
        }
        else if (try adjust(rightState, leftState)) |new| {
            rightState = new;
        }

        // print("b\n{}\n{},\n\n", .{leftState, rightState});

        //assert(leftState.depth == rightState.depth);
        if (leftState.depth == 0 or rightState.depth == 0)
            return leftState.position == leftState.input.len;
        
        switch (leftState.lastToken)
        {
            TokenType.ArrayEnd, TokenType.SingleIntegerArrayEnd => {
                // print("skip?{c}", .{'\n'});
                if (rightState.lastToken != TokenType.ArrayEnd and rightState.lastToken != TokenType.SingleIntegerArrayEnd)
                    return true;
            },
            TokenType.Comma => {
                // print("comma?{c}", .{'\n'});
                if (rightState.lastToken != TokenType.Comma)
                    return false;
            },
            TokenType.Integer,TokenType.SingleIntegerArray => {
                // print("int?{c}", .{'\n'});
                //print("{}\n{}\n\n", .{leftState, rightState});
                if (rightState.lastToken == TokenType.ArrayEnd or rightState.lastToken == TokenType.SingleIntegerArrayEnd)
                    return false;
                if (leftState.lastValue != rightState.lastValue)
                    return leftState.lastValue < rightState.lastValue;
            },
            TokenType.ArrayStart, TokenType.SingleIntegerArrayStart  => {
                if (rightState.lastToken == TokenType.ArrayEnd or rightState.lastToken == TokenType.SingleIntegerArrayEnd)
                    return false;
            }
        }
    }
    
    unreachable;
}

test "isolated2" {
    try std.testing.expect(!(try checkOrder("[[[],[],8,10,2],[]]", "[[],[8,[[4,8,2,9,3],[4,0]]]]")));
}

test "isolated" {
    try std.testing.expect(try checkOrder("[[8,[[7]]]]", "[[[[8],[3]]]]"));
    // 1
    // l-> array [8,[[7]]]
    // r -> array [[[[8],[3]]]]

    // 2
    // l -> 8
    // r -> array []
    // promote l to [8]

    // 3
    // l -> [8]
    // r -> [[8],[3]]
    // promote l to [[8]]

    // ok, [8] == [8], no more elements lhs

    // 4
    // l -> [[7]]
    // r -> end

    // -> false, l > r
}

test "checkOrdered" {
    try std.testing.expect(try checkOrder("[]", "[]"));
    try std.testing.expect(try checkOrder("[]", "[2]"));
    try std.testing.expect(try checkOrder("[2]", "[2]"));
    try std.testing.expect(try checkOrder("[2]", "[[2]]"));
    try std.testing.expect(try checkOrder("[[2]]", "[2]"));
    try std.testing.expect(try checkOrder("[2]", "[3]"));
    try std.testing.expect(try checkOrder("[[[2]]]", "[3]"));
    try std.testing.expect(try checkOrder("[[[]]]", "[3]"));
    try std.testing.expect(try checkOrder("[[],[0],[[]]]", "[[0],[[4]]]"));
    try std.testing.expect(try checkOrder("[[8,[[7]]]", "[[[[8],[3]]]]"));
    try std.testing.expect(try checkOrder("[1,3]", "[[1,[4]],2]"));
}

test "check not Ordered" {
    try std.testing.expect(!(try checkOrder("[2]", "[]")));
    try std.testing.expect(!(try checkOrder("[2, 1]", "[2]")));
    try std.testing.expect(!(try checkOrder("[3]", "[[2]]")));
    try std.testing.expect(!(try checkOrder("[[3]]", "[2]")));
    try std.testing.expect(!(try checkOrder("[3]", "[2]")));
    try std.testing.expect(!(try checkOrder("[1,3]", "[1,2]")));
}

pub fn main() !void {
    var file = try fs.cwd().openFile("input2.txt", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    var in_stream = buf_reader.reader();
   
    var tf = try fs.cwd().openFile("input2_tf.txt", .{});
    defer tf.close();
    var buf_reader2 = std.io.bufferedReader(tf.reader());
    var tfs = buf_reader2.reader();
   
    
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();

    var result : u32 = 0;
    var buf: [10000]u8 = undefined;
    var idx : u32 = 1;
    while (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1000)) |line|
    {
        var ln1 : []const u8 = line;
        if (line.len != 0 and line[line.len - 1] == 13)
            ln1 = line[0..line.len-1];

        if (ln1.len == 0)
            break;

        if (try in_stream.readUntilDelimiterOrEofAlloc(allocator, '\n', 1000)) |line2|
        {
            var ln2 : [] const u8 = line2;
            if (line2.len != 0 and line2[line2.len - 1] == 13)
            ln2 = line2[0..line2.len-1];

            if (ln2.len == 0)
                break;
            const r = try checkOrder(ln1, ln2);
            const res = try tfs.readUntilDelimiterOrEof(&buf, '\n');
            if (r != (res.?[0] == '1'))
            {
                print("{s}\n{s}\n{} vs {c}\n", .{ln1, ln2, r, res.?[0]});
            }
            // print("{}\n\n", .{r});
            if (r)
                result += idx;
        }

        idx += 1;
        _ = in_stream.readUntilDelimiterOrEof(&buf, '\n') catch ""; // skip empty separator
    }

    print("{d}\n", .{result});
}
