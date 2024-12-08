use bufio;
use encoding::utf8;
use endian;
use fmt;
use hash;
use hash::fnv;
use io;
use math;
use os;
use strconv;
use strings;

type point = struct {
    x: u32,
    y: u32,
};

type set = struct {
    entries: [64][]point,
    all: []point,
    count: u32,
};

fn point_hash(point: point) u32 = {
	let hash = fnv::fnv32a();
    let buf: [4]u8 = [0...];
    endian::leputu32(buf, point.x);
    hash::write(&hash, buf);
    endian::leputu32(buf, point.y);
    hash::write(&hash, buf);
	return hash::fnv::sum32(&hash);
};

fn contains(set: const *set, val: point) bool = {
    const hash = point_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i].x == val.x && bucket[i].y == val.y) {
            return true;
        };
    };

    return false;
};

fn set_append(set: *set, val: point)bool  = {
    const hash = point_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i].x == val.x && bucket[i].y == val.y) {
            return false;
        };
    };

    append(bucket, val);
    set.count += 1;
    append(set.all, val);
    return true;
};

type map_entry = struct {
    key: rune,
    entries: set,
};

type map = struct {
	entries: [64][]map_entry,
    keys: []rune
};

fn rune_hash(r: rune)u32 = {
    const encoded = encoding::utf8::encoderune(r);
    let hash = fnv::fnv32a();
    hash::write(&hash, encoded);
	return hash::fnv::sum32(&hash);
};

fn map_append(map: *map, key: rune, val: point) bool = {
    const hash = rune_hash(key);
    let bucket = &map.entries[hash % len(map.entries)];
	for (let i = 0z; i < len(*bucket); i += 1) {
		if (bucket[i].key == key) {
			set_append(&bucket[i].entries, val);
            return false;
		};
	};

    append(map.keys, key);
    let n = map_entry {
        key = key,
        entries = set {
            ...
        },
    };

    set_append(&n.entries, val);
    append(bucket, n);

    return true;
};

fn map_find(map: const *map, key: rune)set = {
    const hash = rune_hash(key);
    let bucket = &map.entries[hash % len(map.entries)];
	for (let i = 0z; i < len(*bucket); i += 1) {
		if (bucket[i].key == key) {
            return bucket[i].entries;
		};
	};

    return set { ... };
};

fn free_set(set: *set)void = {
    free(set.all);
    for (let i = 0z; i < len(set.entries); i += 1) {
        free(set.entries[i]);
    };

};

fn free_map(map: *map) void = {
    free(map.keys);
    for (let bucket .. map.entries) {
        for (let b .. bucket) {
            free_set(&b.entries);
        };
    };
};

export fn main() void = {
    let maxx = 0, maxy = 0;

    let map = map {
        ...
    };

    defer free_map(&map);

    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::torunes(strings::fromutf8(line)!);
            case io::EOF => break;
        };
        maxx = (len(line) : int);
        maxy += 1;

        for(let i = 0z; i < len(line); i += 1) {
            const r = line[i];
            fmt::print(r)!;
            if (r == '.') {
                continue;
            };

            map_append(&map, r, point { x = ((i + 1) : u32), y = (maxy : u32)});
        };
        fmt::println()!;
    };

    let spots = set {
        ...
    };

    for (let r .. map.keys) {
        const s = map_find(&map, r);
        const l = len(s.all);
        for (let i = 0z; i < l - 1; i += 1) {
            for (let j = i + 1; j < l; j += 1) {
                fmt::printfln("{} at {}/{} vs {}/{}", r, s.all[i].x, s.all[i].y, s.all[j].x, s.all[j].y)!;
                const xdiff = (s.all[i].x : int) - ( s.all[j].x: int);
                const ydiff = (s.all[i].y : int) - ( s.all[j].y: int);
                fmt::printfln("x {} y {}", xdiff, ydiff)!;

                const xa = (s.all[i].x : int) + xdiff;
                const ya = (s.all[i].y : int) + ydiff;
                if (xa > 0 && xa <= maxx && ya > 0 && ya <= maxy) {
                    set_append(&spots, point { x = (xa : u32), y = (ya : u32)});
                };
                const xa = (s.all[j].x : int) - xdiff;
                const ya = (s.all[j].y : int) - ydiff;
                if (xa > 0 && xa <= maxx && ya > 0 && ya <= maxy) {
                    set_append(&spots, point { x = (xa : u32), y = (ya : u32)});
                };
                // break;
            };
            // break;
        };
        // break;
    };

    for (const p .. spots.all) {
        fmt::printfln("{}/{}", p.x, p.y)!;
    };

    for (let j = 1; j <= maxy; j += 1) {
        for (let i = 1; i <= maxx; i += 1) {
            if (contains(&spots, point {x = (i : u32), y = (j : u32)})) {
                fmt::print("#")!;
            } else {
                fmt::print(".")!;
            };
        };
        fmt::println()!;
    };


    fmt::printfln("Result is {}", spots.count)!;
};