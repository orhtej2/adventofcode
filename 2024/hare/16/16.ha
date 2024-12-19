use bufio;
use fmt;
use io;
use os;
use strings;
use types;

type point = struct {
    x: u8,
    y: u8,
};

type tile = enum { EMPTY, START, FINISH, WALL };

const adjusts: [4][2]i8 = [[0, 1], [-1, 0], [0, -1], [1, 0]];


fn traversable(t: tile) bool = {
    return t == tile::EMPTY || t == tile::FINISH || t == tile::START;
};

fn exits(map: [][]tile, y: size, x: size)u8 = {
    let res: u8 = 0;
    if (traversable(map[y-1][x])) { res += 1; };
    if (traversable(map[y+1][x])) { res += 1; };
    if (traversable(map[y][x-1])) { res += 1; };
    if (traversable(map[y][x+1])) { res += 1; };

    return res;
};

fn print(map: [][]tile) void = {
    for (let i = 1z; i < len(map) - 1; i += 1) {
        for (let j = 1z; j < len(map[i]) - 1; j += 1) {
            switch(map[i][j]) {
                case tile::WALL => fmt::print("#")!;
                case tile::START => fmt::print("S")!;
                case tile::FINISH => fmt::print("E")!;
                case => fmt::print(".")!;
            };
        };
        fmt::println()!;
    };

    fmt::println()!;
    fmt::println()!;
};

fn min(scores: [][][4]u64, y: u8, x: u8) u64 = {
    let r = types::U64_MAX;

    for (let i = 0z; i < 4; i += 1) {
        if (scores[y][x][i] != 0 && scores[y][x][i] < r) {
            r = scores[y][x][i];
        };
    };

    return r;
};

export fn main() void = {
    let map: [][]tile = [];
    defer free(map);

    let exit_x : u8 = 0;
    let exit_y : u8 = 0;

    let start_x : u8 = 0;
    let start_y : u8 = 0;

    let y : u8 = 0;
    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::torunes(strings::fromutf8(line)!);
            case io::EOF => break;
        };
        let l : []tile = [];

        for(let i = 0z; i < len(line); i += 1) {
            if (line[i] == '#') {
                append(l, tile::WALL);
            } else if (line[i] == 'S') {
                append(l, tile::START);
                start_x = (i : u8);
                start_y = y;
            } else if (line[i] == 'E') {
                append(l, tile::FINISH);
                exit_x = (i : u8);
                exit_y = y;
            } else {
                append(l, tile::EMPTY);
            };
        };
        append(map, l);
        y += 1;
    };

    print(map);

    let dirty = true;
    for (dirty) {
        dirty = false;
        for (let i = 1z; i < len(map) - 1; i += 1) {
            for (let j = 1z; j < len(map[i]) - 1; j += 1) {
                if (map[i][j] == tile::EMPTY && exits(map, i, j) < 2) {
                    map[i][j] = tile::WALL;
                    dirty = true;
                };
            };
        };
    };

    print(map);

    let scores: [][][4]u64 = [];
    for (let i = 0z; i < len(map); i+=1) {
        append(scores, alloc([[0...]...],len(map[i])));
    };

    scores[start_y][start_x][0] = 1;

    dirty = true;
    for (dirty) {
        dirty = false;
        for (let i = 1z; i < len(map) - 1; i += 1) {
            for (let j = 1z; j < len(map[i]) - 1; j += 1) {
                if (!traversable(map[i][j])) { continue; };
                for (let d = 0z; d < 4; d += 1) {
                    const cost = scores[(i : i16) - adjusts[d][0]][(j : i16) - adjusts[d][1]][d];
                    if (cost != 0 && (scores[i][j][d] == 0 || scores[i][j][d] > cost + 1)) {
                        dirty = true;
                        scores[i][j][d] = cost + 1;
                    };

                    const cost = scores[i][j][(d + 1) %4] + 1000;
                    if (cost != 1000 && (scores[i][j][d] == 0 || scores[i][j][d] > cost)) {
                        dirty = true;
                        scores[i][j][d] = cost;
                    };

                    const cost = scores[i][j][(d + 3) %4] + 1000;
                    if (cost != 1000 && (scores[i][j][d] == 0 || scores[i][j][d] > cost)) {
                        dirty = true;
                        scores[i][j][d] = cost;
                    };
                };
            };
        };
    };

    dirty = true;
    for (dirty) {
        dirty = false;
        for (let i = 1z; i < len(map) - 1; i += 1) {
            for (let j = 1z; j < len(map[i]) - 1; j += 1) {
                if (!traversable(map[i][j])) { continue; };
                for (let d = 0z; d < 4; d += 1) {
                    if (scores[i][j][d] == 0) { continue; };
                    if (map[i][j] == tile::FINISH) {
                        if (scores[i][j][d] != min(scores, (i : u8), (j : u8))) {
                            dirty = true;
                            scores[i][j][d] = 0;
                        };
                        continue;
                    };

                    if (scores[i][j][d] + 1 > scores[(i : i16) + adjusts[d][0]][(j : i16) + adjusts[d][1]][d]
                        && scores[i][j][d] + 1000 > scores[i][j][(d + 1) %4]
                        && scores[i][j][d] + 1000 > scores[i][j][(d + 3) %4]) {
                        scores[i][j][d] = 0;
                        dirty = true;
                    };
                };
            };
        };
    };

    let p2 = 0;
    for (let i = 1z; i < len(map) - 1; i += 1) {
        for (let j = 1z; j < len(map[i]) - 1; j += 1) {
            if (min(scores, (i : u8), (j : u8)) != types::U64_MAX) {
                p2 += 1;
            };
        };
    };

    fmt::printfln("Result is {}, p2 {}", min(scores, exit_y, exit_x), p2)!;
};