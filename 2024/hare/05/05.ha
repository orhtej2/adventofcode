use bufio;
use endian;
use fmt;
use hash;
use hash::fnv;
use io;
use os;
use sort;
use strings;
use strconv;

fn int_hash(number: u32) u32 = {
	let hash = fnv::fnv32a();
    let buf: [4]u8 = [0...];
    endian::leputu32(buf, number);
    hash::write(&hash, buf);
	return hash::fnv::sum32(&hash);
};

type set = struct {
    all: []u32,
    entries: [64][]u32,
};

fn make_set(val: u32) set = {
    let retval = set {
        all = [],
        ...
    };
    append(retval.all, val);
    const hash = int_hash(val);
    let bucket = &retval.entries[hash % len(retval.entries)];
    append(bucket, val);

    return retval;
};

fn contains(set: const *set, val: u32)bool = {
    const hash = int_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i] == val) {
            return true;
        };
    };

    return false;
};

fn set_append(set: *set, val: u32)bool  = {
    const hash = int_hash(val);
    let bucket = &set.entries[hash % len(set.entries)];
    for (let i = 0z; i < len(bucket); i += 1) {
        if (bucket[i] == val) {
            return false;
        };
    };

    append(bucket, val);
    append(set.all, val);
    return true;
};

type ordering = struct {
    key: u32,
    entries: set,
};

type order = struct {
	orderings: [64][]ordering,
};

fn order_append(order: *order, key: u32, val: u32)bool = {
    const hash = int_hash(key);
    let bucket = &order.orderings[hash % len(order.orderings)];
	for (let i = 0z; i < len(*bucket); i += 1) {
		if (bucket[i].key == key) {
			set_append(&bucket[i].entries, val);
            return false;
		};
	};

    append(bucket, ordering {
        key = key,
        entries = make_set(val),
    });

    return true;
};

fn order_find(order: const *order, key: u32)set = {
    const hash = int_hash(key);
    let bucket = &order.orderings[hash % len(order.orderings)];
	for (let i = 0z; i < len(*bucket); i += 1) {
		if (bucket[i].key == key) {
            return bucket[i].entries;
		};
	};

    return set { ... };
};

fn validate(rules: const *order, line: str) u32 = {
    const s = strings::split(line,",");
    defer free(s);
    let seen = set {
        ...
    };
    for (let n .. s) {
        const n = strconv::stou32(n)!;
        fmt::printf("{} ", n)!;
        let rules = order_find(rules, n);
        for (const rule .. rules.all) {
            if (contains(&seen, rule)) {
                return 0;
            };
        };
        set_append(&seen, n);
    };

    return strconv::stou32(s[len(s)/2])!;
};

let rules: order = order {
    ...
};

fn relative_order(a: const *opaque, b: const *opaque) int = {
    const a = *(a: const *u32), b = *(b: const *u32);
    const a_rules = order_find(&rules, a);
    if (contains(&a_rules, b)) {
        return -1;
    };
    const b_rules = order_find(&rules, b);
    if (contains(&b_rules, a)) {
        return 1;
    };
    return 0;
};

fn validatep2(rules: const *order, line: str) u32 = {
    const s2 = strings::split(line,",");
    defer free(s2);

    let s: []u32 = [];
    for (let n .. s2) {
        const n = strconv::stou32(n)!;
        append(s, n);
    };

    sort::sort(s, size(u32), &relative_order);

    // let ow: []str = [];
    // defer free(ow);
    // for (const n .. s) { 
    //     append(ow, strconv::u32tos(n));
    // };

    //assert(validate(rules, strings::join(",", ow)) > 0);

    return s[len(s)/2];
};

export fn main() void = {
    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };
        if (len(line) > 0) {
            const s = strings::split(line,"|");
            defer free(s);
            const key = strconv::stou32(s[0])!;
            const val = strconv::stou32(s[1])!;
            order_append(&rules, key, val);
        } else {
            break;
        };
    };

    // for (let i = 0z; i < len(rules.orderings); i += 1) {
    //     fmt::printfln("{} with {}", i, len(rules.orderings[i]))!;
    // };

    let result = 0u, resultp2 = 0u;
    for (true) {
        let line = match(bufio::read_line(os::stdin)!) {
            case let line: []u8 => yield strings::fromutf8(line)!;
            case io::EOF => break;
        };
        if (len(line) > 0) {
            const r = validate(&rules, line);
            if (r > 0) {
                result += r;
            } else {
                resultp2 += validatep2(&rules, line);
            };
        } else {
            break;
        };
        fmt::println()!;
    };

    fmt::printfln("Result is {}, p2: {}", result, resultp2)!;
};