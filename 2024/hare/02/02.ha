use bufio;
use fmt;
use io;
use math;
use os;
use strconv;
use strings;

fn parse_report(line: str) ([]int | io::EOF | strconv::error) = {
    let retval: []int = [];
    const split = strings::split(line, " ");
    defer free(split);
    const l = len(split);
    if (l == 0) {
        return io::EOF;
    };
    for (const tok .. split) {
        append(retval, strconv::stoi(tok)!);
    };
    return retval;
};

fn is_valid_report(report: []int) bool = {
    const l = len(report);
    if (l == 1) {
        return true;
    };

    const init_diff = math::signi(report[1] - report[0]);
    for (let i = 1z; i < l; i += 1) {
        const diff = report[i] - report[i-1];
        const times = diff * init_diff;
        if (times <= 0 || times > 3) {
            return false;
        };
    };

    return true;
};

fn is_valid_report_v2(report: []int) bool = {
    if (is_valid_report(report)) {
        return true;
    };

    const l = len(report);
    for (let i = 0z; i < l; i += 1) {
        let spliced: []int = [];
        defer free(spliced);
        for (let j = 0z; j < l; j += 1) {
            if (i == j) {
                continue;
            };
            append(spliced, report[j]);
        };

        if (is_valid_report(spliced)) {
            return true;
        };
    };

    return false;
};

@test fn is_valid_report() void = {
    const valid_reports: [][]int = [[1, 2, 3], [1, 4, 7], [3, 2, 1]];
    for (let report .. valid_reports) {
        assert(is_valid_report(report));
    };

    const invalid_reports: [][]int = [[1, 2, 9], [1, 1, 7], [9, 2, 1], [1, 2, 1]];
    for (let report .. invalid_reports) {
        assert(!is_valid_report(report));
    };
};

@test fn is_valid_report_v2() void = {
    const valid_reports: [][]int = [[7, 6, 4, 2, 1], [1, 3, 2, 4, 5], [8, 6, 4, 4, 1], [1, 3, 6, 7, 9]];
    for (let report .. valid_reports) {
        assert(is_valid_report_v2(report));
    };

    const invalid_reports: [][]int = [[1, 2, 7, 8, 9], [9, 7, 6, 2, 1]];
    for (let report .. invalid_reports) {
        assert(!is_valid_report_v2(report));
    };
};

export fn main() void = {
    let valid = 0u, validv2 = 0u;
    for (true) {
		let line = match(bufio::read_line(os::stdin)!) {
			case let line: []u8 => yield strings::fromutf8(line)!;
			case io::EOF => break;
		};
		let report = match(parse_report(line)!) {
            case let report: []int => yield report;
            case io::EOF => break;
        };

        if (is_valid_report(report)) {
            valid = valid + 1;
            validv2 = validv2 + 1;
        } else if (is_valid_report_v2(report)) {
            validv2 = validv2 + 1;
        };
    };

    fmt::printfln("Valid reports: {}", valid)!;
    fmt::printfln("Valid v2 reports: {}", validv2)!;
};