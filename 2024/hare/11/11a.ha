use bufio;
use endian;
use fmt;
use hash;
use hash::fnv;
use io;
use os;
use strconv;
use strings;

type map_entry = struct {
    key: u64,
    count: u64,
};

type map = struct {
	entries: [64][]map_entry,
    keys: []u64
};

fn int_hash(number: u64) u32 = {
	let hash = fnv::fnv32a();
    let buf: [8]u8 = [0...];
    endian::leputu64(buf, number);
    hash::write(&hash, buf);
	return hash::fnv::sum32(&hash);
};


fn map_add(map: *map, key: u64, val: u64) bool = {
    const hash = int_hash(key);
    let bucket = &map.entries[hash % len(map.entries)];
	for (let i = 0z; i < len(*bucket); i += 1) {
		if (bucket[i].key == key) {
			bucket[i].count += val;
            return false;
		};
	};

    append(map.keys, key);
    let n = map_entry {
        key = key,
        count = val
    };

    append(bucket, n);

    return true;
};

fn map_find(map: const *map, key: u64)u64 = {
    const hash = int_hash(key);
    let bucket = &map.entries[hash % len(map.entries)];
	for (let i = 0z; i < len(*bucket); i += 1) {
		if (bucket[i].key == key) {
            return bucket[i].count;
		};
	};

    return 0u;
};

fn free_map(map: *map) void = {
    free(map.keys);
    for (let bucket .. map.entries) {
        free(bucket);
    };
};

fn digits(number: u64) u8 = {
    let d :u8 = (1u : u8);
    for (number / 10u > 0) {
        number /= 10u;
        d += 1;
    };

    return d;
};

@test fn digits() void = {
    assert(digits(0u) == 1u);
    assert(digits(1u) == 1u);
    assert(digits(10u) == 2u);
    assert(digits(11u) == 2u);
    assert(digits(333u) == 3u);
};

fn arreq(l: [2]u64, r: [2]u64) bool = {
    return l[0] == r[0] && l[1] == r[1];
};

@test fn arreq() void = {
    assert(arreq([1u, 2u], [1u, 2u]));
    assert(!arreq([5u, 2u], [1u, 2u]));
    assert(!arreq([5u, 2u], [5u, 88u]));
};

fn split(number: u64) [2]u64 = {
    static let buf: [2]u64 = [0, 0];
    const d = digits(number) / 2;
    let n : u64 = 1u;
    for (let i = 0u; i < d; i += 1) {
        n *= 10u;
    };
    buf[0] = number / n;
    buf[1] = number % n;
    // fmt::printfln("For {} - {} and {}", number, buf[0], buf[1])!;
    return buf;
};

@test fn split() void = {
    assert(arreq(split(10u), [1u, 0u]));
    assert(arreq(split(98u), [9u, 8u]));
    assert(arreq(split(1000u), [10u, 0u]));
    assert(arreq(split(1928u), [19u, 28u]));
};

fn step(stones: *map) map = {
    let result = map { ... };
    for (const s .. stones.keys) {
        const count = map_find(stones, s);
        if (s == 0) {
            map_add(&result, 1u, count);
        } else if (digits(s) % 2 == 0) {
            const sp = split(s);
            map_add(&result, sp[0], count);
            map_add(&result, sp[1], count);
            // fmt::printfln("{} becomes {} and {}", s, sp[0], sp[1])!;
        } else {
            map_add(&result, s * (2024u : u64), count);
            // fmt::printfln("{} becomes {}", s, s * (2024u : u32))!;
        };
    };
    return result;
};

export fn main() void = {
    let line = match(bufio::read_line(os::stdin)!) {
        case let line: []u8 => yield strings::fromutf8(line)!;
        case io::EOF => return;
    };
    defer free(line);
    const numbers = strings::split(line, " ");
    defer free(numbers);
    let stones = map { ... };
    for (const n .. numbers) {
        map_add(&stones, strconv::stou64(n)!, 1);
    };

    // for (const s .. stones) {
    //     fmt::printf("{} ", s)!;
    // };
    // fmt::println()!;
    // fmt::println()!;

    for (let i = 0; i < 75; i += 1) {
        const n = step(&stones);
        free_map(&stones);
        stones = n;

        // for (const s .. stones) {
        //     fmt::printf("{} ", s)!;
        // };
        // fmt::println()!;
        // fmt::println()!;
    };
    
    // for (const s .. stones) {
    //     fmt::printf("{} ", s)!;
    // };
    // fmt::println()!;

    let result : u64 = 0u;
    for (const k .. stones.keys) {
        result += map_find(&stones, k);
    };
    fmt::printfln("Result is {}", result)!;
};